list() {
    get_snapshots "$SNAPSHOTS"
}

create() {
    if ! is_mounted "$SUBVOLUME"; then
        warning "$TEXT_CREATE_SUBVOLUME_MISSING" PROFILE_NAME
        return 0
    fi

    # Allow ability to override the running timestamp, simplifying testing.
    TIMESTAMP=${BTRFS_SNAPSHOTS_TIMESTAMP:-$(get_timestamp)}

    mkdir -p "$SNAPSHOTS"
    btrfs subvolume snapshot -r "$SUBVOLUME" "$SNAPSHOTS/$TIMESTAMP" || {
        error "$TEXT_BTRFS_FAILED" STATUS="$?"
        return 1
    }
}

prune() {
    local event_name counts=() limits=()
    for event_name in "${EVENT_NAMES[@]}"; do
        counts+=(0)
        limits+=("$(get_limit "$event_name")")
    done

    local snapshots
    readarray -t snapshots < <(get_snapshots "$SNAPSHOTS" | sort -r)

    local snapshot_index
    for ((snapshot_index = 0; snapshot_index < ${#snapshots[@]}; snapshot_index++)); do
        local snapshot=${snapshots[snapshot_index]}
        local timestamp=${snapshot##*/}

        local event_index keep=0
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
                if (($(timestamp_compare "$timestamp" "$other_timestamp") == 1)); then
                    continue 2
                fi
            done

            keep=1
        done

        if ((keep)); then
            continue
        fi

        btrfs subvolume delete "$snapshot" || {
            error "$TEXT_BTRFS_FAILED" STATUS="$?"
            return 1
        }
    done
}
