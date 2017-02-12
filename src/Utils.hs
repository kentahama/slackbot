{-# LANGUAGE OverloadedStrings #-}
module Utils
    ( sendTeX
    ) where

import           Web.Slack
import           Web.Slack.Message      (sendMessage)
import           Web.Slack.State        (config)
import           Web.Slack.WebAPI       (files_upload)
import           Control.Lens           (use, (^.))
import           Control.Monad          (when)
import           Control.Monad.IO.Class (liftIO)
import           Control.Monad.Trans    (lift)
import           Control.Monad.Except
import qualified Data.Text    as T
import qualified Data.Text.IO as T
import           System.Process
import           System.Exit

type TeX = T.Text


-- |Write math.tex which is `\input`ted from frame.tex,
-- and compile it.
platex :: TeX -> IO (ExitCode, String)
platex tex = do
  T.writeFile "math.tex" tex
  (exitCode, stdout, stderr) <- readProcessWithExitCode "platex" ["frame.tex"] ""
  return (exitCode, concat [stdout, "\n",  stderr])

sendImage :: ChannelId -> FilePath -> Slack s ()
sendImage cid path = do
  conf <- use config
  file <- runExceptT $ files_upload conf cid path "rendered.png"
  either (liftIO . print) rememberFileId file

rememberFileId :: File -> Slack s ()
rememberFileId file = do
  liftIO . print $ file ^. id

sendTeX :: ChannelId -> TeX -> Slack s ()
sendTeX cid tex = void . runExceptT $ do
  (exitCode, errMsg) <- liftIO $ platex tex
  when (exitCode /= ExitSuccess) $ throwError errMsg
  liftIO $ system "run.sh"
  lift $ sendImage cid "math.png"
  `catchError` \errMsg -> lift $ do
    sendMessage cid "error: see #stderr"
    sendMessage (Id "stderr") $ T.pack errMsg
