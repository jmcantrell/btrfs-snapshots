timestamp_seq() {
    local timestamp=$1
    local increment=$2
    local count=$3

    local i
    for ((i = 0; i < count; i++)); do
        printf "%s\n" "$timestamp"
        timestamp=$(timestamp --date="$timestamp + $increment")
    done
}

timestamp_seq_event() {
    local timestamp=$1
    local event_name=$2
    local count=$3

    local increment
    case ${event_name@L} in
    minutely) increment="1 minute" ;;
    hourly) increment="1 hour" ;;
    daily) increment="1 day" ;;
    weekly) increment="7 days" ;;
    monthly) increment="1 month" ;;
    quarterly) increment="3 months" ;;
    yearly) increment="1 year" ;;
    esac

    timestamp_seq "$timestamp" "$increment" "$count"
}
