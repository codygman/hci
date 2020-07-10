#!/usr/bin/env bash

# TODO check that we're actually on nixos, otherwise throw an error

# TODO update nixos to use home-manager module for this script to actually sync the state of the system
# This will be useful to ensure both my system level and user (or home) level states are in sync
if grep -q "NixOS" /etc/issue; then
    echo "we are on nixos; calling nixos-rebuild and assuming home-manager module enabled"
    NIXOS_CONFIG=$(pwd)/nixpkgs/configuration.nix sudo -E nixos-rebuild switch
else
    echo "we are not on nixos, calling home-manager switch"
    home-manager switch
fi
