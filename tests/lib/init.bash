export SELF_NAME=test

export LIB_DIR=$PWD/lib
export CONFIG_DIR=$TEMP_DIR/etc
export PROFILES_DIR=$CONFIG_DIR/profile.d
export DEFAULTS_FILE=$CONFIG_DIR/defaults.conf

export BTRFS_SNAPSHOTS_LIB_DIR=$LIB_DIR
export BTRFS_SNAPSHOTS_CONFIG_DIR=$CONFIG_DIR

export TIMESTAMP=2001-01-01T00:00:00Z

source ./tests/lib/assert.bash
source ./tests/lib/timestamp.bash

source ./lib/init.bash
