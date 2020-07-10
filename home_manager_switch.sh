#!/usr/bin/env bash
set -o errexit

export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
export PATH=$HOME/.nix-profile/bin:$PATH
export HCI_DIR=/home/runner/work/hci/hci

rm -rv ~/.config/nixpkgs
ln -sv "$HCI_DIR/nixpkgs" /home/runner/.config/nixpkgs

# remove zshrc and bashrc so home-manager can overwrite them
# TODO add this into bootstrap.hs and only do this on CI?
[[ ! -f ~/.bashrc ]] || rm -v ~/.bashrc
[[ ! -f ~/.zshrc ]] || rm -v ~/.zshrc
[[ ! -f ~/.bash_profile ]] || rm -v ~/.bash_profile
[[ ! -f ~/.profile ]] || rm -v ~/.profile

function check_installed() {
    echo "checking we have $1"
    if [ -x "$(command -v $1)" ]; then
	echo ""
	echo "=================================================="
        echo "$1 installed, moving on"
	echo "=================================================="
	echo ""
    else
        echo "$1 not installed or not in PATH";
	echo "~/.config/nixpkgs/home.nix looks like: "
	cat ~/.config/nixpkgs/home.nix
	echo "PATH is:"
	echo "$PATH"
	exit 1;
    fi
}

export PATH=$HOME/.nix-profile/bin:$PATH
# NOTE this is okay for now I think
# TODO eventually change this to use switch.sh (or hs if we change to it) and remove all the symlinking above/elsewhere
# NOTE be sure to look for other places that might assume those nixpkgs symlinks are present, but I can't think of any right now
home-manager switch
. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"

check_installed "emacs"
