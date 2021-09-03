get_snapshots() {
    local directory=$1
    for snapshot in "$directory"/*; do
        if [[ -d $snapshot ]] && is_timestamp "${snapshot##*/}"; then
            printf "%s\n" "$snapshot"
        fi
    done
}
