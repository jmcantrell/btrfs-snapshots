st_dev() {
    stat -c %d "$1"
}

st_ino() {
    stat -c %i "$1"
}

is_mounted() {
    local path=$1

    if [[ ! -d $path ]]; then
        return 1
    fi

    if [[ -v BTRFS_SNAPSHOTS_BYPASS_IS_MOUNTED ]]; then
        return 0
    fi

    local dev parent_dev
    dev=$(st_dev "$path")
    parent_dev=$(st_dev "$path"/..)

    if ((dev != parent_dev)); then
        return 0
    fi

    local ino parent_ino
    ino=$(st_ino "$path")
    parent_ino=$(st_ino "$path"/..)

    ((ino == parent_ino))
}
