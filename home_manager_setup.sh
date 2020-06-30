#!/usr/bin/env bash
set -o errexit


. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
echo "nix profile bin"
ls $HOME/.nix-profile/bin

export PATH=$HOME/.nix-profile/bin:$PATH

nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
