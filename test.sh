#!/usr/bin/env bash
set -o errexit

home-manager switch
# echo "running emacs: $(which emacs)"
# Before running tests, clean the stack directory for our haskell test project
pushd testdata/simple-haskell-project && stack clean && popd
EMACSFOR="PERSONAL" emacs -Q -f package-initialize  --load load-init-then-test.el -batch
emacsExitCode=$?;

# TODO improve git commit hooks and track with git via https://medium.com/@anandmohit7/improving-development-workflow-using-git-hooks-8498f5aa3345

if [ -z "$GITHUB_ACTIONS" ]; then
    exit $emacsExitCode;
fi
if [ -f "test-results.txt" ]; then
    cat test-results.txt
    rm test-results.txt
fi
