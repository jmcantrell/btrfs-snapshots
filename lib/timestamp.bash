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

is_same_event() {
    local event_name=$1
    local timestamp1=$2
    local timestamp2=$3

    case ${event_name@L} in
    yearly) parts=(Y) ;;           # year
    quarterly) parts=(Y q) ;;      # year quarter
    monthly) parts=(Y m) ;;        # year month
    weekly) parts=(G V) ;;         # year and week number (ISO)
    daily) parts=(Y m d) ;;        # year month day
    hourly) parts=(Y m d H) ;;     # year month day hour
    minutely) parts=(Y m d H M) ;; # year month day hour minute
    esac

    local format=${parts[*]/#/%}

    local parts1 parts2
    parts1=$(date --utc --date="$timestamp1" +"$format") || return 1
    parts2=$(date --utc --date="$timestamp2" +"$format") || return 1

    [[ $parts1 == "$parts2" ]]
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

    printf -- "$result"
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
