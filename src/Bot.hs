{-# LANGUAGE OverloadedStrings #-}
module Bot
    ( bot
    ) where

import Web.Slack
import Web.Slack.Message

import Control.Lens

import Control.Monad
import Control.Monad.IO.Class

import qualified Data.Text as T
import qualified Data.Text.IO as TIO

idText :: UserId -> T.Text
idText uid = T.concat ["<@", uid ^. getId, ">"]

bot :: SlackBot ()
bot Hello = do
  myid <- use $ session . slackSelf . selfUserId
  liftIO $ print myid
bot (Message cid who msg time styp edt) = do
  myid <- use $ session . slackSelf . selfUserId
  when (idText myid `T.isPrefixOf` msg) $
    sendMessage cid "Hi!"
  liftIO $ TIO.putStrLn msg
bot _ = return ()
