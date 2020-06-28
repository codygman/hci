#!/usr/bin/env bash

echo "before: \n$PATH"
if [ -f "$HOME/.nix-profile/etc/profile.d/nix.sh" ]; then
    echo "sourcing"
    . ~/.nix-profile/etc/profile.d/nix.sh
    export NIX_PATH=$HOME/.nix-defexpr/channels${NIX_PATH:+:}$NIX_PATH
fi
# echo "after: \n$PATH"
home-manager switch
# echo "running emacs: $(which emacs)"
EMACSFOR="PERSONAL" emacs -nw --load load-init-then-run-ert.el
cat test-results.txt
if [ -f "test-results.txt" ]; then
    rm test-results.txt
fi
