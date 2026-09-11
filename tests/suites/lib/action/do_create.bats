source ./tests/lib/init.bash
source ./lib/init.bash

export BATS_TEST_NAME_PREFIX='do_create '

setup() {
    bin_dir=$BATS_TEST_TMPDIR/bin
    export PATH=$bin_dir:$PATH

    install -D ./tests/fakes/logger.bash "$bin_dir"/btrfs

    install -D ./tests/fakes/base.bash "$bin_dir"/mountpoint
    {
        # Skip any options.
        printf 'while [[ ${1:-} == -* ]]; do shift; done\n'
        # Pretend that an existing directory is a mount point.
        printf '[[ -d $1 ]]\n'
    } >>"$bin_dir"/mountpoint

    export SUBVOLUME=$BATS_TEST_TMPDIR/subvolume
    export SNAPSHOTS=$BATS_TEST_TMPDIR/snapshots
}

@test "makes a single timestamped snapshot" {
    mkdir -p -- "$SUBVOLUME"
    touch -- "$SUBVOLUME"/marker

    timestamp() {
        if (($# > 0)); then
            printf "fake timestamp got unexpected arguments\n" >&2
            return 1
        fi
        printf "%s\n" "$TIMESTAMP"
    }

    run -0 do_create
    assert_output "fake btrfs subvolume snapshot -r -- $SUBVOLUME $SNAPSHOTS/$TIMESTAMP"
}

@test "reports a missing subvolume and does nothing" {
    run -0 --separate-stderr do_create
    assert_stderr "test: subvolume is not available: $SUBVOLUME"
    refute_output
}

@test "btrfs exit status is forwarded" {
    mkdir -p -- "$SUBVOLUME"

    local exit_status=$((RANDOM % 255 + 1))
    local error_message="something bad happened"

    # Fake implementation of `btrfs` that always errors.
    install -D ./tests/fakes/error.bash "$bin_dir"/btrfs

    export TEST_FAKE_EXIT_STATUS=$exit_status
    export TEST_FAKE_ERROR_MESSAGE=$error_message
    run -"$exit_status" --separate-stderr do_create
    assert_stderr "$error_message"
    refute_output
}
