stack_trace() {
    local depth=0
    while caller "$((depth++))"; do :; done | tac
}
