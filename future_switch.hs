#! /usr/bin/env nix-shell
#! nix-shell -i runghc -p "haskellPackages.ghcWithPackages (ps: [ps.turtle])"
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/d5291756487d70bc336e33512a9baf9fa1788faf.tar.gz
{-# LANGUAGE OverloadedStrings #-}
-- NOTE: nixpkgs is pinned to nixpkgs-1909 2020-03-28
-- it's 1909 mostly so that I don't have to build ghc on android
-- which kept failing for some reason with previous pin
import qualified Data.Text                     as T
import           Turtle
import           Data.Time
import           Control.Monad
import System.IO.Temp
import Control.Monad.Catch

main = do
  userHome <- home
  hciDir  <- pwd
  let myNixPkgs = hciDir </> decodeString "nixpkgs"
      nixpkgConfigPath = userHome </> decodeString ".config/nixpkgs"
  initialSetup userHome myNixPkgs nixpkgConfigPath hciDir

initialSetup userHome myNixPkgs nixpkgConfigPath hciDir = do
  sh $ homeManagerSetupSwitch nixpkgConfigPath myNixPkgs
  sh $ doomSetupOrSync userHome hciDir

homeManagerSetupSwitch :: Turtle.FilePath -> Turtle.FilePath -> Shell Line
homeManagerSetupSwitch nixpkgConfigPath myNixPkgs = do
  userHome <- home
  testpath nixpkgConfigPath >>= \pathExist -> when pathExist $ do
    testfile nixpkgConfigPath >>= \isFile -> when isFile $ do
      echoTxt $ format ("homeManagerSetupSwitch: removing current symlink to " % w) nixpkgConfigPath
      rm nixpkgConfigPath -- just assume it's a symlink here
    testdir nixpkgConfigPath >>= \isdir -> when isdir $
      -- if for some reason this isn't a symlink, let's go ahead and do an ephemeral backup to /tmp and print it out
      liftIO $ ephemeralBackup nixpkgConfigPath
  echoTxt $ format ("homeManagerSetupSwitch: creating symlink from " % fp % " to " % fp) myNixPkgs nixpkgConfigPath
  symlink myNixPkgs nixpkgConfigPath

  which "home-manager" >>= \hm -> case hm of
    Just _ -> echo "homeManagerSetupSwitch: already installed" >> pure ()
    Nothing -> installHomeManager

  echo "homeManagerSetupSwitch: switching"
  homeManager ["switch"]

doomInstalled :: Shell Bool
doomInstalled = do
  userHome <- home
  let doomInstalledTests = [ testdir (userHome </> ".doom.d")
                           , testdir (userHome </> ".emacs.d") -- TODO improve this by checking it's a doom repo, perhaps right revision, etc
                           ]
  doomInstalled <- fmap (all (== True)) . sequenceA $ doomInstalledTests
  case doomInstalled of
    True -> stdout "doom is installed" >> pure True
    False -> stdout "doom is not installed" >> pure False

configDoomExists :: IO Bool
configDoomExists = do
  userHome <- home
  testdir (userHome </> ".doom.d") >>= \cde -> do
    when cde $ echo "A ~/.doom.d folder exists, assuming it's the right one"
    pure cde

emacsDExists :: Shell Bool
emacsDExists = do
  userHome <- home
  echo "An emacs.d folder exists, assuming it's the right one"
  testdir (userHome </> ".emacs.d")

cloneDoomEmacsD :: Shell Line
cloneDoomEmacsD = do
   echo "cloneDoomEmacsD"
   userHome <- home
   testdir (userHome </> ".emacs.d") >>= \there -> if there then empty else
     git ["clone","-b","develop", "git://github.com/hlissner/doom-emacs", format fp (userHome </> ".emacs.d")]

linkConfigDoom userHome hciDir = do
  let myDoomDir = hciDir </> decodeString "doom"
      doomConfigDir = userHome </> decodeString ".doom.d"
  notExistOrFail doomConfigDir "~/.doom.d already exists, exiting. Back up or remove it then run ./bootstrap.hs again"
  symlink myDoomDir doomConfigDir

-- TODO actually use this; similar to homeManagerSetupSwitch testPath branches
doomSetupOrSync :: Turtle.FilePath -> Turtle.FilePath -> Shell Line
doomSetupOrSync userHome hciDir = do
  let doomConfigDir = userHome </> decodeString ".doom.d"
  testdir doomConfigDir >>= \there -> if there then do
    echoTxt "doom already there, removing and linking"
    rm doomConfigDir
    linkConfigDoom userHome hciDir
    else do
      echo "~/.doom.d not there linking ~/hci/doom to ~/.doom.d"
      -- NOTE this is brittle, but it works for now
      linkConfigDoom userHome hciDir
  doomInstalled >>= \di -> when (not di) $ do
    echo "doomSetupOrSync: doom not installed"
    stdout cloneDoomEmacsD
    echo "doomSetupOrSync: doom install"
    stdout $ doom ["install", "--yes"]
  echo "doomSetupOrSync: doom sync"
  doom ["sync"]

ephemeralBackup :: (MonadIO m, MonadMask m) => Turtle.FilePath -> m ()
ephemeralBackup dir = do
  let tmpDirTemplate = encodeString $ filename dir
  echoTxt $ format ("creating tmp dir with template" % w) tmpDirTemplate
  withSystemTempDirectory tmpDirTemplate $ \tmpFilePath -> do
    echoTxt $ format ("ephemeralBackup of directory: " % fp % " to " % w) dir tmpFilePath
    let tmpFilePathFp = decodeString tmpFilePath
    echoTxt $ format ("copying directory " % fp % " to " % fp) dir tmpFilePathFp
    cptree dir tmpFilePathFp
    echoTxt $ format ("rm directory " % fp) dir
    rmtree dir
  echo "finished with ephemeral backup"

notExistOrFail dir msg = do
  exists <- testdir dir
  if exists then
    fail $ "directory exists when we expected it not to: " <> show dir
    else
    pure ()

installHomeManager :: Shell ()
installHomeManager = do
  echo "installing home manager"
  proc
      "nix-channel"
      [ "--add"
      , "https://github.com/rycee/home-manager/archive/master.tar.gz"
      , "home-manager"
      ]
    empty
  proc "nix-channel" ["--update"] empty
  view $ shell "nix-shell '<home-manager>' -A install" empty

homeManager opts = inproc "home-manager" opts empty

git opts = inproc "git" opts empty

doom opts = home >>= \uh -> inproc (format fp (uh </> ".emacs.d" </> "bin" </> "doom")) opts empty

echoTxt :: MonadIO io => Text -> io ()
echoTxt = echo . unsafeTextToLine
