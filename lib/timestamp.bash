export TIMESTAMP_FORMAT="%Y-%m-%dT%H:%M:%SZ"
export TIMESTAMP_PATTERN="^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z"

timestamp() {
    date --utc "$@" +"$TIMESTAMP_FORMAT"
}

is_timestamp() {
    local input=${1:?missing timestamp}

    # Ensure input is formatted correctly.
    [[ $input =~ $TIMESTAMP_PATTERN ]] || return

    # Ensure input is a valid date.
    date --utc --date="$input" &>/dev/null
}
