#!/usr/bin/env bash

set -eu

export BIN_NAME=btrfs-snapshots
export LIB_DIR=$PWD/lib/$BIN_NAME
export TESTS_LIB_DIR=$PWD/tests/lib

export PATH=$PWD/tests/bin:$PWD/bin:$PATH

export BTRFS_SNAPSHOTS_LIB_DIR=$LIB_DIR
export BTRFS_SNAPSHOTS_CONFIG_FILE=$PWD/etc/main.conf
export BTRFS_SNAPSHOTS_PROFILE_DIR=$PWD/etc/profiles.d
export BTRFS_SNAPSHOTS_BYPASS_IS_MOUNTED=1

find ./tests/{unit,integration} -type f -executable "$@" |
    parallel -j0 'echo "running test: {}"; "{}" || echo "test failed: {}"'
