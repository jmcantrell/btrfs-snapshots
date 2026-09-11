source ./tests/lib/init.bash
source ./lib/init.bash

export BATS_TEST_NAME_PREFIX='is_timestamp '

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

@test "accepts timestamps in utc zulu format" {
    assert_is "$TIMESTAMP"
}

@test "rejects nonsense" {
    assert_is_not bogus
}

@test "rejects date strings" {
    assert_is_not now
    assert_is_not tomorrow
    assert_is_not yesterday
}

@test "rejects valid but improperly formatted dates" {
    assert_is_not "$(date)"
}

@test "rejects utc date not in zulu format" {
    assert_is_not 2000-01-01T00:00:00+00:00
}

@test "rejects invalid utc zulu formatted date" {
    assert_is_not 0000-00-00T00:00:00Z
}
