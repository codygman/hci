#!/usr/bin/env sh

# nix install
# TODO use a pinned version
curl -L https://nixos.org/nix/install | sh

if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    echo "sourcing nix.sh";
    echo "PATH before:"
    echo $PATH
    . ~/.nix-profile/etc/profile.d/nix.sh
    echo "PATH after:"
    echo $PATH
else
    echo "nix.sh doesn't exist, not sourcing"
fi

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

echo "checking we have home-manager"
if [ -x "$(command -v home-manager)" ]; then
    echo "home-manager installed, moving on"
else
    echo "home-manager not installed or not in PATH"; exit 1;
fi

nix-env -iA cachix -f https://cachix.org/api/v1/install

echo "checking we have cachix"
[ -x "$(command -v cachix)" ] && echo "cachix exists, moving on" || echo "cachix failed not installed or not in PATH";

echo "checking we have emacs"
[ -x "$(command -v emacs)" ] && echo "emacs exists, moving on" || echo "emacs failed not installed or not in PATH";

echo "configure machine to use cachix"
cachix use codygman5

echo "now trying to run emacs"
emacs -batch -f package-initialize -L . -f buttercup-run-discover
echo "done trying to run emacs"
