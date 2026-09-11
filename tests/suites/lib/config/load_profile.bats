source ./tests/lib/init.bash
source ./lib/init.bash

export BATS_TEST_NAME_PREFIX='load_profile '

setup() {
    CONFIG_DIR=$BATS_TEST_TMPDIR/etc
    PROFILES_DIR=$CONFIG_DIR/profile.d
    DEFAULTS_FILE=$CONFIG_DIR/defaults.conf

    mkdir -p -- "$PROFILES_DIR"
}

assert_loaded() {
    local profile_file=${1:?missing profile file}

    local output
    local return_status=0
    output=${ load_profile "$profile_file" 2>&1;} || return_status=$?
    assert_equal "$return_status" 0
    assert_equal "$output" ""
}

assert_not_loaded() {
    local profile_file=${1:?missing profile file}
    local return_status=${2:?missing return status}
    local error_message=${3:?missing error message}

    run -"$return_status" --separate-stderr load_profile "$profile_file"
    assert_stderr "$error_message"
    refute_output
}

@test "limits are zero by default" {
    local profile_file=$PROFILES_DIR/foo.conf

    printf "%s=%q\n" \
        SUBVOLUME "$BATS_TEST_TMPDIR" \
        SNAPSHOTS "$BATS_TEST_TMPDIR" \
        >"$profile_file"

    assert_loaded "$profile_file"

    local event_name
    local variable
    # Ensure the base default is zero.
    for event_name in "${EVENT_NAMES[@]}"; do
        variable=LIMIT_${event_name^^}
        assert_equal "${!variable}" 0
    done
}

@test "recognizes default limits" {
    local profile_file=$PROFILES_DIR/foo.conf

    printf "%s=%q\n" \
        SUBVOLUME "$BATS_TEST_TMPDIR" \
        SNAPSHOTS "$BATS_TEST_TMPDIR" \
        >"$profile_file"

    local limits=()

    local event_name
    local limit
    for event_name in "${EVENT_NAMES[@]}"; do
        limit=$((1 + RANDOM))
        limits+=("$limit")

        printf "%s=%d\n" \
            LIMIT_"${event_name^^}" "$limit" \
            >>"$DEFAULTS_FILE"
    done

    assert_loaded "$profile_file"

    local i
    local variable
    # Ensure the profile will be using the previously set defaults.
    for i in "${!EVENT_NAMES[@]}"; do
        variable=LIMIT_${EVENT_NAMES[i]^^}
        assert_equal "${!variable}" "${limits[i]}"
    done
}

@test "recognizes a default snapshots directory" {
    local profile_name=profile$RANDOM
    local profile_file=$PROFILES_DIR/$profile_name.conf

    printf "%s=%q\n" \
        SUBVOLUME "$BATS_TEST_TMPDIR" \
        >"$profile_file"

    printf "%s=%q\n" \
        SNAPSHOTS "$BATS_TEST_TMPDIR/%s" \
        >"$DEFAULTS_FILE"

    assert_loaded "$profile_file"

    assert_equal "$SNAPSHOTS" "$BATS_TEST_TMPDIR/$profile_name"
}

@test "fails if the default snapshots directory is missing a placeholder" {
    local profile_file=$PROFILES_DIR/foo.conf

    printf "%s=%q\n" \
        SUBVOLUME "$BATS_TEST_TMPDIR" \
        >"$profile_file"

    printf "%s=%q\n" \
        SNAPSHOTS "$BATS_TEST_TMPDIR" \
        >"$DEFAULTS_FILE"

    assert_not_loaded "$profile_file" 78 \
        "test: configured default for SNAPSHOTS is missing the %s placeholder: $BATS_TEST_TMPDIR"
}

@test "reports errors when reading defaults" {
    local profile_file=$PROFILES_DIR/foo.conf

    printf "%s=%q\n" \
        SUBVOLUME "$TEMP_DIR" \
        SNAPSHOTS "$TEMP_DIR" \
        >"$profile_file"

    local return_status=$((RANDOM % 255 + 1))

    printf "return %d\n" "$return_status" >"$DEFAULTS_FILE"

    assert_not_loaded "$profile_file" "$return_status" \
        "test: could not load defaults: $DEFAULTS_FILE"
}

@test "ensures a subvolume setting is ignored in the defaults" {
    local profile_file=$PROFILES_DIR/foo.conf

    # Create a profile that does not have the subvolume set.
    printf "%s=%q\n" \
        SNAPSHOTS "$BATS_TEST_TMPDIR" \
        >"$profile_file"

    # If there's no protection, this value will get used.
    printf "%s=%q\n" \
        SUBVOLUME "$BATS_TEST_TMPDIR" \
        >"$DEFAULTS_FILE"

    assert_not_loaded "$profile_file" 78 \
        "test: variable SUBVOLUME is not set for profile: foo"
}

@test "recognizes all settings in profile" {
    local profile_file=$PROFILES_DIR/foo.conf

    local subvolume_dir=$BATS_TEST_TMPDIR/$RANDOM
    local snapshots_dir=$BATS_TEST_TMPDIR/$RANDOM

    printf "%s=%q\n" \
        SUBVOLUME "$subvolume_dir" \
        SNAPSHOTS "$snapshots_dir" \
        >"$profile_file"

    local limits=()

    local limit
    local event_name
    # These limits are randomized, but will be at least 2.
    for event_name in "${EVENT_NAMES[@]}"; do
        limit=$((RANDOM % 10 + 2))
        limits+=("$limit")
        printf "%s=%d\n" \
            LIMIT_"${event_name^^}" "$limit" \
            >>"$profile_file"
    done

    # The default limits are all set to 1. If the ones set in the profile are
    # not recognized, they will still be 1.
    for event_name in "${EVENT_NAMES[@]}"; do
        printf "%s=%d\n" LIMIT_"${event_name^^}" 1
    done >"$DEFAULTS_FILE"

    assert_loaded "$profile_file"

    assert_equal "$SUBVOLUME" "$subvolume_dir"
    assert_equal "$SNAPSHOTS" "$snapshots_dir"

    local i
    local variable
    for i in "${!EVENT_NAMES[@]}"; do
        variable=LIMIT_${EVENT_NAMES[i]^^}
        assert_not_equal "${!variable}" 1
        assert_equal "${!variable}" "${limits[i]}"
    done
}

@test "overwrites a previous subvolume setting" {
    local profile_file=$PROFILES_DIR/foo.conf

    # Try to trick the function into accepting a previous value.
    export SUBVOLUME=$BATS_TEST_TMPDIR

    # Write a profile with no variables set. If existing variables are not
    # overwritten, there should be no errors and the value would remain set.
    touch -- "$profile_file"

    assert_not_loaded "$profile_file" 78 \
        "test: variable SUBVOLUME is not set for profile: foo"
}

@test "overwrites a previous snapshots setting" {
    local profile_file=$PROFILES_DIR/foo.conf

    # Try to trick the function into accepting a previous value.
    export SNAPSHOTS=$BATS_TEST_TMPDIR

    # Write a profile with only subvolume set. If existing variables are not
    # overwritten, there should be no errors and the value would remain set.
    printf "%s=%q\n" \
        SUBVOLUME "$BATS_TEST_TMPDIR" \
        >"$profile_file"

    assert_not_loaded "$profile_file" 78 \
        "test: variable SNAPSHOTS is not set for profile: foo"
}

@test "overwrites any previous limit settings" {
    local profile_file=$PROFILES_DIR/foo.conf

    # Try to trick the function into accepting previous values.
    for event_name in "${EVENT_NAMES[@]}"; do
        export "LIMIT_${event_name^^}=1"
    done

    # Write a valid profile with no limits set. If existing variables are not
    # overwritten, the limits should be non-zero.
    printf "%s=%q\n" \
        SUBVOLUME "$BATS_TEST_TMPDIR" \
        SNAPSHOTS "$BATS_TEST_TMPDIR" \
        >"$profile_file"

    assert_loaded "$profile_file"

    # If $variable was not overwritten, it would be non-zero
    for event_name in "${EVENT_NAMES[@]}"; do
        variable=LIMIT_${event_name^^}
        assert_equal "${!variable}" 0
    done
}

@test "fails if the subvolume directory is not set" {
    local profile_file=$PROFILES_DIR/foo.conf

    printf "%s=%q\n" \
        SNAPSHOTS "$BATS_TEST_TMPDIR" \
        >"$profile_file"

    assert_not_loaded "$profile_file" 78 \
        "test: variable SUBVOLUME is not set for profile: foo"
}

@test "fails if the subvolume directory is empty" {
    local profile_file=$PROFILES_DIR/foo.conf

    printf "%s=%q\n" \
        SUBVOLUME "" \
        SNAPSHOTS "$BATS_TEST_TMPDIR" \
        >"$profile_file"

    assert_not_loaded "$profile_file" 78 \
        "test: variable SUBVOLUME is not set for profile: foo"
}

@test "fails if the subvolume directory is not absolute" {
    local profile_file=$PROFILES_DIR/foo.conf

    printf "%s=%q\n" \
        SUBVOLUME "./relative" \
        SNAPSHOTS "$BATS_TEST_TMPDIR" \
        >"$profile_file"

    assert_not_loaded "$profile_file" 78 \
        "test: profile foo variable SUBVOLUME is not an absolute path: ./relative"
}

@test "fails if the snapshots directory is not set" {
    local profile_file=$PROFILES_DIR/foo.conf

    printf "%s=%q\n" \
        SUBVOLUME "$BATS_TEST_TMPDIR" \
        >"$profile_file"

    assert_not_loaded "$profile_file" 78 \
        "test: variable SNAPSHOTS is not set for profile: foo"
}

@test "fails if the snapshots directory is empty" {
    local profile_file=$PROFILES_DIR/foo.conf

    printf "%s=%q\n" \
        SUBVOLUME "$BATS_TEST_TMPDIR" \
        SNAPSHOTS "" \
        >"$profile_file"

    assert_not_loaded "$profile_file" 78 \
        "test: variable SNAPSHOTS is not set for profile: foo"
}

@test "fails if the snapshots directory is not absolute" {
    local profile_file=$PROFILES_DIR/foo.conf

    printf "%s=%q\n" \
        SUBVOLUME "$BATS_TEST_TMPDIR" \
        SNAPSHOTS "./relative" \
        >"$profile_file"

    assert_not_loaded "$profile_file" 78 \
        "test: profile foo variable SNAPSHOTS is not an absolute path: ./relative"
}
