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

main = do
  userHome <- home
  hciDir  <- pwd
  let myNixPkgs   = hciDir </> decodeString "nixpkgs"
      nixpkgConfigPath = userHome </> decodeString ".config/nixpkgs"
  initialSetup userHome myNixPkgs nixpkgConfigPath hciDir

initialSetup userHome myNixPkgs nixPkgConfigPath hciDir = do
  homeManagerSetup nixPkgConfigPath myNixPkgs
  doomSetup userHome hciDir

homeManagerSetup nixPkgConfigPath myNixPkgs = do
  userHome <- home
  notExistOrFail nixPkgConfigPath "Nix pkg config path already exists, exiting"
  echo . unsafeTextToLine $ format ("homeManagerSetup: " % fp) myNixPkgs
  echo . unsafeTextToLine $ format ("homeManagerSetup: " % fp) nixPkgConfigPath
  symlink myNixPkgs nixPkgConfigPath

  which "home-manager" >>= \hm -> case hm of
    Just _ -> pure ()
    Nothing -> installHomeManager
  view $ homeManager ["switch"]


doomInstalled :: IO Bool
doomInstalled = pure False

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

cloneDoomEmacsD = do
   userHome <- home
   testdir (userHome </> ".emacs.d") >>= \there -> if there then empty else
     git ["clone","-b","develop", "git://github.com/hlissner/doom-emacs", format fp (userHome </> ".emacs.d")]

linkConfigDoom userHome hciDir = do
  let myDoomDir = hciDir </> decodeString "doom"
      doomConfigDir = userHome </> decodeString ".doom.d"
  notExistOrFail doomConfigDir "~/.doom.d already exists, exiting. Back up or remove it then run ./bootstrap.hs again"
  symlink myDoomDir doomConfigDir

doomSetup userHome hciDir = do
  notExistOrFail (userHome </> ".emacs.d")  "~/.config/.emacs.d already exists, exiting. Back up or remove it then run ./bootstrap.hs again"
  doomInstalled >>= \di -> when (not di) $ do
    echo "doom setup"
    view $ cloneDoomEmacsD
  doom ["install"]

notExistOrFail dir msg = do
  exists <- testdir dir
  if exists then
    fail $ "directory exists when we expected it not to: " <> show dir
    else
    pure ()

installHomeManager = do
  view $ proc
      "nix-channel"
      [ "--add"
      , "https://github.com/rycee/home-manager/archive/master.tar.gz"
      , "home-manager"
      ]
    empty
  view $ proc "nix-channel" ["--update"] empty
  view $ shell "nix-shell '<home-manager>' -A install" empty

homeManager opts = inproc "home-manager" opts empty

git opts = inproc "git" opts empty

doom opts = home >>= \uh -> inproc (format fp (uh </> ".emacs.d" </> "bin" </> "doom")) opts empty

echoTxt :: Text -> IO ()
echoTxt = echo . unsafeTextToLine
