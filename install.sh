#!/usr/bin/env bash

set -o errexit

echo "github env vars"
env | grep -i github

cachix use codygman5
