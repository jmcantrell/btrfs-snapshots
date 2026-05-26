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
        if [[ -v files[$name] ]]; then
            selected[$name]=1
        else
            invalid+=("${name@Q}")
        fi
    done

    if ((${#invalid[@]} > 0)); then
        printf "%s: profiles do not exist: %s\n" "$SELF_NAME" "${invalid[*]}" >&2
        return 78
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

    local return_status

    if [[ -f $DEFAULTS_FILE ]]; then
        return_status=0
        source "$DEFAULTS_FILE" || return_status=$?
        if ((return_status > 0)); then
            printf "%s: could not load defaults: %q\n" "$SELF_NAME" "$DEFAULTS_FILE" >&2
            return $return_status
        fi
    fi

    unset SUBVOLUME

    if [[ -v SNAPSHOTS && $SNAPSHOTS != *%s* ]]; then
        printf "%s: configured default for SNAPSHOTS is missing the %%s placeholder: %q\n" "$SELF_NAME" "$SNAPSHOTS" >&2
        return 78
    fi

    return_status=0
    source "$PROFILE_FILE" || return_status=$?
    if ((return_status > 0)); then
        printf "%s: could not load profile: %q\n" "$SELF_NAME" "$PROFILE_FILE" >&2
        return $return_status
    fi

    local variable
    for variable in SUBVOLUME SNAPSHOTS; do
        if [[ ! -v $variable || -z ${!variable} ]]; then
            printf "%s: variable %q is not set for profile: %s\n" "$SELF_NAME" "$variable" "$PROFILE_NAME" >&2
            return 78
        fi
        if [[ ${!variable} != /* ]]; then
            printf "%s: profile %q variable %q is not an absolute path: %s\n" "$SELF_NAME" "$PROFILE_NAME" "$variable" "${!variable}" >&2
            return 78
        fi
    done

    printf -v SNAPSHOTS -- "$SNAPSHOTS" "$PROFILE_NAME"

    export SUBVOLUME SNAPSHOTS
}
