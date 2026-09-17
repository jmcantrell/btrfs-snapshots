source ./tests/lib/init.bash
source ./tests/lib/timestamp.bash

source ./lib/snapshot.bash
source ./lib/timestamp.bash

export BATS_TEST_NAME_PREFIX='lib/snapshot::'

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

@test "is_snapshot identifies correctly named directories" {
    mkdir -p -- "$snapshot"
    assert_is "$snapshot"
}

@test "is_snapshot does not identify incorrectly named non-existent paths" {
    assert_is_not "$not_a_snapshot"
}

@test "is_snapshot does not identify incorrectly named files" {
    touch -- "$not_a_snapshot"
    assert_is_not "$not_a_snapshot"
}

@test "is_snapshot does not identify incorrectly named directories" {
    mkdir -p -- "$not_a_snapshot"
    assert_is_not "$not_a_snapshot"
}

@test "is_snapshot does not identify correctly named non-existent paths" {
    assert_is_not "$snapshot"
}

@test "is_snapshot does not identify correctly named files" {
    touch -- "$snapshot"
    assert_is_not "$snapshot"
}

@test "print_snapshots prints timestamped directories at the top level" {
    local timestamp
    while read -r timestamp; do
        mkdir -p -- "$BATS_TEST_TMPDIR/$timestamp"
        printf "%s\n" "$BATS_TEST_TMPDIR/$timestamp"
    done < <(timestamp_seq "$TIMESTAMP" hour $((RANDOM % 10 + 2))) >"$BATS_TEST_TMPDIR"/output

    run -0 print_snapshots "$BATS_TEST_TMPDIR"
    assert_output - <"$BATS_TEST_TMPDIR"/output
}

@test "print_snapshots ignores anything that does not look like a snapshot" {
    # Paths that should not be printed:
    touch -- "$BATS_TEST_TMPDIR"/foo                 # incorrectly named file
    touch -- "$BATS_TEST_TMPDIR/$TIMESTAMP"          # correctly named file
    mkdir -p -- "$BATS_TEST_TMPDIR"/bar/"$TIMESTAMP" # correctly named nested directory

    run -0 print_snapshots "$BATS_TEST_TMPDIR"
    refute_output
}
