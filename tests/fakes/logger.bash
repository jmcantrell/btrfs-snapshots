#!/usr/bin/env bash

set -euo pipefail

{
    printf "fake %q" "${0##*/}"
    for arg in "$@"; do
        printf " %q" "$arg"
    done
    printf "\n"
} >&2
