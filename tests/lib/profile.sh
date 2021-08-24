create_profile_unsafe() {
    if [[ -v 1 ]]; then
        echo "SUBVOLUME=$1"
    fi

    if [[ -v 2 ]]; then
        echo "SNAPSHOTS=$2"
    fi
}

create_profile() {
    create_profile_unsafe "$1" "$2"
    shift 2

    local limit
    for limit in "$@"; do
        name=${limit%=*}
        value=${limit#*=}
        echo "$(get_limit_variable "$name")=${value:-0}"
    done
}
