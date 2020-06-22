#! /usr/bin/env bash

nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update
export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH

echo "home looks like this"
ls -larth "$HOME"

echo "find nix.sh in .nix-profile"
find "$HOME/.nix-profile" -iname "nix.sh"

echo "NIX_PATH: $NIX_PATH"

# remove zshrc and bashrc so home-manager can overwrite them
# TODO add this into bootstrap.hs and only do this on travis?
[[ -f ~/.bashrc ]] || rm -v ~/.bashrc
[[ -f ~/.zshrc ]] || rm -v ~/.zshrc
home-manager switch
emacs -batch -f buttercup-run-discover
