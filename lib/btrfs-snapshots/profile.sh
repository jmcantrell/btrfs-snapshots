load_profile() {
    PROFILE_NAME=${PROFILE_FILE##*/}
    PROFILE_NAME=${PROFILE_NAME%.conf}

    if [[ ! -r $PROFILE_FILE ]]; then
        error "$TEXT_PROFILE_NOT_EXIST" PROFILE_NAME
        return 1
    fi

    unset SUBVOLUME SNAPSHOTS

    local event_name
    for event_name in "${EVENT_NAMES[@]}"; do
        set_limit "$event_name"
    done

    . "$PROFILE_FILE" || return 1

    if [[ ! -v SNAPSHOTS && -v DEFAULT_SNAPSHOTS ]]; then
        SNAPSHOTS=$(format "$DEFAULT_SNAPSHOTS" NAME="$PROFILE_NAME")
    fi

    local variable
    for variable in SUBVOLUME SNAPSHOTS; do
        if [[ ! -v $variable || -z ${!variable} ]]; then
            error "$TEXT_PROFILE_VARIABLE_NOT_SET" VARIABLE="$variable" PROFILE_NAME
            return 1
        fi

        if [[ ! ${!variable} =~ ^/.* ]]; then
            error "$TEXT_PROFILE_ABS_PATH" VARIABLE="$variable" PROFILE_NAME
            return 1
        fi
    done
}
