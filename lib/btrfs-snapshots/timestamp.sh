export EVENT_NAMES=(minutely hourly daily weekly monthly quarterly yearly)
export TIMESTAMP_FORMAT=%Y-%m-%dT%H:%M:%SZ

digit="[0-9]"
digit2="$digit{2}"
digit4="$digit{4}"

TIMESTAMP_PATTERN="^${TIMESTAMP_FORMAT//%Y/$digit4}$"

for placeholder in %m %d %H %M %S; do
    TIMESTAMP_PATTERN=${TIMESTAMP_PATTERN//$placeholder/$digit2}
done

unset digit digit2 digit4 placeholder

get_timestamp() {
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

    case $event_name in
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

    if ((s1 < s2)); then
        echo -1
    elif ((s1 > s2)); then
        echo 1
    else
        echo 0
    fi
}
