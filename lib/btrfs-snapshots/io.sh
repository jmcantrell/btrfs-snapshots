format() {
    local message=$1
    shift

    local arg
    for arg in "$@"; do
        if [[ $arg == *=* ]]; then
            local key=${arg%%=*}
            local value=${arg#*=}
            message=${message//%$key%/$value}
        else
            declare -n var=$arg
            message=${message//%$arg%/${var[*]}}
        fi
    done

    printf "%s" "$message"
}

info() {
    local message
    message=$(format "$@")
    printf "%s\n" "$message"
}

warning() {
    local message
    message=$(format "$@")
    printf "WARNING: %s\n" "$message" >&2
}

error() {
    local message
    message=$(format "$@")
    printf "ERROR: %s\n" "$message" >&2
}

die() {
    (($# > 0)) && error "$@"
    exit 1
}
