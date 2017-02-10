module Main where

import Bot (bot)

import Web.Slack

import System.Environment (lookupEnv)
import System.Directory (doesFileExist)
import Data.Maybe (fromMaybe)
import Control.Monad (when)

myConfig :: String -> SlackConfig
myConfig apiToken = SlackConfig
         { _slackApiToken = apiToken -- Specify your API token here
         }

main :: IO ()
main = do
  doesFileExist "frame.tex" >>= errorOnNotExist "flame.tex not found. Please run in 'work'."
  doesFileExist "run.sh"    >>= errorOnNotExist    "run.sh not found. Please run in 'work'."
  apiToken <- fromMaybe (error "SLACK_API_TOKEN not set")
               <$> lookupEnv "SLACK_API_TOKEN"
  runBot (myConfig apiToken) bot ()
  where
    errorOnNotExist errMsg exist = when (not exist) (error errMsg)
