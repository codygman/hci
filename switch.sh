#!/usr/bin/env bash
home-manager -f nixpkgs/home.nix switch

# TODO check that we're actually on nixos, otherwise throw an error
# TODO move to home-manager via nixos module once I iron out how to handle differences between machines like
# - wifi/ethernet network names
# - has or doesn't have wireless support
# - more things I haven't ran into yet
# if [ -z "$IN_GIT_HOOK" ] && [ -z "$INSIDE_EMACS" ]; then
#     if grep -q "NixOS" /etc/issue; then
# 	echo "we are on nixos; calling nixos-rebuild and assuming home-manager module enabled"
# 	# TODO avoid needing sudo here by using nix-build directly, NOTE subsequent calls will somehow need to use the result symlink it generates
# 	NIXOS_CONFIG=$(pwd)/nixpkgs/configuration.nix sudo -E nixos-rebuild switch
#     else
# 	echo "we are not on nixos, calling home-manager switch"
# 	home-manager -f nixpkgs/home.nix switch
#     fi
# else
#     # TODO when we move to nixos-rebuild build/update commands to use that env we don't have to use home-manager here
#     # and it will result in a more reproducible environment
#     echo "in git hook, just running home-manager switch"
#     home-manager -f nixpkgs/home.nix switch
# fi
