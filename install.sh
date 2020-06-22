# nix upgrade-nix

nix-channel --add https://github.com/rycee/home-manager/archive/master.tar.gz home-manager
nix-channel --update
export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH

# remove zshrc and bashrc so home-manager can overwrite them
# TODO add this into bootstrap.hs and only do this on travis?
FILE=~/.bashrc [[ -f $FILE ]] | rm -v "$FILE"
FILE=~/.zshrc [[ -f $FILE ]] | rm -v "$FILE"
home-manager switch
