{-# LANGUAGE OverloadedStrings #-}
module Main where

import Utils (sendTeX)

import Web.Slack

import System.Environment (lookupEnv)
import System.Directory (doesFileExist)
import Data.Maybe (fromMaybe)
import Control.Monad (when)
import qualified Data.Text as T

texPrefix = "tex:"
texBody msg = T.drop (T.length texPrefix) msg
mathPrefix = "math:"
mathBody msg = T.drop (T.length mathPrefix) msg

bot :: SlackBot ()
bot (Message cid _ msg _ _ _) = do
  when (texPrefix `T.isPrefixOf` msg) $
    sendTeX cid (texBody msg)
  when (mathPrefix `T.isPrefixOf` msg) $
    sendTeX cid $ T.concat ["$$", mathBody msg, "$$"]
bot (HiddenMessage cid _  _ (Just (SMessageChanged (MessageUpdate _ msg _ _ _)))) = do
  when (texPrefix `T.isPrefixOf` msg) $
    sendTeX cid (texBody msg)
  when (mathPrefix `T.isPrefixOf` msg) $
    sendTeX cid $ T.concat ["$$", mathBody msg, "$$"]
bot _ = return ()

main :: IO ()
main = do
  doesFileExist "frame.tex" >>= errorOnNotExist "flame.tex not found. Please run in 'work'."
  doesFileExist "run.sh"    >>= errorOnNotExist    "run.sh not found. Please run in 'work'."
  apiToken <- fromMaybe (error "SLACK_API_TOKEN not set")
               <$> lookupEnv "SLACK_API_TOKEN"
  runBot (myConfig apiToken) bot ()
  where
    errorOnNotExist errMsg exist = when (not exist) (error errMsg)
    myConfig apiToken = SlackConfig {_slackApiToken = apiToken}
