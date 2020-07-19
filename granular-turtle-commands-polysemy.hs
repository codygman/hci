#! /usr/bin/env nix-shell
#! nix-shell -i runghc -p "haskellPackages.ghcWithPackages (ps: [ps.turtle ps.polysemy ps.polysemy-plugin])"
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/a84cbb60f0296210be03c08d243670dd18a3f6eb.tar.gz
-- TODO running actual script doesn't work because polysemy plugin broken in above revision, try a84cbb60f0296210be03c08d243670dd18a3f6eb
{-# OPTIONS_GHC -fplugin=Polysemy.Plugin #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE BlockArguments #-}
import Polysemy
import Polysemy.Input
import Polysemy.Output
import Polysemy.Error
import Polysemy.Resource
import Polysemy.Trace
import           Turtle
import Prelude hiding (FilePath)
import qualified System.FilePath as SysFilepath

data ShellCommand m a where
  WhichCmd :: SysFilepath.FilePath -> ShellCommand m (Maybe FilePath)
  EchoCmd :: String -> ShellCommand m ()
  TestPathCmd :: SysFilepath.FilePath -> ShellCommand m Bool

makeSem ''ShellCommand

runShellCommandPure :: Sem (ShellCommand : r) a -> Sem r a
runShellCommandPure = interpret \case
  EchoCmd str -> pure ()
  WhichCmd str -> pure (Just $ decodeString str)
  TestPathCmd str -> pure True

runShellCommandIO :: Member (Embed IO) r => Sem (ShellCommand : r) a -> Sem r a
runShellCommandIO = interpret \case
  EchoCmd str -> embed $ putStrLn str
  WhichCmd filePath -> embed $ which (fromString filePath)

main :: IO ()
main = do
  putStrLn "Pure interpreter"

  putStrLn "1."
  Main.echoCmd "hi" & runShellCommandPure  & run & print 
  putStrLn ""

  putStrLn "2. The pure interpretation of whichCmd always gives Nothing"
  Main.whichCmd "nonexistent" & runShellCommandPure & runM >>= print
  putStrLn ""

  putStrLn "3. The pure interpretation of TestPath always gives True"
  testPathCmd "nonexistent" & runShellCommandPure & runM >>= print
  putStrLn ""


  
  putStrLn "Impure interpreter"

  putStrLn "1."
  Main.echoCmd "hi" & runShellCommandIO  & runM
  putStrLn ""

  putStrLn "2. Test a nonexistent command gives nothing"
  Main.whichCmd "nonexistent" & runShellCommandIO  & runM >>= print
  putStrLn ""

  putStrLn "3. Test an existing command gives Just"
  Main.whichCmd "ghc" & runShellCommandIO  & runM >>= print
  putStrLn ""
