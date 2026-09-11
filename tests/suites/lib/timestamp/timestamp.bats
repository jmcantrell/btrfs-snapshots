source ./tests/lib/init.bash
source ./lib/init.bash

export BATS_TEST_NAME_PREFIX='timestamp '

assert_valid() {
    run -0 is_timestamp "$@"
    refute_output
}

@test "prints a date in the correct format" {
    assert_valid "$(timestamp)"
}

@test "passes its arguments to \`date\`" {
    assert_valid "$(timestamp --date="today - 1 year")"
}

@test "rejects an invalid date" {
    run ! timestamp --date="0000-00-00T00:00:00Z"
}
