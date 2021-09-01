#!/usr/bin/env bash

set -eu

export LIB_DIR=$PWD/lib
export TESTS_LIB_DIR=$PWD/tests/lib

export PATH=$PWD/tests/bin:$PWD/bin:$PATH

export BTRFS_SNAPSHOTS_LIB_DIR=$LIB_DIR
export BTRFS_SNAPSHOTS_BYPASS_IS_MOUNTED=1

# Set these to something that doesn't exist, so they're not read from the system.
export BTRFS_SNAPSHOTS_PROFILES_DIR=
export BTRFS_SNAPSHOTS_DEFAULTS_FILE=

run_test() {
    local file=$1

    if [[ -v TESTS_VERBOSE ]]; then
        echo "Running test: $file"
    fi
    
    if ! "$file"; then
        echo "Test failed: $file" >&2
        return 1
    fi
}

export -f run_test

find ./tests/{unit,integration} -type f -executable "$@" -print0 |
    parallel -j0 -0 run_test
