#!/usr/bin/env sh

set -o errexit

# nix install
curl -Os https://nixos.org/releases/nix/nix-2.3.6/nix-2.3.6.tar.xz
tar xfj nix-2.3.6.tar.xz
cd nix-2.3.6
./install

ln -rs ~/hci/nixpkgs ~/.config/nixpkgs

nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update
export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
# remove zshrc and bashrc so home-manager can overwrite them
# TODO add this into bootstrap.hs and only do this on travis?
[ ! -f ~/.bashrc ] || rm -v ~/.bashrc
nix-shell '<home-manager>' -A install

[ -x "$(command -v home-manager)" ] || echo "home-manager failed to install"; exit 1;
[ -x "$(command -v cachix)" ] || echo "cachix failed to install"; exit 1;

echo "configure machine to use cachix"
cachix use codygman5

