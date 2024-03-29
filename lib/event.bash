# For the purposes of this project, the term "event" is defined as the set of
# all timestamps that share the same timestamp parts, where the parts are
# determined based on the type of event, e.g. yearly, monthly, daily, etc.
#
# For example, an hourly event is the set of all timestamps that share the same
# year, month, day, and hour. The following timestamps are part of the same
# hourly event because they happen during the same hour:
#
#   2001-01-02T12:00:00Z
#   2001-01-02T12:34:56Z
#   2001-01-02T12:59:59Z
#
# However, the same event would not contain the following timestamps, even
# though they occur in close proximity:
#
#   2001-01-02T11:59:59Z (from the previous hourly event)
#   2001-01-02T13:00:00Z (from the next hourly event)
#
# Weekly events have to be handled specially, though.
#
# Since weeks commonly span adjacent years, we have to employ the concept of an
# ISO week and year number, which has the same values for every date and time
# that occur within the same logical week, regardless of whether or not the
# dates occur in different actual years.

export EVENT_NAMES=(minutely hourly daily weekly monthly quarterly yearly)

is_same_event() {
    local event_name=${1:?missing event name}

    local timestamps=(
        "${2:?missing first timestamp}"
        "${3:?missing second timestamp}"
    )

    local parts
    case ${event_name,,} in
    yearly) parts=(Y) ;;           # year
    quarterly) parts=(Y q) ;;      # year quarter
    monthly) parts=(Y m) ;;        # year month
    weekly) parts=(G V) ;;         # year and week number (ISO)
    daily) parts=(Y m d) ;;        # year month day
    hourly) parts=(Y m d H) ;;     # year month day hour
    minutely) parts=(Y m d H M) ;; # year month day hour minute
    esac

    local format=${parts[*]/#/%}

    local timestamp events=()
    for timestamp in "${timestamps[@]}"; do
        events+=("$(date --utc --date="$timestamp" +"$format")") || return 1
    done

    [[ ${events[0]} == "${events[1]}" ]]
}
