source ./tests/lib/init.bash
source ./lib/init.bash

export BATS_TEST_NAME_PREFIX='print_profiles '

setup() {
    CONFIG_DIR=$BATS_TEST_TMPDIR/etc
    PROFILES_DIR=$CONFIG_DIR/profile.d

    mkdir -p -- "$PROFILES_DIR"
}

@test "prints nothing if there are no profiles" {
    run -0 print_profiles
    refute_output
}

@test "only considers *.conf files at the top level" {
    # Add some invalid paths (that should not be returned):
    mkdir -p -- "$PROFILES_DIR"/dir        # directory
    mkdir -p -- "$PROFILES_DIR"/bogus.conf # correctly named directory
    touch -- "$PROFILES_DIR"/dir/deep.conf # correctly named nested file

    run -0 print_profiles
    refute_output
}

@test "prints all profiles by default" {
    touch -- "$PROFILES_DIR"/{a,b,c}.conf

    run -0 print_profiles
    printf "$PROFILES_DIR/%s.conf\n" a b c | assert_output -
}

@test "output is sorted" {
    touch -- "$PROFILES_DIR"/{a..z}.conf

    readarray -t shuffled < <(printf "%s\n" {a..z} | shuf)

    run -0 print_profiles "${shuffled[@]}"
    printf "$PROFILES_DIR/%s.conf\n" {a..z} | assert_output -
}

@test "output is deduplicated" {
    touch -- "$PROFILES_DIR"/{a,b,c}.conf

    run -0 print_profiles c a c b c a b b a
    printf "$PROFILES_DIR/%s.conf\n" a b c | assert_output -
}

@test "prints only the selected profiles" {
    touch -- "$PROFILES_DIR"/{a..z}.conf

    readarray -t selected < <(printf "%s\n" {a..z} | shuf -n$((RANDOM % 12 + 2)))

    run -0 print_profiles "${selected[@]}"
    printf -- "$PROFILES_DIR/%s.conf\n" "${selected[@]}" | sort | assert_output -
}

@test "fails when non-existent profiles are selected" {
    touch -- "$PROFILES_DIR"/{a,b,c}.conf

    run -78 --separate-stderr print_profiles a b foo c bar
    assert_stderr "test: profiles do not exist: 'foo' 'bar'"
    refute_output
}
