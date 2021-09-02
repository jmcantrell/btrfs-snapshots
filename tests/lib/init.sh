. "$TESTS_LIB_DIR"/io.sh
. "$TESTS_LIB_DIR"/temp.sh
. "$TESTS_LIB_DIR"/assert.sh
. "$TESTS_LIB_DIR"/message.sh
. "$TESTS_LIB_DIR"/timestamp.sh

# Make a convenient place for configuration.
export ETC_DIR=$TEMP_DIR/etc

# A sensible runtime timestamp.
# Also a convenient starting point for all event types.
export TIMESTAMP=2001-01-01T00:00:00Z

# These are the variables needed to override.
export BTRFS_SNAPSHOTS_ETC_DIR=$ETC_DIR
export BTRFS_SNAPSHOTS_LIB_DIR=$LIB_DIR
export BTRFS_SNAPSHOTS_TIMESTAMP=$TIMESTAMP
export BTRFS_SNAPSHOTS_BYPASS_IS_MOUNTED=1
