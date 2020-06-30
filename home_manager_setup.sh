#!/usr/bin/env bash
set -o errexit

export PATH=$HOME/.nix-profile/bin:$PATH

nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install
