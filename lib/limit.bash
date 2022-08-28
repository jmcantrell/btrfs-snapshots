limit() {
    local variable=LIMIT_${1@U}

    if [[ -v 2 ]]; then
        export "$variable=$2"
    else
        printf "%s" "${!variable:-0}"
    fi
}
