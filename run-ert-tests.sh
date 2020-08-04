#!/usr/bin/env bash

echo "running emacs with xvfb-run at: $(date)"
xvfb-run -e xvfb-error.log emacs --load load-init-then-run-ert.el
echo "finish running emacs at: $(date)"
emacsExitCode=$?;
echo "emacs exit code will be: $emacsExitCode"

echo "xvfb-run error file contents:"
cat xvfb-error.log

if [ -f "test-results.txt" ]; then
    echo "ert test results:"
    cat test-results.txt
    rm -v test-results.txt
elif [ "$TERM" != "dumb" ]; then
    echo "test-results.txt not present, did ert tests run?"
    echo "IN_GIT_HOOK is $IN_GIT_HOOK"
fi

exit $emacsExitCode
