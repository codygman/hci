#! /usr/bin/env bash

set -o errexit

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
	exit 1;
    fi
}


nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update

export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
export PATH=$HOME/.nix-profile/bin:$PATH
export HCI_DIR=/home/runner/work/hci/hci/

ln -sv "$HCI_DIR/nixpkgs" /home/runner/.config/nixpkgs

echo ""
echo ""
echo "all folders of ~/.config/nixpkgs "
ls -larth -R ~/.config/nixpkgs/
echo ""
echo ""
echo ""
echo ""
echo "cat of ~/.config/nixpkgs/home.nix"
cat cat of ~/.config/nixpkgs/home.nix
echo ""
echo ""

nix-shell '<home-manager>' -A install

check_installed "emacs"

. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
echo "nix profile bin"
ls $HOME/.nix-profile/bin

# remove zshrc and bashrc so home-manager can overwrite them
# TODO add this into bootstrap.hs and only do this on CI?
[[ ! -f ~/.bashrc ]] || rm -v ~/.bashrc
[[ ! -f ~/.zshrc ]] || rm -v ~/.zshrc
home-manager switch
emacs -batch -f buttercup-run-discover
