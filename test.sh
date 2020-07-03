#!/usr/bin/env bash

home-manager switch
# echo "running emacs: $(which emacs)"
# Before running tests, clean the stack directory for our haskell test project
pushd testdata/simple-haskell-project && stack clean && popd

echo "run buttercup tests"
EMACSFOR="PERSONAL" emacs -Q -f package-initialize  --load load-init-then-test.el -batch --debug-init
buttercupExitCode=$?;

if [ $buttercupExitCode -ne 0 ]; then
    exit $buttercupExitCode;
fi

# if this is github actions, we want to run this in it's own block for more granular timing info
# if not, we're running it locally and just want to run it
if [ -z "$GITHUB_ACTIONS" ]; then
    echo "We are running locally, running ert tests..."
    bash run-ert-tests.sh
else 
    echo "in github action, ert tests will be run directly"
fi
