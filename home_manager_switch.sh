#!/usr/bin/env bash
set -o errexit

export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
export PATH=$HOME/.nix-profile/bin:$PATH
export HCI_DIR=/home/runner/work/hci/hci/

ln -sv "$HCI_DIR/nixpkgs" /home/runner/.config/nixpkgs

# remove zshrc and bashrc so home-manager can overwrite them
# TODO add this into bootstrap.hs and only do this on CI?
[[ ! -f ~/.bashrc ]] || rm -v ~/.bashrc
[[ ! -f ~/.zshrc ]] || rm -v ~/.zshrc
[[ ! -f ~/.bash_profile ]] || rm -v ~/.bash_profile
[[ ! -f ~/.profile ]] || rm -v ~/.profile

home-manager switch
check_installed "emacs"

. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
export PATH=$HOME/.nix-profile/bin:$PATH
