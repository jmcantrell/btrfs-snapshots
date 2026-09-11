source ./tests/lib/init.bash

export BATS_TEST_NAME_PREFIX='btrfs-snapshots '

setup() {
    bin_dir=$BATS_TEST_TMPDIR/bin
    export PATH=$bin_dir:$PATH

    CONFIG_DIR=$BATS_TEST_TMPDIR/etc
    PROFILES_DIR=$CONFIG_DIR/profile.d

    mkdir -p -- "$PROFILES_DIR"

    lib_dir=$BATS_TEST_TMPDIR/lib
    install -D /dev/null "$lib_dir"/init.bash

    export BTRFS_SNAPSHOTS_LIB_DIR=$lib_dir
    export BTRFS_SNAPSHOTS_CONFIG_DIR=$CONFIG_DIR
}

assert_help() {
    run -0 btrfs-snapshots "$@"
    assert_output --regexp ".*Usage:.*Actions:.*Arguments:.*Environment:.*"
}

for flag in -h --help; do
    bats_test_function --description "prints help with $flag" -- \
        assert_help "$flag"
done

assert_version() {
    printf "fake version\n" >"$lib_dir"/version

    run -0 btrfs-snapshots "$@"
    assert_output "fake version"
}

for flag in -v --version; do
    bats_test_function --description "prints version with $flag" -- \
        assert_version "$flag"
done

@test "complains when no action is given" {
    run -64 --separate-stderr btrfs-snapshots
    assert_stderr "btrfs-snapshots: missing action"
    refute_output
}

@test "complains when an invalid action is given" {
    run -64 --separate-stderr btrfs-snapshots bogus
    assert_stderr "btrfs-snapshots: invalid action: bogus"
    refute_output
}

test_init() {
    local action=${1:?missing action}

    # Quiet these functions to isolate the test.
    install -D ./tests/fakes/base.bash "$bin_dir"/print_profiles
    install -D ./tests/fakes/base.bash "$bin_dir"/load_profile
    install -D ./tests/fakes/base.bash "$bin_dir"/do_"$action"

    # Have the command print something to suppress the error.
    printf 'printf "does not matter\n"' >>"$bin_dir"/print_profiles

    local variable
    # Log the key variables as the initializer sees them.
    for variable in PROFILES_DIR DEFAULTS_FILE; do
        printf 'printf "%s=%%s\\n" "$%s"\n' "$variable" "$variable"
    done >"$lib_dir"/init.bash

    run -0 btrfs-snapshots "$action"
    # Ensure the intializer was sourced and it saw the proper settings.
    {
        printf "PROFILES_DIR=%s/profile.d\n" "$BTRFS_SNAPSHOTS_CONFIG_DIR"
        printf "DEFAULTS_FILE=%s/defaults.conf\n" "$BTRFS_SNAPSHOTS_CONFIG_DIR"
    } | assert_output -
}

test_no_config() {
    local action=${1:?missing action}

    install -D ./tests/fakes/base.bash "$bin_dir"/print_profiles

    run -66 --separate-stderr btrfs-snapshots "$action"
    assert_stderr "btrfs-snapshots: no profiles configured"
    refute_output
}

test_pass_args() {
    local action=${1:?missing action}

    install -D ./tests/fakes/logger.bash "$bin_dir"/print_profiles

    # Have the command print something to suppress the error.
    printf 'printf "does not matter\n"' >>"$bin_dir"/print_profiles

    # Quiet these functions to isolate the test.
    install -D ./tests/fakes/base.bash "$bin_dir"/load_profile
    install -D ./tests/fakes/base.bash "$bin_dir"/do_"$action"

    run -0 btrfs-snapshots "$action"
    assert_output "fake print_profiles"

    run -0 btrfs-snapshots "$action" a b c
    assert_output "fake print_profiles a b c"
}

test_pass_control() {
    local action=${1:?missing action}

    install -D ./tests/fakes/base.bash "$bin_dir"/print_profiles
    printf 'printf "%%s\n" /path/to/profile/{a,b,c}.conf\n' >>"$bin_dir"/print_profiles

    install -D ./tests/fakes/logger.bash "$bin_dir"/load_profile
    install -D ./tests/fakes/logger.bash "$bin_dir"/do_"$action"

    run -0 btrfs-snapshots "$action"
    {
        printf "fake load_profile /path/to/profile/a.conf\n"
        printf "fake do_%s\n" "$action"
        printf "fake load_profile /path/to/profile/b.conf\n"
        printf "fake do_%s\n" "$action"
        printf "fake load_profile /path/to/profile/c.conf\n"
        printf "fake do_%s\n" "$action"
    } | assert_output -
}

for action in list create prune; do
    bats_test_function --description "$action properly initializes the core" -- \
        test_init "$action"

    bats_test_function --description "$action complains if no profiles are configured" -- \
        test_no_config "$action"

    bats_test_function --description "$action passes arguments to print_profiles" -- \
        test_pass_args "$action"

    bats_test_function --description "$action passes control to the core action" -- \
        test_pass_control "$action"
done
