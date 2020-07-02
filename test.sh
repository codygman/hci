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

if [ -z "$IN_GIT_HOOK" ] && [ -z "$INSIDE_EMACS" ]; then
   echo "finished running buttercup tests, running ert tests"
   EMACSFOR="PERSONAL" emacs -nw --load load-init-then-run-ert.el
   echo "finished running ert tests"
else
    echo "in git hook, skipping ert test since we don't have TTY"
fi

emacsExitCode=$?;
echo "emacs exit code will be: $emacsExitCode"

# TODO improve git commit hooks and track with git via https://medium.com/@anandmohit7/improving-development-workflow-using-git-hooks-8498f5aa3345

if [ -f "test-results.txt" ]; then
    echo "ert test results:"
    cat test-results.txt
    rm -v test-results.txt
elif [ "$TERM" != "dumb" ]; then
    echo "test-results.txt not present, did ert tests run?"
    echo "IN_GIT_HOOK is $IN_GIT_HOOK"
fi


if [ -z "$GITHUB_ACTIONS" ]; then
    exit $emacsExitCode;
fi

