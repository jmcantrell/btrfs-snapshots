export EVENT_NAMES=(minutely hourly daily weekly monthly quarterly yearly)
export TIMESTAMP_FORMAT="%Y-%m-%dT%H:%M:%SZ"
export TIMESTAMP_PATTERN="^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z"

. "$LIB_DIR"/action.bash
. "$LIB_DIR"/config.bash
. "$LIB_DIR"/event.bash
. "$LIB_DIR"/locale.bash
. "$LIB_DIR"/snapshot.bash
. "$LIB_DIR"/timestamp.bash
