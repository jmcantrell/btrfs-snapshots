# A sensible runtime timestamp.
# Also a convenient starting point for all event types.
export TIMESTAMP=2001-01-01T00:00:00Z

TEMP_DIR=$(mktemp -d -t "${0##*/}.XXXXXXXXX")
export TEMP_DIR

export CONFIG_DIR=$TEMP_DIR/etc

export BTRFS_SNAPSHOTS_CONFIG_DIR=$CONFIG_DIR
export BTRFS_SNAPSHOTS_LIB_DIR=$LIB_DIR
export BTRFS_SNAPSHOTS_TIMESTAMP=$TIMESTAMP

. "$TESTS_LIB_DIR"/assert.bash
. "$TESTS_LIB_DIR"/debug.bash
. "$TESTS_LIB_DIR"/locale.bash
. "$TESTS_LIB_DIR"/temp.bash
. "$TESTS_LIB_DIR"/timestamp.bash
