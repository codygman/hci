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

-- my human computing interface "installed" by symlinking /path/to/git/repo to ~/.config/nixpkgs
-- The part I want to have a pure/effectful version of is symlinking since I keep mucking up the logic for some reason and want to have a pure version to test against


-- Return Types
data HomeManagerInstallStatus = AlreadyInstalledHomeManager | NeedToInstallHomeManager deriving (Ord, Eq, Show)
data HCIInstallStatus = HCISymlinked | HCINotSymlinked deriving (Ord, Eq, Show)


-- GADTS
data HCI m a where
  HCIInstall :: HCI m HCIInstallStatus
  HCIInstalled :: HCI m HCIInstallStatus
makeSem ''HCI

data HomeManager m a where
  HomeManagerInstall :: HomeManager m String
  HomeManagerInstalled :: HomeManager m HomeManagerInstallStatus
  HomeManagerSwitch :: HomeManager m ()
makeSem ''HomeManager

-- interpreters
homeManagerPure :: (Member Trace r) => HomeManagerInstallStatus -> Sem (HomeManager ': r) a -> Sem r a
homeManagerPure installState = interpret \case
  HomeManagerInstall -> pure "HomeManagerInstall"
  HomeManagerInstalled -> pure installState
  HomeManagerSwitch -> do
    trace "home manager switch"
    pure ()

hciPure :: (Member Trace r) => HCIInstallStatus -> Sem (HCI ': r) a -> Sem r a
hciPure hciInstallState = interpret \case
  HCIInstall -> do
    -- installHCI
    pure hciInstallState
  HCIInstalled -> pure hciInstallState

-- polysemy functions? Not sure what to call this one. It's an interpreter too?
installHCI :: (Member Trace r, Member HCI r) => Sem r ()
installHCI = do
  status <- hCIInstalled
  if (status == HCINotSymlinked) then do
    trace "symlinking config to ~/.config/nixpkgs"
    pure ()
    else pure ()

syncHci :: (Member HCI r, Member HomeManager r, Member Trace r) => Sem (HCI ': r) a -> Sem r ()
syncHci = do
  -- hCIInstall
  maybeInstallHomeManager
  homeManagerSwitch

homeManagerIO :: (Member (Embed IO) r) => Sem (HomeManager ': r) a -> Sem r a
homeManagerIO = interpret \case
  HomeManagerInstall -> pure "HomeManagerInstall"
  HomeManagerInstalled -> embed . single $ isHomeManagerInstalled
  HomeManagerSwitch -> embed . sh $ homeManager ["switch"]


isHCISymlinked :: Shell HCIInstallStatus
isHCISymlinked = pure HCINotSymlinked

isHomeManagerInstalled :: Shell HomeManagerInstallStatus
isHomeManagerInstalled = maybe NeedToInstallHomeManager (const AlreadyInstalledHomeManager) <$> which (fromString "home-manager")

ppTraceOutput :: ([String], ()) -> IO ()
ppTraceOutput = mapM_ putStrLn . fst

main :: IO ()
main = do
  {-
   Potential States:
     1. HCISymlinked,AlreadyInstalledHomeManager -- Everything's good, should be this most of the time
     2. HCINotSymlinked,NeedToInstallHomeManager -- Nothing installed, needs to be installed
     3. HCINotSymlinked,AlreadyInstalledHomeManager -- Someone who is trying hci?
     4. HCINotSymlinked,NeedToInstallHomeManager -- Weird case... maybe home-manager was uninstalled?
  -}
  putStrLn "Pure interpreters"
  putStrLn "1."
  -- syncHci & homeManagerPure AlreadyInstalledHomeManager & _ &
  --   runTraceList & run & ppTraceOutput
  -- syncHci & homeManagerPure AlreadyInstalledHomeManager & hciPure HCISymlinked & runTraceList & run & ppTraceOutput
  putStrLn ""
  putStrLn ""
  -- putStrLn "2."
  syncHci & hciPure HCINotSymlinked & homeManagerPure NeedToInstallHomeManager &
    runTraceList & run & ppTraceOutput
  -- putStrLn ""
  -- putStrLn ""
  -- putStrLn "Actually sync hci"
  -- syncHci & traceToIO & homeManagerIO & runM & (print =<<)

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


homeManager opts = inproc "home-manager" opts empty
