#! /usr/bin/env bash

nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update

if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
  echo "sourcing nix daemon"
  . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
fi

# remove zshrc and bashrc so home-manager can overwrite them
# TODO add this into bootstrap.hs and only do this on travis?
[[ ! -f ~/.bashrc ]] || rm -v ~/.bashrc
[[ ! -f ~/.zshrc ]] || rm -v ~/.zshrc
home-manager switch
emacs -batch -f buttercup-run-discover
