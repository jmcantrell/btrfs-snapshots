get_limit_variable() {
    echo "LIMIT_${1@U}"
}

get_limit() {
    local variable
    variable=$(get_limit_variable "$1")
    echo "${!variable:-0}"
}

set_limit() {
    local variable
    variable=$(get_limit_variable "$1")
    eval "$variable=${2:-0}"
}

is_limit_enabled() {
    (($(get_limit "$1") > 0))
}
