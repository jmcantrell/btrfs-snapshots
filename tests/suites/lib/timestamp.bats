source ./tests/lib/init.bash

source ./lib/timestamp.bash

export BATS_TEST_NAME_PREFIX='lib/timestamp::'

assert_result() {
    local return_status=${1:?missing return status}
    shift

    run -"$return_status" is_timestamp "$@"
    refute_output
}

assert_is() {
    assert_result 0 "$@"
}

assert_is_not() {
    assert_result 1 "$@"
}

@test "is_timestamp accepts timestamps in utc zulu format" {
    assert_is "$TIMESTAMP"
}

@test "is_timestamp rejects nonsense" {
    assert_is_not bogus
}

@test "is_timestamp rejects date strings" {
    assert_is_not now
    assert_is_not tomorrow
    assert_is_not yesterday
}

@test "is_timestamp rejects valid but improperly formatted dates" {
    assert_is_not "$(date)"
}

@test "is_timestamp rejects utc date not in zulu format" {
    assert_is_not 2000-01-01T00:00:00+00:00
}

@test "is_timestamp rejects invalid utc zulu formatted date" {
    assert_is_not 0000-00-00T00:00:00Z
}

assert_valid() {
    run -0 is_timestamp "$@"
    refute_output
}

@test "timestamp prints a date in the correct format" {
    assert_valid "$(timestamp)"
}

@test "timestamp passes its arguments to \`date\`" {
    assert_valid "$(timestamp --date="today - 1 year")"
}

@test "timestamp rejects an invalid date" {
    run ! timestamp --date="0000-00-00T00:00:00Z"
}
