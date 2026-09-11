# Choose a perfect timestamp to make reasoning and arithmetic easier.
# This is the start of a year, quarter, month, week, day, hour, and second.
export TIMESTAMP=2001-01-01T00:00:00Z

timestamp_seq() {
    local timestamp=${1:?missing timestamp}
    local increment=${2:?missing increment}
    local count=${3:?missing count}

    local i
    for ((i = 0; i < count; i++)); do
        printf "%s\n" "$timestamp"
        timestamp=$(timestamp --date="$timestamp + $increment")
    done
}

timestamp_range() {
    local date_start=${1:?missing start date}
    local date_stop=${2:?missing stop date}
    local increment=${3:?missing increment}

    local timestamp_curr timestamp_stop
    timestamp_curr=$(timestamp --date="$date_start")
    timestamp_stop=$(timestamp --date="$date_stop")

    while (($(timestamp_cmp "$timestamp_curr" "$timestamp_stop") < 1)); do
        timestamp --date="$timestamp_curr"
        timestamp_curr=$(timestamp --date="$timestamp_curr $increment")
    done
}
