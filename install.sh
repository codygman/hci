#!/usr/bin/env bash


if [ -z "$CACHIX_SIGNING_KEY" ]; then
    echo "CACHIX_SIGNING_KEY not set, failing NOW!";
    exit 1
fi
   


function check_installed() {
    echo "checking we have $1"
    if [ -x "$(command -v $1)" ]; then
        echo "$1 installed, moving on"
    else
        echo "$1 not installed or not in PATH"; exit 1;
    fi
}

# nix install
# TODO use a pinned version
curl -L https://nixos.org/nix/install | sh

if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    echo "sourcing nix.sh";
    . ~/.nix-profile/etc/profile.d/nix.sh
else
    echo "nix.sh doesn't exist, not sourcing"
fi

nix-env -iA cachix -f https://cachix.org/api/v1/install
check_installed "cachix"
echo "configure machine to use cachix"
cachix use codygman6
echo "start cachix push watcher for nix store, logging to nohup.out"
nohup cachix push --watch-store codygman6 &
sleep 2

echo "cachix watcher update"
cat nohup.out

nix-env -iA nixpkgs.hello

sleep 20

echo "cachix watcher update"
cat nohup.out

ln -rs "$TRAVIS_BUILD_DIR/nixpkgs" ~/.config/nixpkgs

nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update

export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
# remove zshrc and bashrc so home-manager can overwrite them
# TODO add this into bootstrap.hs and only do this on travis?
[ -f "$HOME/.bashrc" ]       && rm -v "$HOME/.bashrc"       || echo "$HOME/.bashrc doesn't exist"
[ -f "$HOME/.profile" ]      && rm -v "$HOME/.profile"      || echo "$HOME/.profile doesn't exist"
[ -f "$HOME/.bash_profile" ] && rm -v "$HOME/.bash_profile" || echo "$HOME/.bash_profile doesn't exist"
[ -f "$HOME/.ssh/config" ]   && rm -v "$HOME/.ssh/config"   || echo "$HOME/.ssh/config doesn't exist"


echo "installing home manager"
nix-shell '<home-manager>' -A install
echo "done installing home manager"

check_installed "home-manager"

check_installed "emacs"


echo "linking emacs setup"
ln -rs "$TRAVIS_BUILD_DIR/" "$HOME/.emacs.d"

echo "we are using this bash: "
echo "path: $(which bash)"
echo "version:"
bash --version
bash test.sh
bash extra.sh
