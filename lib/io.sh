info() {
    local format=$1
    shift
    printf -- "$format\n" "$@"
}

warning() {
    local format=$1
    shift
    printf "WARNING: $format\n" "$@" >&2
}

error() {
    local format=$1
    shift
    printf "ERROR: $format\n" "$@" >&2
}

die() {
    (($# > 0)) && error "$@"
    exit 1
}
