get_limit_variable() {
    echo "LIMIT_${1@U}"
}

get_default_limit_variable() {
    echo "DEFAULT_$(get_limit_variable "$1")"
}

get_limit() {
    local variable default_variable
    variable=$(get_limit_variable "$1")
    default_variable=$(get_default_limit_variable "$1")
    echo "${!variable:-${!default_variable:-0}}"
}

set_limit() {
    local variable default_variable
    variable=$(get_limit_variable "$1")
    default_variable=$(get_default_limit_variable "$1")
    eval "$variable=${2:-${!default_variable:-0}}"
}

is_limit_enabled() {
    (($(get_limit "$1") > 0))
}
