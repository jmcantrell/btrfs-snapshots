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
