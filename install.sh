# nix upgrade-nix

nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update
# export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
# nix-env -iA cachix -f https://cachix.org/api/v1/install

# echo "configure machine to use cachix"
# cachix use codygman5

# remove zshrc and bashrc so home-manager can overwrite them
# TODO add this into bootstrap.hs and only do this on travis?
rm -v ~/.bashrc
rm -v ~/.zshrc
home-manager switch

# install home-manager
# ./bootstrap.hs
