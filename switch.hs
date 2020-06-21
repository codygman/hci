#! /usr/bin/env nix-shell
#! nix-shell -i runghc -p "haskellPackages.ghcWithPackages (ps: [ps.turtle ps.polysemy ps.polysemy-plugin])"
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/d5291756487d70bc336e33512a9baf9fa1788faf.tar.gz
{-# OPTIONS_GHC -fplugin=Polysemy.Plugin #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
-- NOTE: nixpkgs is pinned to nixpkgs-1909 2020-03-28
-- it's 1909 mostly so that I don't have to build ghc on android
-- which kept failing for some reason with previous pin
-- import qualified Data.Text                     as T
-- import           Turtle
-- import           Data.Time
-- import           Control.Monad
-- import qualified Control.Foldl as Fold
-- import Data.Maybe
import Data.Function
import Polysemy
import Polysemy.State
import Polysemy.Error

example :: Members '[State String, Error String] r => Sem r String
example = do
  put "start"
  let throwing, catching :: Members '[State String, Error String] r => Sem r String
      throwing = do
        modify (++"-throw")
        throw "error"
        get
      catching = do
        modify (++"-catch")
        get
  catch throwing (\ _ -> catching)

main = example
    & runError
    & fmap (either id id)
    & evalState ""
    & runM
    & (print =<<)


-- example :: Members '[State String, Error String] r => Sem r String

foo :: Members '[] r => Sem r String
foo = do
  pure "foo"
  -- put "start"
  -- let throwing, catching :: Members '[State String, Error String] r => Sem r String
  --     throwing = do
  --       modify (++"-throw")
  --       throw "error"
  --       get
  --     catching = do
  --       modify (++"-catch")
  --       get
  -- catch @String throwing (\ _ -> catching)

fooWithState :: Members '[State String] r => Sem r String
fooWithState = do
  put ("start" :: String)
  pure "foo"

-- . embed $ (print 2)
    -- & runError
    -- & fmap (either id id)
    -- & evalState ""
    -- & runM
    -- & (print =<<)


-- doomDirNixPkgs :: Shell Turtle.FilePath
-- doomDirNixPkgs = (</> (decodeString ".config" </> decodeString "nixpkgs")) <$> home

-- nixpkgConfigPath :: Shell Turtle.FilePath
-- nixpkgConfigPath = undefined

-- removeNixConfig = undefined
-- linkNixConfig = undefined

-- main = do
--   userHome <- home
--   doomDir  <- pwd
--   let doomDirNixpkgs   = doomDir </> decodeString "nixpkgs"
--       nixpkgConfigPath = userHome </> decodeString ".config/nixpkgs"
--   -- initialSetup doomDirNixpkgs nixpkgConfigPath
--   -- nixConfig <- fromMaybe False <$> fold nixConfigExists Fold.head
--   -- unless nixConfig . sh $ removeNixConfig -- >> linkNixConfig
--   -- view $ homeManager ["switch"]
--   view $ do
--     liftIO $ putStrLn "enter"
--     nixConfig <- testdir nixpkgConfigPath
--     homeManager <- maybe False (const True) <$> which "home-manager"
--     unless nixConfig $ liftIO $ putStrLn "remove and link nixconfig"
--     unless homeManager $ installHomeManager
--     liftIO $ putStrLn "exit"
--     -- homeManager ["switch"]

--         -- symlink doomDirNixpkgs nixpkgConfigPath

-- installHomeManager = do
--   view . liftIO $ putStrLn "installing home manager"
--   -- view $ proc
--   --     "nix-channel"
--   --     [ "--add"
--   --     , "https://github.com/rycee/home-manager/archive/master.tar.gz"
--   --     , "home-manager"
--   --     ]
--   --   empty
--   -- view $ proc "nix-channel" ["--update"] empty
--   -- view $ shell "nix-shell '<home-manager>' -A install" empty

-- homeManager opts = inproc "home-manager" opts empty

-- git opts = inproc "git" opts empty

-- doom opts = home >>= \uh -> inproc (format fp (uh </> ".emacs.d" </> "bin" </> "doom")) opts empty

-- echoTxt :: Text -> IO ()
-- echoTxt = echo . unsafeTextToLine
