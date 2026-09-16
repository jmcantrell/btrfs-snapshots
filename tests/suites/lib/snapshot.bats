source ./tests/lib/init.bash

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
    local snapshot
    while read -r timestamp; do
        snapshot=$BATS_TEST_TMPDIR/$timestamp
        expected+=("$snapshot")
        mkdir -p -- "$snapshot"
    done < <(timestamp_seq "$TIMESTAMP" hour 24)

    run -0 print_snapshots "$BATS_TEST_TMPDIR"
    printf "%s\n" "${expected[@]}" | assert_output -
}

@test "print_snapshots ignores anything that does not look like a snapshot" {
    # Paths that should not be printed:
    touch -- "$BATS_TEST_TMPDIR"/foo                 # incorrectly named file
    touch -- "$BATS_TEST_TMPDIR/$TIMESTAMP"          # correctly named file
    mkdir -p -- "$BATS_TEST_TMPDIR"/bar/"$TIMESTAMP" # correctly named nested directory

    run -0 print_snapshots "$BATS_TEST_TMPDIR"
    refute_output
}
