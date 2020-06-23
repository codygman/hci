#!/usr/bin/env sh

set -o errexit

# nix install, TODO use
curl -L https://nixos.org/nix/install | sh

ln -rs ~/hci/nixpkgs ~/.config/nixpkgs

nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update
export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
nix-shell '<home-manager>' -A install

[ -x "$(command -v home-manager)" ] || echo "home-manager failed to install"; exit 1;
[ -x "$(command -v cachix)" ] || echo "cachix failed to install"; exit 1;

echo "configure machine to use cachix"
cachix use codygman5



# remove zshrc and bashrc so home-manager can overwrite them
# TODO add this into bootstrap.hs and only do this on travis?
rm -v ~/.bashrc
rm -v ~/.zshrc

# install home-manager
./bootstrap.hs
