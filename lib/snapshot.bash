is_snapshot() {
    [[ -d $1 ]] && is_timestamp "${1##*/}"
}

get_snapshots() {
    for path in "$1"/*; do
        if is_snapshot "$path"; then
            printf "%s\n" "$path"
        fi
    done
}
