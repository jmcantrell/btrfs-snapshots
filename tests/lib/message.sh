debug() {
    for var in "$@"; do
        info "$var=${!var}"
    done
}

die() {
    local i size=${#FUNCNAME[@]}
    for ((i = size - 1; i >= 0; i--)); do
        echo "${BASH_SOURCE[i]}: line ${BASH_LINENO[i - 1]}: ${FUNCNAME[i]}"
    done

    error "$@"
    exit 1
}
