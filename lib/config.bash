load_profile() {
    export PROFILE_FILE=$1

    PROFILE_NAME=${PROFILE_FILE##*/}
    PROFILE_NAME=${PROFILE_NAME%.conf}
    export PROFILE_NAME

    unset SNAPSHOTS

    local event_name
    for event_name in "${EVENT_NAMES[@]}"; do
        export "LIMIT_${event_name^^}=0"
    done

    if [[ -f $DEFAULTS_FILE ]] && ! . "$DEFAULTS_FILE"; then
        printf "%s: unable to source file: %q\n" "$0" "$DEFAULTS_FILE" >&2
        return 1
    fi

    unset SUBVOLUME

    if [[ -v SNAPSHOTS && $SNAPSHOTS != *%s* ]]; then
        printf "%s: default SNAPSHOTS is missing the %%s placeholder: %q\n" "$0" "$SNAPSHOTS" >&2
        return 1
    fi

    if ! . "$PROFILE_FILE"; then
        printf "%s: unable to source file: %q\n" "$0" "$PROFILE_FILE" >&2
        return 1
    fi

    local variable
    for variable in SUBVOLUME SNAPSHOTS; do
        if [[ ! -v $variable || -z ${!variable} ]]; then
            printf "%s: variable is not set: %s\n" "$0" "$variable" >&2
            return 1
        fi

        if [[ ${!variable} != /* ]]; then
            printf "%s: %s is not an absolute path: %q\n" "$0" "$variable" "${!variable}" >&2
            return 1
        fi
    done

    printf -v SNAPSHOTS "$SNAPSHOTS" "$PROFILE_NAME"

    export SUBVOLUME SNAPSHOTS "${EVENT_NAMES[@]/#/LIMIT_}"
}
