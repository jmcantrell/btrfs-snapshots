#!/usr/bin/env bash

set -eu

trap 'kill $$' INT

while sleep 0.1; do
    find . -type f | entr -acd ./test.sh "$@" || continue
done
