#!/usr/bin/env bash

echo "before: \n$PATH"
. ~/.nix-profile/etc/profile.d/nix.sh
echo "after: \n$PATH"
export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
home-manager switch
echo "running emacs: $(which emacs)"
EMACSFOR="PERSONAL" emacs -nw --load load-init-then-run-ert.el
cat test-results.txt
