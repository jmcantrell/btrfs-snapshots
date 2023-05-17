export TIMESTAMP_FORMAT="%Y-%m-%dT%H:%M:%SZ"
export TIMESTAMP_PATTERN="^[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z"

timestamp() {
    date --utc "$@" +"$TIMESTAMP_FORMAT"
}

is_timestamp() {
    local input=$1

    # Ensure input is formatted correctly.
    if [[ ! $input =~ $TIMESTAMP_PATTERN ]]; then
        return 1
    fi

    # Ensure input is a valid date.
    if ! date --utc --date="$input" &>/dev/null; then
        return 1
    fi
}

timestamp_cmp() {
    local s1 s2
    s1=$(date --utc --date="$1" +%s) || return 1
    s2=$(date --utc --date="$2" +%s) || return 1

    local result
    if ((s1 < s2)); then
        result="-1"
    elif ((s1 > s2)); then
        result="1"
    else
        result="0"
    fi

    printf "%s" "$result"
}

timestamp_eq() {
    local cmp
    cmp=$(timestamp_cmp "$@") || return 1
    ((cmp == 0))
}

timestamp_neq() {
    local cmp
    cmp=$(timestamp_cmp "$@") || return 1
    ((cmp != 0))
}

timestamp_lt() {
    local cmp
    cmp=$(timestamp_cmp "$@") || return 1
    ((cmp == -1))
}

timestamp_lte() {
    local cmp
    cmp=$(timestamp_cmp "$@") || return 1
    ((cmp == -1 || cmp == 0))
}

timestamp_gt() {
    local cmp
    cmp=$(timestamp_cmp "$@") || return 1
    ((cmp == 1))
}

timestamp_gte() {
    local cmp
    cmp=$(timestamp_cmp "$@") || return 1
    ((cmp == 1 || cmp == 0))
}
