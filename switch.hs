#! /usr/bin/env nix-shell
#! nix-shell -i runghc -p "haskellPackages.ghcWithPackages (ps: [ps.turtle ps.polysemy ps.polysemy-plugin])"
#! nix-shell -I nixpkgs=https://github.com/NixOS/nixpkgs-channels/archive/d5291756487d70bc336e33512a9baf9fa1788faf.tar.gz
{-# OPTIONS_GHC -fplugin=Polysemy.Plugin #-}
{-# LANGUAGE OverloadedStrings #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeApplications #-}
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
