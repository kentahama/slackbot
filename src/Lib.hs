module Lib
    ( myBot
    ) where

import Web.Slack
import Web.Slack.Message

import Control.Lens

import Control.Monad
import Control.Monad.IO.Class

import qualified Data.Text as T
import qualified Data.Text.IO as TIO

idText :: UserId -> T.Text
idText uid = T.pack $ "<" ++ show uid ++ ">"

myBot :: SlackBot ()
myBot Hello = do
  myid <- use $ session . slackSelf . selfUserId . getId
  liftIO $ print myid
myBot (Message cid who msg time styp edt) = do
  myid <- use $ session . slackSelf . selfUserId . getId
  -- when (idText myid `T.isInfixOf` msg) $ sendMessage cid "Hi!"
  liftIO $ TIO.putStr msg
myBot _     = return ()
