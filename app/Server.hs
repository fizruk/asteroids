{-# LANGUAGE RecordWildCards #-}
module Main (main) where

import API

import Servant
import Network.Wai (Application)
import Network.Wai.Handler.Warp (run)
import System.Environment


server :: Server ServerAPI
server = serveGame

app :: Application
app = serve (Proxy :: Proxy ServerAPI) server

main :: IO()
main = do
    argv <- getArgs
    let http_port = (read . head) argv :: Int
    let ws_port = (read . head . tail) argv :: Int
    run http_port app