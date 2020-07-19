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
  SymlinkCmd :: SysFilepath.FilePath -> SysFilepath.FilePath -> ShellCommand m ()

makeSem ''ShellCommand

runShellCommandPure :: Member Trace r => Sem (ShellCommand : r) a -> Sem r a
runShellCommandPure = interpret \case
  EchoCmd str -> pure ()
  WhichCmd str -> pure (Just $ decodeString str)
  TestPathCmd str -> do
    -- PROBLEM: If I always return False here I can't test the pure version of `symlinkIfNotExist`)
    trace $ "Pure testpathcmd: returning False for: " <> str
    pure False
  SymlinkCmd _ _ -> pure ()

runShellCommandIO :: (Member (Embed IO) r, Member Trace r) => Sem (ShellCommand : r) a -> Sem r a
runShellCommandIO = interpret \case
  EchoCmd str -> embed $ putStrLn str
  WhichCmd filepath -> embed $ which (fromString filepath)
  TestPathCmd filepath -> do
    res <- embed $ testpath (fromString filepath)
    trace $ "test path for" <> filepath <> " returned: " <> show res
    pure res
  SymlinkCmd from to -> do
    symlink (decodeString from) (decodeString to)

symlinkIfNotExist :: (Member Trace r, Member ShellCommand r) => FilePath -> FilePath -> Sem r ()
symlinkIfNotExist from to = do
  fromExists <- testPathCmd (encodeString from)
  toExists <- testPathCmd (encodeString to)
  case (fromExists, toExists) of
    (_, True) -> trace $ "destination already exists at: " <> encodeString to -- TODO warn when symlink is a different from
    (False, False)  -> trace "source does not exist"
    (True, False)  -> do
      trace "creating symlink"
      symlinkCmd (encodeString from) (encodeString to)

main :: IO ()
main = do
  putStrLn "Pure interpreter"

  putStrLn "1."
  Main.echoCmd "hi" & runShellCommandPure & runTraceList & run & print 
  putStrLn ""

  putStrLn "2. The pure interpretation of whichCmd always gives Nothing"
  Main.whichCmd "nonexistent" & runShellCommandPure & runTraceList & run & print
  putStrLn ""

  putStrLn "3. The pure interpretation of TestPath always gives False"
  testPathCmd "nonexistent" & runShellCommandPure & runTraceList & run & print
  putStrLn ""

  putStrLn "4. Creates a symlink if one doesn't already exist"
  symlinkIfNotExist "nonexistent from" "nonexistent to" & runShellCommandPure & runTraceList & run & print
  putStrLn ""


  
  putStrLn "Impure interpreter"

  putStrLn "1."
  Main.echoCmd "hi" & runShellCommandIO & runTraceList & runM
  putStrLn ""

  putStrLn "2. Test a nonexistent command gives nothing"
  Main.whichCmd "nonexistent" & runShellCommandIO & runTraceList & runM >>= print
  putStrLn ""

  putStrLn "3. Test an existing command gives Just"
  Main.whichCmd "ghc" & runShellCommandIO & runTraceList & runM >>= print
  putStrLn ""

  putStrLn "4. Creates a symlink if source filepath exists and destination doesn't already exist"
  symlinkIfNotExist "/etc/issue" "bar" & runShellCommandIO & runTraceList & runM >>= print
  putStrLn ""
