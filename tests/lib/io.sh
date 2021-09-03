trace() {
    local i size=${#FUNCNAME[@]}
    for ((i = size - 1; i >= 0; i--)); do
        printf "%s\n" "${BASH_SOURCE[i]}: line ${BASH_LINENO[i - 1]}: ${FUNCNAME[i]}" >&2
    done
}

die() {
    trace
    (($# > 0)) && error "$@"
    exit 1
}
