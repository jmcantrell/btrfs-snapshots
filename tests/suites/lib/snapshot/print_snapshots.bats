source ./tests/lib/init.bash
source ./lib/init.bash

export BATS_TEST_NAME_PREFIX='print_snapshots '

@test "prints timestamped directories at the top level" {
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

@test "ignores anything that does not look like a snapshot" {
    # Paths that should not be printed:
    touch -- "$BATS_TEST_TMPDIR"/foo                 # incorrectly named file
    touch -- "$BATS_TEST_TMPDIR/$TIMESTAMP"          # correctly named file
    mkdir -p -- "$BATS_TEST_TMPDIR"/bar/"$TIMESTAMP" # correctly named nested directory

    run -0 print_snapshots "$BATS_TEST_TMPDIR"
    refute_output
}
