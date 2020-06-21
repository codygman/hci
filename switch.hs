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

makeSem ''HomeManager

installHomeManager :: (Member HomeManager r, Member Trace r) => Sem r String
installHomeManager = do
  installStatus <- homeManagerInstalled
  case installStatus of
    AlreadyInstalledHomeManager -> do
      trace "already installed home-manager"
      pure (show AlreadyInstalledHomeManager)
    NeedToInstallHomeManager -> do
      trace "installing home-manager"
      pure "mock success installing home-manager"

homeManagerPure :: HomeManagerInstalledStatus -> Sem (HomeManager ': r) a -> Sem r a
homeManagerPure installState = interpret \case
  HomeManagerInstall -> pure "HomeManagerInstall"
  HomeManagerInstalled -> pure installState

homeManagerIO :: Member (Embed IO) r => Sem (HomeManager ': r) a -> Sem r a
homeManagerIO = interpret \case
  HomeManagerInstall -> pure "HomeManagerInstall"
  HomeManagerInstalled -> embed . single $ isHomeManagerInstalled

isHomeManagerInstalled :: Shell HomeManagerInstalledStatus
isHomeManagerInstalled = maybe NeedToInstallHomeManager (const AlreadyInstalledHomeManager) <$> which (fromString "home-manager")


-- TODO actually do the things and run the commands
-- leave this til last, keep these super simple 1 to 1 mappings, and the pure versions of tests should guarantee the impure work
-- homeManagerIO

main :: IO ()
main = do
  -- putStrLn "If we already installed home manager, it should say 'AlreadyInstalledHomeManager' below:"
  -- print . run . homeManagerPure AlreadyInstalledHomeManager $ installHomeManager
  -- putStrLn "If we haven't installed home manager, it should say 'install home manager success' below:"
  -- print . run . homeManagerPure NeedToInstallHomeManager $ installHomeManager
  -- putStrLn "actually do the thing"
  -- installHomeManager & homeManagerPure AlreadyInstalledHomeManager & runTraceList & run & fst & mapM_ print
  installHomeManager & traceToIO & homeManagerIO & runM & (print =<<)


homeManager opts = inproc "home-manager" opts empty
