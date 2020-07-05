#!/usr/bin/env bash

set -o errexit

echo "cd to simple-haskell-project"
cd $GITHUB_WORKSPACE/testdata/simple-haskell-project
echo "it's directory looks like"
ls | head -n5
nix-shell --pure --run "echo \"finished building nix shell for simple-haskell\""
echo "out of nix-shell invocation for building nix-shell for simple-haskell"
echo "verify we have the right ghc"
nix-shell --pure --run "realpath $(which ghc)"
