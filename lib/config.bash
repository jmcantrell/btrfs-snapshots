print_profiles() {
    local names=()
    local -A files=()

    local file name

    for file in "$PROFILES_DIR"/*.conf; do
        if [[ -f $file ]]; then
            name=${file##*/}
            name=${name%.conf}
            names+=("$name")
            files[$name]=$file
        fi
    done

    local invalid=()
    local -A selected=()

    for name in "$@"; do
        if [[ ! -v files[$name] ]]; then
            invalid+=("${name@Q}")
        fi
        selected[$name]=1
    done

    if ((${#invalid[@]} > 0)); then
        printf "%s: profiles do not exist: %s\n" "$0" "${invalid[*]}" >&2
        return 2
    fi

    if ((${#selected[@]} == 0)); then
        for name in "${names[@]}"; do
            selected[$name]=1
        done
    fi

    for name in "${names[@]}"; do
        if [[ -v selected[$name] ]]; then
            printf "%s\n" "${files[$name]}"
        fi
    done
}

load_profile() {
    export PROFILE_FILE=${1:?missing profile file}

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

    export SUBVOLUME SNAPSHOTS
}
