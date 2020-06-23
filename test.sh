#!/usr/bin/env sh
set -euo

emacs -batch -f package-initialize -L . -f buttercup-run-discover
