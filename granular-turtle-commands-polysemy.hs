#! /usr/bin/env nix-shell
#! nix-shell -i runghc -p "haskellPackages.ghcWithPackages (ps: [ps.turtle ps.polysemy ps.polysemy-plugin])"
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/a84cbb60f0296210be03c08d243670dd18a3f6eb.tar.gz

{-# LANGUAGE BlockArguments #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE GADTs #-}
{-# LANGUAGE LambdaCase #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE PolyKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE TypeApplications #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# OPTIONS_GHC -fplugin=Polysemy.Plugin #-}

-- TODO running actual script doesn't work because polysemy plugin broken in above revision, try a84cbb60f0296210be03c08d243670dd18a3f6eb

import qualified Data.Map as Map
import Polysemy
import Polysemy.Error
import Polysemy.Input
import Polysemy.Output
import Polysemy.Resource
import Polysemy.Trace
import qualified System.FilePath as SysFilepath
import Turtle
import Prelude hiding (FilePath)

data ShellCommand m a where
  WhichCmd :: FilePath -> ShellCommand m (Maybe FilePath)
  EchoCmd :: String -> ShellCommand m ()
  TestPathCmd :: FilePath -> ShellCommand m Bool
  SymlinkCmd :: FilePath -> FilePath -> ShellCommand m ()
makeSem ''ShellCommand

data InstallStatus = AlreadyInstalled
                   | InstallSuccess
                   | NotInstalled
                   deriving Show
                   -- | ErrorInstalling -- TODO

data HomeManager m a where
  HomeManagerInstall :: HomeManager m InstallStatus
makeSem ''HomeManager

symlinkIfNotExist :: (Member Trace r, Member ShellCommand r) => FilePath -> FilePath -> Sem r ()
symlinkIfNotExist from to = do
  fromExists <- testPathCmd from
  toExists <- testPathCmd to
  case (fromExists, toExists) of
    (_, True) -> trace $ "symlinkIfNotExist: destination already exists at: " <> encodeString to -- TODO warn when symlink is a different from
    (False, False) -> trace "symlinkIfNotExist: source does not exist"
    (True, False) -> do
      trace "symlinkIfNotExist: creating symlink"
      symlinkCmd from to

maybeInstallHomeManager :: (Member Trace r, Member ShellCommand r, Member HomeManager r) => Sem r InstallStatus
maybeInstallHomeManager = do
  trace "we might install it"
  homeManagerInstalled <- whichCmd "home-manager"
  case homeManagerInstalled of
    Just _ -> pure AlreadyInstalled
    Nothing -> homeManagerInstall

newtype PureHomeManagerState = HomeManagerState InstallStatus

runHomeManagerPure :: Member Trace r => PureHomeManagerState -> Sem (HomeManager : r) InstallStatus -> Sem r InstallStatus
runHomeManagerPure homeManagerState = interpret \case
  HomeManagerInstall -> do
    case homeManagerState of
      HomeManagerState AlreadyInstalled -> do
        trace "HomeManagerInstall: home-manager already installed"
        pure AlreadyInstalled
      HomeManagerState InstallSuccess -> error "invalid state" -- TODO probably bad also
      HomeManagerState NotInstalled -> do
        trace "HomeManagerInstall: installing home-manager"
        -- For now we'll say the pure version always succeeds installing
        pure InstallSuccess

runHomeManagerIO :: Member Trace r => Sem (HomeManager : r) a -> Sem r a
runHomeManagerIO = interpret \case
  HomeManagerInstall -> do
    -- The problem here is now we have duplicate logic around the install state
    -- of home manager between the IO and pure interpreters
    -- This is bad. If the interpreters don't stay simple, the tests of the pure variant
    -- aren't very useful as far as I can see.
    -- This means we need some sort of state 
    -- Maybe we can rename `HomeManagerInstall` to `HomeManagerMaybeInstall`
    -- Does that help us though? The problem here is how do we make sure that dispatching logic
    -- of already installed, install not installed, etc is done in a differnt function?
    -- then what's know known as HomeManagerInstall just calls that function in both the
    -- pure and impure variants
    -- Maybe it's just my naming that's making it confusing
    trace "runHomeManagerIO: install home manager"
    pure InstallSuccess

data PureFilePathState = NoFilePathsExist
                       | AllFilePathsExist
                       | CustomFilePaths (Map.Map FilePath FilePathExistence)

runShellCommandPure :: Member Trace r => PureFilePathState -> Sem (ShellCommand : r) a -> Sem r a
runShellCommandPure filePathState = interpret \case
  EchoCmd str -> pure ()
  WhichCmd str -> pure (Just str)
  TestPathCmd filepath -> do
    -- TODO lambdacase this?
    case filePathState of
      NoFilePathsExist -> pure False
      AllFilePathsExist -> pure True
      CustomFilePaths filepathMap -> do
        -- TODO use maybe here?
        case Map.lookup filepath filepathMap of
          Just val -> do
            -- TODO lambda case?
            case val of
              FilePathExists -> do
                trace $ "testPathCmd: filepath exists: " <> show filepath
                pure True
              FilePathDoesNotExist -> do
                trace $ "testPathCmd: filepath exists: " <> show filepath
                pure False
          Nothing -> do
            -- TODO this is bad.... maybe... probably
            error $ "Your filepathMap doesn't have an entry for " <> show filepath
  SymlinkCmd _ _ -> pure ()

runShellCommandIO :: (Member (Embed IO) r, Member Trace r) => Sem (ShellCommand : r) a -> Sem r a
runShellCommandIO = interpret \case
  EchoCmd str -> embed $ putStrLn str
  WhichCmd filepath -> embed $ which filepath
  TestPathCmd filepath -> do
    res <- embed $ testpath filepath
    trace $ "test path for" <> show filepath <> " returned: " <> show res
    pure res
  SymlinkCmd from to -> do
    symlink from to

data FilePathExistence = FilePathExists | FilePathDoesNotExist deriving (Ord, Eq, Show)




main :: IO ()
main = do

  putStrLn "* Pure HomeManager"
  putStrLn "** homeManagerInstall installs homeManager"
  homeManagerInstall & runHomeManagerPure (HomeManagerState NotInstalled) & runTraceList & run & print
  putStrLn ""
  putStrLn "** If not installed, home-manager is installed - maybeInstallHomeManager"
  maybeInstallHomeManager & runShellCommandPure AllFilePathsExist & runHomeManagerPure (HomeManagerState NotInstalled) & runTraceList & run & print
  
  -- TODO turn these pure interpreter things into hspec tests
  -- putStrLn "Pure interpreter"
  -- putStrLn "1."
  -- Main.echoCmd "hi" & runShellCommandPure NoFilePathsExist & runTraceList & run & print
  -- putStrLn ""
  -- putStrLn "2. The pure interpretation of whichCmd always gives Nothing"
  -- Main.whichCmd "nonexistent" & runShellCommandPure NoFilePathsExist & runTraceList & run & print
  -- putStrLn ""
  -- putStrLn "3. The pure interpretation of TestPath always gives False"
  -- testPathCmd "nonexistent" & runShellCommandPure NoFilePathsExist & runTraceList & run & print
  -- putStrLn ""
  -- putStrLn "4. Creates a symlink if one doesn't already exist (State: no filepaths, so expect source does not exist)"
  -- symlinkIfNotExist "nonexistent from" "nonexistent to" & runShellCommandPure NoFilePathsExist & runTraceList & run & print
  -- putStrLn ""
  -- putStrLn "5. Creates a symlink if one doesn't already exist (State: happy path, source exists, destination does not)"
  -- let source = decodeString "/etc/issue"
  --     destination = decodeString "bar"
  --     state =
  --       CustomFilePaths $
  --         Map.fromList
  --           [ (source, FilePathExists),
  --             (destination, FilePathDoesNotExist)
  --           ]
  --  in symlinkIfNotExist source destination & runShellCommandPure state & runTraceList & run & print
  -- putStrLn ""
  -- putStrLn "6. Warns destination exists and doesn't create symlink"
  -- let source :: FilePath = decodeString "/etc/issue"
  --     destination :: FilePath = decodeString "existent"
  --     state =
  --       CustomFilePaths $
  --         Map.fromList
  --           [ (source, FilePathExists),
  --             (destination, FilePathExists)
  --           ]
  --  in symlinkIfNotExist source destination & runShellCommandPure state & runTraceList & run & print
  -- putStrLn ""
  -- putStrLn "7. Warns source exists and doesn't create symlink"
  -- let source :: FilePath = decodeString "/etc/issue"
  --     destination :: FilePath = decodeString "existent"
  --     state =
  --       CustomFilePaths $
  --         Map.fromList
  --           [ (source, FilePathDoesNotExist),
  --             (destination, FilePathDoesNotExist)
  --           ]
  --  in symlinkIfNotExist source destination & runShellCommandPure state & runTraceList & run & print
  -- putStrLn ""
  -- putStrLn "Impure interpreter"
  -- putStrLn "1."
  -- Main.echoCmd "hi" & runShellCommandIO & runTraceList & runM
  -- putStrLn ""
  -- putStrLn "2. Test a nonexistent command gives nothing"
  -- Main.whichCmd "nonexistent" & runShellCommandIO & runTraceList & runM >>= print
  -- putStrLn ""
  -- putStrLn "3. Test an existing command gives Just"
  -- Main.whichCmd "ghc" & runShellCommandIO & runTraceList & runM >>= print
  -- putStrLn ""
  -- putStrLn "4. Creates a symlink if source filepath exists and destination doesn't already exist"
  -- symlinkIfNotExist "/etc/issue" "bar" & runShellCommandIO & runTraceList & runM >>= print
  -- putStrLn ""
