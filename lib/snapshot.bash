is_snapshot() {
    local directory=${1:?missing directory}
    [[ -d $directory ]] && is_timestamp "${directory##*/}"
}

print_snapshots() {
    local directory=${1:?missing directory}

    local path
    for path in "$directory"/*; do
        if is_snapshot "$path"; then
            printf "%s\n" "$path"
        fi
    done
}
