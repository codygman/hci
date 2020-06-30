#!/usr/bin/env bash
set -o errexit

nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update
nix-shell '<home-manager>' -A install


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

check_installed "emacs"

. "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
echo "nix profile bin"
ls $HOME/.nix-profile/bin

export PATH=$HOME/.nix-profile/bin:$PATH
