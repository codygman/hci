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

echo "what does nixpkgs look like before home-manager install?"
ls -larth /home/runner/.config/nixpkgs
echo "this should be same:"
ls -larth ~/.config/nixpkgs
nix-shell '<home-manager>' -A install

echo "realpath of nixpkgs before ln: $(realpath ~/.config/nixpkgs)"
ln -rs "$TRAVIS_BUILD_DIR/nixpkgs" ~/.config/nixpkgs
echo "ls of nixpkgs after ln: "
ls ~/.config/nixpkgs
echo "realpath of nixpkgs before install: $(realpath ~/.config/nixpkgs)"

home-manager switch

check_installed "emacs"

. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
echo "nix profile bin"
ls $HOME/.nix-profile/bin

# remove zshrc and bashrc so home-manager can overwrite them
# TODO add this into bootstrap.hs and only do this on travis?
[[ ! -f ~/.bashrc ]] || rm -v ~/.bashrc
[[ ! -f ~/.zshrc ]] || rm -v ~/.zshrc
home-manager switch
emacs -batch -f buttercup-run-discover
