source ./tests/lib/init.bash
source ./lib/init.bash

export BATS_TEST_NAME_PREFIX='is_same_event '

assert_result() {
    local return_status=${1:?missing return status}
    shift

    run -"$return_status" is_same_event "$@"
    refute_output
}
assert_same() {
    assert_result 0 "$@"
}

assert_different() {
    assert_result 1 "$@"
}

assert_bounds() {
    local event_name=${1:?missing event name}
    local event_start=${2:?missing event start}
    local event_stop=${3:?missing event stop}

    # Ensure a tiny step before the event window is considered a different event.
    assert_different "$event_name" "$event_start" "$(timestamp -d "$event_start - 1 second")"

    # Ensure a tiny step after the event window is considered a different event.
    assert_different "$event_name" "$event_stop" "$(timestamp -d "$event_stop + 1 second")"
}

assert_range() {
    local event_name=${1:?missing event name}
    local event_start=${2:?missing event start}
    local event_stop=${3:?missing event stop}
    local increment=${4:?missing increment}

    local timestamp
    while read -r timestamp; do
        assert_same "$event_name" "$event_start" "$timestamp"
    done < <(timestamp_range "$event_start" "$event_stop" "$increment")
}

@test "recognizes a timestamp from the same yearly event" {
    local event_start event_stop
    event_start=$(timestamp -d "$TIMESTAMP + $((RANDOM % 15)) year")
    event_stop=$(timestamp -d "$event_start + 1 year - 1 second")

    # Ensure a tiny step outside of the year is considered a different event.
    assert_bounds yearly "$event_start" "$event_stop"

    # Ensure every month of the year is considered the same event.
    assert_range yearly "$event_start" "$event_stop" '1 month'
}

@test "recognizes a timestamp from the same quarterly event" {
    local event_start event_stop
    event_start=$(timestamp -d "$TIMESTAMP + $((RANDOM % 4 * 3)) month")
    event_stop=$(timestamp -d "$event_start + 3 months - 1 second")

    # Ensure a tiny step outside of the quarter is considered a different event.
    assert_bounds quarterly "$event_start" "$event_stop"

    # Ensure every month of the quarter is considered the same event.
    assert_range quarterly "$event_start" "$event_stop" '1 month'

    # Ensure different years with the same quarter number do not appear as the same event.
    assert_different quarterly 2000-01-01T00:00:00Z 2001-01-01T00:00:00Z
}

@test "recognizes a timestamp from the same monthly event" {
    local event_start event_stop
    event_start=$(timestamp -d "$TIMESTAMP + $((RANDOM % 12)) month")
    event_stop=$(timestamp -d "$event_start + 1 month - 1 second")

    # Ensure a tiny step outside of the month is considered a different event.
    assert_bounds monthly "$event_start" "$event_stop"

    # Ensure every day of the month is considered the same event.
    assert_range monthly "$event_start" "$event_stop" '1 day'
}

@test "recognizes a timestamp from the same weekly event" {
    # Need to pick a start date that is the first monday of a year.
    local timestamp='2000-01-03T00:00:00Z'

    local event_start event_stop
    event_start=$(timestamp -d "$timestamp + $((RANDOM % 52)) weeks")
    event_stop=$(timestamp -d "$event_start + 1 week - 1 second")

    # Ensure a tiny step outside of the week is considered a different event.
    assert_bounds weekly "$event_start" "$event_stop"

    # Ensure every day of the week is considered the same event.
    assert_range weekly "$event_start" "$event_stop" '1 day'

    # Ensure adjacent years with the same week number appear as the same event.
    assert_same weekly 1999-12-31T00:00:00Z 2000-01-01T23:00:00Z

    # Ensure non-adjacent years with the same week number do not appear as the same event.
    assert_different weekly 2000-01-03T00:00:00Z 2002-01-01T00:00:00Z
}

@test "recognizes a timestamp from the same daily event" {
    local event_start event_stop
    event_start=$(timestamp -d "$TIMESTAMP + $((RANDOM % 31)) days")
    event_stop=$(timestamp -d "$event_start + 24 hours - 1 second")

    # Ensure a tiny step outside of the day is considered a different event.
    assert_bounds daily "$event_start" "$event_stop"

    # Ensure every hour of the day is considered the same event.
    assert_range daily "$event_start" "$event_stop" '1 hour'
}

@test "recognizes a timestamp from the same hourly event" {
    local event_start event_stop
    event_start=$(timestamp -d "$TIMESTAMP + $((RANDOM % 24)) hours")
    event_stop=$(timestamp -d "$event_start + 1 hour - 1 second")

    # Ensure a tiny step outside of the hour is considered a different event.
    assert_bounds hourly "$event_start" "$event_stop"

    # Ensure every minute of the hour is considered the same event.
    assert_range hourly "$event_start" "$event_stop" '1 minute'
}

@test "recognizes a timestamp from the same minutely event" {
    local event_start event_stop
    event_start=$(timestamp -d "$TIMESTAMP + $((RANDOM % 60)) minutes")
    event_stop=$(timestamp -d "$event_start + 1 minute - 1 second")

    # Ensure a tiny step outside of the minute is considered a different event.
    assert_bounds minutely "$event_start" "$event_stop"

    # Ensure every second of the minute is considered the same event.
    assert_range minutely "$event_start" "$event_stop" '1 second'
}
