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

    [[ $(date -ud "$timestamp1" +"$format") == $(date -ud "$timestamp2" +"$format") ]]
}

timestamp_compare() {
    local s1 s2
    s1=$(date --utc --date="$1" +%s)
    s2=$(date --utc --date="$2" +%s)

    local result
    if ((s1 < s2)); then
        result="-1"
    elif ((s1 > s2)); then
        result="1"
    else
        result="0"
    fi

    printf "%s\n" "$result"
}
