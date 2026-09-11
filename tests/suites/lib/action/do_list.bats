source ./tests/lib/init.bash
source ./lib/init.bash

export BATS_TEST_NAME_PREFIX='do_list '

setup() {
    export SNAPSHOTS=$BATS_TEST_TMPDIR/snapshots
}

@test "does nothing if there are no snapshots" {
    run -0 do_list
    refute_output
}

@test "prints timestamped directories" {
    local timestamp
    local snapshot
    while read -r timestamp; do
        snapshot=$SNAPSHOTS/$timestamp
        mkdir -p -- "$snapshot"
        printf "%s\n" "$snapshot"
    done < <(timestamp_seq "$TIMESTAMP" hour 24) >"$BATS_TEST_TMPDIR"/expected

    run -0 do_list
    assert_output - <"$BATS_TEST_TMPDIR"/expected
}

@test "ignores anything that isn't a timestamped directory" {
    # Ignore a nested correctly named directory.
    mkdir -p -- "$SNAPSHOTS/foo/$TIMESTAMP"

    # Ignore a shallow correctly named file.
    touch -- "$SNAPSHOTS/$TIMESTAMP"

    run -0 do_list
    refute_output
}
