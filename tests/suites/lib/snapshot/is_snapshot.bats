source ./tests/lib/init.bash
source ./lib/init.bash

export BATS_TEST_NAME_PREFIX='is_snapshot '

setup() {
    snapshot=$BATS_TEST_TMPDIR/$TIMESTAMP
    not_a_snapshot=$BATS_TEST_TMPDIR/bogus
}

assert_result() {
    local return_status=${1:?missing return status}
    shift

    run -"$return_status" is_snapshot "$@"
    refute_output
}

assert_is() {
    assert_result 0 "$@"
}

assert_is_not() {
    assert_result 1 "$@"
}

@test "identifies correctly named directories" {
    mkdir -p -- "$snapshot"
    assert_is "$snapshot"
}

@test "does not identify incorrectly named non-existent paths" {
    assert_is_not "$not_a_snapshot"
}

@test "does not identify incorrectly named files" {
    touch -- "$not_a_snapshot"
    assert_is_not "$not_a_snapshot"
}

@test "does not identify incorrectly named directories" {
    mkdir -p -- "$not_a_snapshot"
    assert_is_not "$not_a_snapshot"
}

@test "does not identify correctly named non-existent paths" {
    assert_is_not "$snapshot"
}

@test "does not identify correctly named files" {
    touch -- "$snapshot"
    assert_is_not "$snapshot"
}
