#!/usr/bin/env bash
set -o errexit

exit 1

home-manager switch
# echo "running emacs: $(which emacs)"
# Before running tests, clean the stack directory for our haskell test project
pushd testdata/simple-haskell-project && stack clean && popd
EMACSFOR="PERSONAL" emacs -batch -f package-initialize -L . -f buttercup-run-discover
emacsExitCode=$?;

if [ -z "$GITHUB_ACTIONS" ]; then
    exit $emacsExitCode;
fi
if [ -f "test-results.txt" ]; then
    cat test-results.txt
    rm test-results.txt
fi
