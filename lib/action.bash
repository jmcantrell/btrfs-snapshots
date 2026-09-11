do_list() {
    print_snapshots "$SNAPSHOTS"
}

do_create() {
    if ! mountpoint -q -- "$SUBVOLUME"; then
        printf "%s: subvolume is not available: %q\n" "$SELF_NAME" "$SUBVOLUME" >&2
        return 0
    fi

    local now
    now=$(timestamp)

    mkdir -p "$SNAPSHOTS"

    btrfs subvolume snapshot -r -- "$SUBVOLUME" "$SNAPSHOTS/$now"
}

do_prune() {
    local counts=()
    local limits=()
    local event_names=()

    local event_name
    local variable
    local limit
    for event_name in "${EVENT_NAMES[@]}"; do
        variable=LIMIT_${event_name^^}
        limit=${!variable:-0}
        if ((limit > 0)); then
            counts+=(0)
            limits+=("$limit")
            event_names+=("$event_name")
        fi
    done

    local snapshots
    readarray -t snapshots < <(print_snapshots "$SNAPSHOTS")

    local snapshot
    local snapshot_index
    local timestamp
    local event_index
    local delete

    # Consider every snapshot, working backward chronologically from the most recent.
    for ((snapshot_index = ${#snapshots[@]} - 1; snapshot_index >= 0; snapshot_index--)); do
        snapshot=${snapshots[snapshot_index]}
        timestamp=${snapshot##*/}
        delete=1

        # Look for an event period that this snapshot can count toward.
        for ((event_index = 0; event_index < ${#event_names[@]}; event_index++)); do

            # This event type has already reached its limit.
            if ((counts[event_index] >= limits[event_index])); then
                continue
            fi

            # There is an earlier snapshot in the same event period, so it cannot count toward this event type.
            if ((snapshot_index > 0)) && is_same_event "${event_names[event_index]}" "$timestamp" "${snapshots[snapshot_index - 1]##*/}"; then
                continue
            fi

            # This is the earliest snapshot in the event period under
            # consideration and the event limit has not yet been reached, so
            # count it, and mark it to be kept.
            counts[event_index]=$((counts[event_index] + 1))
            delete=0
            break
        done

        # No event period could be found that this snapshot could count toward.
        if ((delete)); then
            btrfs subvolume delete -- "$snapshot"
        fi
    done
}
