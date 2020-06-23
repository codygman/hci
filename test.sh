#!/usr/bin/env sh
set -o errexit

emacs -batch -f package-initialize -L . -f buttercup-run-discover
