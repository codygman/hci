#!/usr/bin/env sh
set -o errexit

# nix install
# TODO use a pinned version
curl -L https://nixos.org/nix/install | sh
[ ! -f ~/.nix-profile/etc/profile.d/nix.sh ] || . ~/.nix-profile/etc/profile.d/nix.sh
ln -rs "$TRAVIS_BUILD_DIR/nixpkgs" ~/.config/nixpkgs

nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update

export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
# remove zshrc and bashrc so home-manager can overwrite them
# TODO add this into bootstrap.hs and only do this on travis?
[ ! -f ~/.bashrc ] || rm -v ~/.bashrc
[ ! -f ~/.profile ] || rm -v ~/.profile
[ ! -f ~/.bash_profile ] || rm -v ~/.bash_profile
[ ! -f ~/.ssh/config ] || rm -v ~/.ssh/config
nix-shell '<home-manager>' -A install

[ -x "$(command -v home-manager)" ] || echo "home-manager not installed or not in PATH"; exit 1;
[ -x "$(command -v cachix)" ] || echo "cachix failed not installed or not in PATH"; exit 1;
[ -x "$(command -v emacs)" ] || echo "emacs failed not installed or not in PATH"; exit 1;

echo "configure machine to use cachix"
cachix use codygman5

