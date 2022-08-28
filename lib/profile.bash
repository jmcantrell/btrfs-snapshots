declare -A SNAPSHOTS_VALUES_SEEN=()

load_profile() {
    unset SNAPSHOTS

    local event_name
    for event_name in "${EVENT_NAMES[@]}"; do
        limit "$event_name" 0
    done

    local defaults_file=$CONFIG_DIR/defaults.conf

    if [[ -f $defaults_file ]] && ! . "$defaults_file"; then
        printf "$TEXT_SOURCE_FAILED\n" "$defaults_file" >&2
        return 1
    fi

    unset SUBVOLUME

    if [[ -v SNAPSHOTS && $SNAPSHOTS != *%s* ]]; then
        printf "$TEXT_DEFAULTS_SNAPSHOTS_MISSING_PLACEHOLDER\n" "$defaults_file" >&2
        return 1
    fi

    if ! . "$PROFILE_FILE"; then
        printf "$TEXT_SOURCE_FAILED\n" "$PROFILE_FILE" >&2
        return 1
    fi

    local variable
    for variable in SUBVOLUME SNAPSHOTS; do
        if [[ ! -v $variable || -z ${!variable} ]]; then
            printf "$TEXT_PROFILE_VARIABLE_NOT_SET\n" "$PROFILE_FILE" "$variable" >&2
            return 1
        fi

        if [[ ${!variable} != /* ]]; then
            printf "$TEXT_PROFILE_PATH_NOT_ABSOLUTE\n" "$PROFILE_FILE" "$variable" >&2
            return 1
        fi
    done

    printf -v SNAPSHOTS "$SNAPSHOTS" "$(basename "$PROFILE_FILE" .conf)"

    if [[ -v SNAPSHOTS_VALUES_SEEN[$SNAPSHOTS] ]]; then
        unset SUBVOLUME SNAPSHOTS
        printf "$TEXT_PROFILE_SNAPSHOTS_NOT_UNIQUE\n" "$PROFILE_FILE" >&2
        return 1
    fi

    SNAPSHOTS_VALUES_SEEN[$SNAPSHOTS]=1
}
