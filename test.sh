#!/usr/bin/env bash

home-manager switch
# echo "running emacs: $(which emacs)"
# Before running tests, clean the stack directory for our haskell test project
pushd testdata/simple-haskell-project && stack clean && popd
EMACSFOR="PERSONAL" emacs -nw --load load-init-then-run-ert.el
emacsExitCode=$?;
cat test-results.txt
echo "github env vars: "
env | grep -i git
exit $emacsExitCode;
if [ -f "test-results.txt" ]; then
    rm test-results.txt
fi
