#!/usr/bin/env bash

if ! [ -x "$(command -v curl)" ]; then
  echo "curl not installed, installing"
  sudo apt install -y curl
fi

if ! [ -x "$(command -v nix-shell)" ]; then
  echo "nix not installed, installing"
  curl -L https://nixos.org/nix/install | sh
fi

. $HOME/.nix-profile/etc/profile.d/nix.sh

sed -i 's/someuser/$USER/g' home.nix
mkdir -pv ~/.config/nixpkgs/
cp -bv home.nix ~/.config/nixpkgs/home.nix

if ! [ -x "$(command -v home-manager)" ]; then
  echo "home-manager not installed, installing"
  nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
  nix-channel --update
  nix-shell '<home-manager>' -A install
fi

home-manager switch
code --install-extension digitalassetholdingsllc.ghcide
code --install-extension rubymaniac.vscode-direnv
code --install-extension bbenoist.Nix

echo ""
echo ""

echo "WARNING: This could take a while (especially if you get cache misses and build from source)"
echo "make sure lorri is stopped"
systemctl --user stop lorri
echo "remove lorri and direnv caches"
rm -rf ~/.local/share/direnv/
rm -rf ~/.cache/lorri/

echo ""
echo "use binary caches"
cachix use iohk
cachix use itprotv-codygman-test

cd ../../
echo "we should be in smurf's root directory, we are in: $(pwd)"
echo "WARNING: If you see lots of 'building X...' and not 'fetching' or 'downloading' your cache might be misconfigured"
nix build --show-trace
nix-shell
exit

echo "running lorri shell (Aside from lorri-level caching, this should basically be a no-op)"
lorri shell
exit

echo "don't forget to Add the appropriate shell hook for direnv to work (see smurf/nix/README.md)"
