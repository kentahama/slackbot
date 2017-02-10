{-# LANGUAGE OverloadedStrings #-}
module Bot
    ( bot
    ) where

import           Web.Slack
import           Web.Slack.Message      (sendMessage)
import           Web.Slack.State        (config)
import           Web.Slack.WebAPI       (files_upload)
import           Control.Lens           (use)
import           Control.Monad          (when)
import           Control.Monad.IO.Class (liftIO)
import           Control.Monad.Trans    (lift)
import           Control.Monad.Except
import qualified Data.Text    as T
import qualified Data.Text.IO as T
import           System.Process
import           System.Exit

type TeX = T.Text

platex :: IO (ExitCode, String)
platex = do
  (exitCode, stdout, stderr) <-
    readProcessWithExitCode "platex" ["frame.tex"] ""
  return (exitCode, concat [stdout, "\n",  stderr])

sendImage :: ChannelId -> FilePath -> Slack s ()
sendImage cid path = do
  conf <- use config
  e <- runExceptT $ files_upload conf cid path "rendered.png"
  liftIO $ print e

sendTeX :: ChannelId -> TeX -> Slack s ()
sendTeX cid body = void . runExceptT $ do
  liftIO $ T.writeFile "math.tex" body
  (exitCode, errMsg) <- liftIO platex
  when (exitCode /= ExitSuccess) $
    throwError errMsg
  liftIO $ system "run.sh"
  lift $ sendImage cid "math.png"
  `catchError` \errMsg -> lift $ do
    sendMessage cid "error: see #stderr"
    sendMessage (Id "#stderr") $ T.pack errMsg

bot :: SlackBot ()
bot (Message cid _ msg _ _ _) = do
  when (texPrefix `T.isPrefixOf` msg) $
    sendTeX cid texBody
  when (mathPrefix `T.isPrefixOf` msg) $
    sendTeX cid $ T.concat ["$$", mathBody, "$$"]
  where
    texPrefix = "tex:"
    texBody = T.drop (T.length texPrefix) msg
    mathPrefix = "math:"
    mathBody = T.drop (T.length mathPrefix) msg
bot _ = return ()
