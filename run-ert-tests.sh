#!/usr/bin/env bash

# It seems this was never running on github actions?
# TODO make a new branch... maybe `debug-emacs-no-window-minimal` and see if there's a bug, we can figure out a work around, or just want to go full X11 server and xvfb

echo "running emacs with xvfb-run"
xvfb-run -e xvfb-error.log emacs --load load-init-then-run-ert.el
emacsExitCode=$?;
echo "emacs exit code will be: $emacsExitCode"

echo "xvfb-run error file contents:"
cat xvfb-error.log
# if [ -z "$IN_GIT_HOOK" ] && [ -z "$INSIDE_EMACS" ]; then
#     echo "finished running buttercup tests, running ert tests"
#     echo "finished running ert tests"
# else
#     echo "in git hook, skipping ert test since we don't have TTY"
# fi


# TODO improve git commit hooks and track with git via https://medium.com/@anandmohit7/improving-development-workflow-using-git-hooks-8498f5aa3345

if [ -f "test-results.txt" ]; then
    echo "ert test results:"
    cat test-results.txt
    rm -v test-results.txt
elif [ "$TERM" != "dumb" ]; then
    echo "test-results.txt not present, did ert tests run?"
    echo "IN_GIT_HOOK is $IN_GIT_HOOK"
fi

exit $emacsExitCode
