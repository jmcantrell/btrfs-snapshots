do_list() {
    print_snapshots "$SNAPSHOTS"
}

do_create() {
    if ! mountpoint -q "$SUBVOLUME"; then
        printf "%s: subvolume is not available: %q\n" "$0" "$SUBVOLUME" >&2
        return 0
    fi

    # Allow ability to override the timestamp, simplifying testing.
    local timestamp
    timestamp=${BTRFS_SNAPSHOTS_TIMESTAMP:-$(timestamp)} || return 1

    mkdir -p "$SNAPSHOTS"

    btrfs subvolume snapshot -r "$SUBVOLUME" "$SNAPSHOTS/$timestamp" || {
        printf "%s: the btrfs command exited with non-zero status code: %s\n" "$0" "$?" >&2
        return 1
    }
}

do_prune() {
    local counts=() limits=()

    local event_name variable
    for event_name in "${EVENT_NAMES[@]}"; do
        counts+=(0)
        variable=LIMIT_${event_name^^}
        limits+=("${!variable:-0}")
    done

    local snapshots
    readarray -t snapshots < <(print_snapshots "$SNAPSHOTS" | sort -r)

    local snapshot_index
    for ((snapshot_index = 0; snapshot_index < ${#snapshots[@]}; snapshot_index++)); do
        local snapshot=${snapshots[snapshot_index]}
        local timestamp=${snapshot##*/}

        local delete=1

        local event_index
        for ((event_index = 0; event_index < ${#EVENT_NAMES[@]}; event_index++)); do
            # If this event type has already reached its limit, skip it.
            if ((counts[event_index] >= limits[event_index])); then
                continue
            fi

            local event_name=${EVENT_NAMES[event_index]}

            local other_snapshot_index
            for ((other_snapshot_index = snapshot_index + 1; other_snapshot_index < ${#snapshots[@]}; other_snapshot_index++)); do
                local other_snapshot=${snapshots[other_snapshot_index]}
                local other_timestamp=${other_snapshot##*/}

                # If any earlier timestamp after the given one occurs in a different
                # event, the given one must have occurred first.
                if ! is_same_event "$event_name" "$timestamp" "$other_timestamp"; then
                    counts[event_index]=$((counts[event_index] + 1))
                    break
                fi

                # If this pair of timestamps occurred during the same event, and the
                # given one happened later than the other one, it didn't occur first.
                if timestamp_gt "$timestamp" "$other_timestamp"; then
                    continue 2
                fi
            done

            delete=0
        done

        if ((delete)); then
            btrfs subvolume delete "$snapshot" || {
                printf "%s: the btrfs command exited with non-zero status code: %s\n" "$0" "$?" >&2
                return 1
            }
        fi
    done
}
