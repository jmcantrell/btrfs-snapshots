declare -A SNAPSHOTS_VALUES_SEEN=()

load_profile() {
    PROFILE_NAME=${PROFILE_FILE##*/}
    PROFILE_NAME=${PROFILE_NAME%.conf}

    if [[ ! -f $PROFILE_FILE ]]; then
        error "$TEXT_PROFILE_NOT_EXIST" "$PROFILE_NAME"
        return 1
    fi

    unset SNAPSHOTS

    local event_name
    for event_name in "${EVENT_NAMES[@]}"; do
        set_limit "$event_name"
    done

    local defaults_file=$ETC_DIR/defaults.conf

    if [[ -f $defaults_file ]] && ! . "$defaults_file"; then
        error "$TEXT_DEFAULTS_LOAD_FAILED" "$defaults_file"
        return 1
    fi

    unset SUBVOLUME

    if [[ -v SNAPSHOTS && $SNAPSHOTS != *%s* ]]; then
        error "$TEXT_DEFAULTS_SNAPSHOTS_MISSING_PLACEHOLDER"
        return 1
    fi

    . "$PROFILE_FILE" || return 1

    local variable
    for variable in SUBVOLUME SNAPSHOTS; do
        if [[ ! -v $variable || -z ${!variable} ]]; then
            error "$TEXT_PROFILE_VARIABLE_NOT_SET" \
                "$PROFILE_NAME" "$variable" 
            return 1
        fi

        if [[ ${!variable} != /* ]]; then
            error "$TEXT_PROFILE_ABS_PATH" \
                "$PROFILE_NAME" "$variable"
            return 1
        fi
    done

    printf -v SNAPSHOTS "$SNAPSHOTS" "$PROFILE_NAME"

    if [[ -v SNAPSHOTS_VALUES_SEEN[$SNAPSHOTS] ]]; then
        error "$TEXT_PROFILE_SNAPSHOTS_UNIQUE" "$PROFILE_NAME"
        return 1
    fi

    SNAPSHOTS_VALUES_SEEN[$SNAPSHOTS]=1
}
