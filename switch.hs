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

data HomeManagerInstalledStatus = AlreadyInstalledHomeManager | NeedToInstallHomeManager deriving (Ord, Eq, Show)

data HomeManager m a where
  HomeManagerInstall :: HomeManager m String
  HomeManagerInstalled :: HomeManager m HomeManagerInstalledStatus
  HomeManagerSwitch :: HomeManager m ()

makeSem ''HomeManager

maybeInstallHomeManager :: (Member HomeManager r, Member Trace r) => Sem r String
maybeInstallHomeManager = do
  installStatus <- homeManagerInstalled
  case installStatus of
    AlreadyInstalledHomeManager -> do
      trace "already installed home-manager"
      pure (show AlreadyInstalledHomeManager)
    NeedToInstallHomeManager -> do
      installHomeManager

installHomeManager :: (Member Trace r) => Sem r String
installHomeManager = do
  trace "trying to install home-manager"
  trace "(TODO implement) success installing home-manager"
  pure "Success"

homeManagerPure :: (Member Trace r) => HomeManagerInstalledStatus -> Sem (HomeManager ': r) a -> Sem r a
homeManagerPure installState = interpret \case
  HomeManagerInstall -> pure "HomeManagerInstall"
  HomeManagerInstalled -> pure installState
  HomeManagerSwitch -> do
    trace "home manager switch"
    pure ()

homeManagerIO :: (Member (Embed IO) r) => Sem (HomeManager ': r) a -> Sem r a
homeManagerIO = interpret \case
  HomeManagerInstall -> pure "HomeManagerInstall"
  HomeManagerInstalled -> embed . single $ isHomeManagerInstalled
  HomeManagerSwitch -> embed . sh $ homeManager ["switch"]

isHomeManagerInstalled :: Shell HomeManagerInstalledStatus
isHomeManagerInstalled = maybe NeedToInstallHomeManager (const AlreadyInstalledHomeManager) <$> which (fromString "home-manager")

syncHci :: (Member HomeManager r, Member Trace r) => Sem r ()
syncHci = do
  maybeInstallHomeManager
  homeManagerSwitch

main :: IO ()
main = do
  let ppTraceOutput = mapM putStrLn . fst
  -- pure
  putStrLn "Pure interpreters"
  putStrLn "1. If home-manager is already installed"
  syncHci & homeManagerPure AlreadyInstalledHomeManager &
    runTraceList & run & ppTraceOutput
  putStrLn ""
  putStrLn ""
  putStrLn "2. If home-manager isn't installed"
  syncHci & homeManagerPure NeedToInstallHomeManager &
    runTraceList & run & ppTraceOutput
  putStrLn ""
  putStrLn ""
  -- putStrLn "Actually sync hci"
  -- syncHci & traceToIO & homeManagerIO & runM & (print =<<)


homeManager opts = inproc "home-manager" opts empty
