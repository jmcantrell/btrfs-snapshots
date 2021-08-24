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

    echo -n "$message"
}

info() {
    local message
    message=$(format "$@")
    echo "$message" >&2
}

error() {
    local message=$1
    shift
    info "ERROR: $message" "$@"
}

die() {
    (($# > 0)) && error "$@"
    exit 1
}

finish() {
    (($# > 0)) && info "$@"
    exit 0
}
