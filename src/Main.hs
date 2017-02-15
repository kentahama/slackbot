{-# LANGUAGE OverloadedStrings #-}
module Main where

import Utils (sendTeX)

import Web.Slack

import System.Environment (lookupEnv)
import System.Directory (doesFileExist)
import Data.Maybe (fromMaybe)
import Control.Monad (forM_, when)
import qualified Data.Text as T

type Prefix = T.Text
type MsgHandler = T.Text -> T.Text

prefixes :: [(Prefix, MsgHandler)]
prefixes = [ ("tex:" , id)
           , ("math:", \msg -> T.concat ["$$", msg, "$$"])
           ]

dropPrefix :: Prefix -> T.Text -> T.Text
dropPrefix = T.drop . T.length

bot :: SlackBot ()
bot (Message cid _ msg _ _ _) =
  forM_ prefixes $ \(prefix, handler) ->
    when (prefix `T.isPrefixOf` msg) $ do
      let msgbody = dropPrefix prefix msg
      sendTeX cid (handler msgbody)
bot (HiddenMessage cid _  _ (Just (SMessageChanged (MessageUpdate _ msg _ _ _)))) =
  forM_ prefixes $ \(prefix, handler) ->
    when (prefix `T.isPrefixOf` msg) $ do
      let msgbody = dropPrefix prefix msg
      sendTeX cid (handler msgbody)
bot _ = return ()

main :: IO ()
main = do
  doesFileExist "frame.tex" >>= errorOnNotExist "flame.tex not found. Please run in 'work'."
  doesFileExist "run.sh"    >>= errorOnNotExist    "run.sh not found. Please run in 'work'."
  apiToken <- fromMaybe (error "SLACK_API_TOKEN not set")
               <$> lookupEnv "SLACK_API_TOKEN"
  runBot (SlackConfig apiToken) bot ()
  where
    errorOnNotExist errMsg exist = when (not exist) (error errMsg)
