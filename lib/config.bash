load_profile() {
    export PROFILE_FILE=$1

    PROFILE_NAME=${PROFILE_FILE##*/}
    export PROFILE_NAME=${PROFILE_NAME%.conf}

    unset SNAPSHOTS

    local variable event_name
    for event_name in "${EVENT_NAMES[@]}"; do
        export "LIMIT_${event_name^^}=0"
    done

    if [[ -f $DEFAULTS_FILE ]] && ! . "$DEFAULTS_FILE"; then
        printf "$TEXT_SOURCE_FAILED\n" "$DEFAULTS_FILE" >&2
        return 1
    fi

    unset SUBVOLUME

    if [[ -v SNAPSHOTS && $SNAPSHOTS != *%s* ]]; then
        printf "$TEXT_DEFAULTS_SNAPSHOTS_MISSING_PLACEHOLDER\n" "$DEFAULTS_FILE" "$SNAPSHOTS" >&2
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
            printf "$TEXT_PROFILE_PATH_NOT_ABSOLUTE\n" "$PROFILE_FILE" "$variable" "${!variable}" >&2
            return 1
        fi
    done

    printf -v SNAPSHOTS "$SNAPSHOTS" "$PROFILE_NAME"

    export SUBVOLUME SNAPSHOTS "${EVENT_NAMES[@]/#/LIMIT_}"
}
