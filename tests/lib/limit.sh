reset_limits() {
    local event_name
    for event_name in "${EVENT_NAMES[@]}"; do
        set_limit "$event_name"
    done
}
