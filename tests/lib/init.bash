export CONFIG_DIR=$TEMP_DIR/etc
export PROFILES_DIR=$CONFIG_DIR/profile.d
export DEFAULTS_FILE=$CONFIG_DIR/defaults.conf

export BTRFS_SNAPSHOTS_CONFIG_DIR=$CONFIG_DIR

export SELF_NAME=test
export TIMESTAMP=2001-01-01T00:00:00Z

source ./tests/lib/assert.bash
source ./tests/lib/timestamp.bash
