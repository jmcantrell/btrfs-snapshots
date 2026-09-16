source "$LIB_DIR"/timestamp.bash

do_action() {
    if ! mountpoint -q -- "$SUBVOLUME"; then
        printf "%s: subvolume is not available: %q\n" "$SELF_NAME" "$SUBVOLUME" >&2
        return 0
    fi

    local now
    now=$(timestamp)

    mkdir -p "$SNAPSHOTS"

    btrfs subvolume snapshot -r -- "$SUBVOLUME" "$SNAPSHOTS/$now"
}
