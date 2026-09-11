source ./tests/lib/init.bash
source ./lib/init.bash

export BATS_TEST_NAME_PREFIX='do_prune '

setup() {
    bin_dir=$BATS_TEST_TMPDIR/bin
    export PATH=$bin_dir:$PATH

    install -D ./tests/fakes/logger.bash "$bin_dir"/btrfs

    export SUBVOLUME=$BATS_TEST_TMPDIR/subvolume
    export SNAPSHOTS=$BATS_TEST_TMPDIR/snapshots
}

@test "does nothing if there are no snapshots" {
    run -0 do_prune
    refute_output
}

@test "removes timestamped directories" {
    mkdir -p -- "$SNAPSHOTS/$TIMESTAMP"

    run -0 do_prune
    assert_output "fake btrfs subvolume delete -- $SNAPSHOTS/$TIMESTAMP"
}

@test "ignores anything that is not a timestamped directory" {
    # Ignore a nested correctly named directory.
    mkdir -p -- "$SNAPSHOTS/foo/$TIMESTAMP"

    # Ignore a shallow correctly named file.
    touch -- "$SNAPSHOTS/$TIMESTAMP"

    run -0 do_prune
    refute_output
}

@test "removes all snapshots if no limits are set" {
    local timestamp
    while read -r timestamp; do
        mkdir -p -- "$SNAPSHOTS/$timestamp"
        printf "fake btrfs subvolume delete -- %s\n" "$SNAPSHOTS/$timestamp"
    done < <(timestamp_seq "$TIMESTAMP" hour $((RANDOM % 15 + 5)) | tac) >"$BATS_TEST_TMPDIR"/output

    run -0 do_prune
    assert_output - <"$BATS_TEST_TMPDIR"/output
}

@test "removes more recent snapshots before less recent ones" {
    local timestamp
    while read -r timestamp; do
        mkdir -p -- "$SNAPSHOTS/$timestamp"
        printf "fake btrfs subvolume delete -- %s\n" "$SNAPSHOTS/$timestamp"
    done < <(timestamp_seq "$TIMESTAMP" hour $((RANDOM % 15 + 5))) >"$BATS_TEST_TMPDIR"/output

    run -0 do_prune
    sort -r "$BATS_TEST_TMPDIR"/output | assert_output -
}

declare -gA event_increment=(
    [minutely]="1 minute"
    [hourly]="1 hour"
    [daily]="1 day"
    [weekly]="7 days"
    [monthly]="1 month"
    [quarterly]="3 months"
    [yearly]="1 year"
)

test_limit_unset() {
    local event_name=${1:?missing event name}

    # Generate enough snapshots to have something to be pruned.
    local total=$((RANDOM % 10 + 1))

    local event_start
    while read -r event_start; do
        mkdir -p -- "$SNAPSHOTS/$event_start"
        printf "fake btrfs subvolume delete -- %s\n" "$_"
    done < <(timestamp_seq "$TIMESTAMP" "${event_increment[$event_name]}" "$total" | tac) >"$BATS_TEST_TMPDIR"/output

    run -0 do_prune
    assert_output - <"$BATS_TEST_TMPDIR"/output
}

test_limit_zero() {
    local event_name=${1:?missing event name}

    # Keep no snapshots.
    export "LIMIT_${event_name^^}=0"

    # Generate enough snapshots to have at least one that will be pruned.
    local total=$((RANDOM % 10 + 1))

    local count=0
    local event_start
    while read -r event_start; do
        mkdir -p -- "$SNAPSHOTS/$event_start"
        printf "fake btrfs subvolume delete -- %s\n" "$_"
    done < <(timestamp_seq "$TIMESTAMP" "${event_increment[$event_name]}" "$total" | tac) >"$BATS_TEST_TMPDIR"/output

    run -0 do_prune
    assert_output - <"$BATS_TEST_TMPDIR"/output
}

test_limit_latest() {
    local event_name=${1:?missing event name}

    # Keep at least one event period.
    local limit=$((RANDOM % 5 + 1))
    export "LIMIT_${event_name^^}=$limit"

    # Generate enough snapshots to have at least one that will be pruned.
    local total=$((limit + RANDOM % 10 + 1))

    local count=0
    local event_start
    # Work backward chronologically through all the snapshots. As soon as the
    # limit is reached, start accumulating delete messages for the snapshots
    # that will be pruned.
    while read -r event_start; do
        mkdir -p -- "$SNAPSHOTS/$event_start"
        if ((count++ >= limit)); then
            printf "fake btrfs subvolume delete -- %s\n" "$_"
        fi
    done < <(timestamp_seq "$TIMESTAMP" "${event_increment[$event_name]}" "$total" | tac) >"$BATS_TEST_TMPDIR"/output

    run -0 do_prune
    assert_output - <"$BATS_TEST_TMPDIR"/output
}

test_limit_earliest() {
    local event_name=${1:?missing event name}

    export "LIMIT_${event_name^^}=1"

    # Generate enough snapshots to have at least one that will be pruned.
    export total=$((RANDOM % 5 + 2))

    local count=$total
    local timestamp
    # Work backward chronologically through all the snapshots. Accumulate
    # delete messages for snapshots except for the single earliest snapshot.
    while read -r timestamp; do
        mkdir -p -- "$SNAPSHOTS/$timestamp"
        if ((count-- > 1)); then
            printf "fake btrfs subvolume delete -- %s\n" "$_"
        fi
    done < <(timestamp_seq "$TIMESTAMP" "1 second" "$total" | tac) >"$BATS_TEST_TMPDIR"/output

    run -0 do_prune
    assert_output - <"$BATS_TEST_TMPDIR"/output
}

for event_name in "${EVENT_NAMES[@]}"; do
    bats_test_function --description "keeps no $event_name snapshots if limit is not set" -- \
        test_limit_unset "$event_name"

    bats_test_function --description "keeps no $event_name snapshots if limit is zero" -- \
        test_limit_zero "$event_name"

    bats_test_function --description "keeps only the latest $event_name snapshots" -- \
        test_limit_latest "$event_name"

    bats_test_function --description "keeps only the earliest snapshot in $event_name periods" -- \
        test_limit_earliest "$event_name"
done

declare -gA event_increment_inner=(
    [hourly]=${event_increment[minutely]}
    [daily]=${event_increment[hourly]}
    [weekly]=${event_increment[daily]}
    [monthly]=${event_increment[weekly]}
    [quarterly]=${event_increment[monthly]}
    [yearly]=${event_increment[quarterly]}
)

test_event_claim_order() {
    local event_name1=${1:?missing first event name}
    local event_name2=${2:?missing second event name}

    local step=${event_increment[$event_name2]}

    local offset_value offset_unit
    read -r offset_value offset_unit <<<"${event_increment_inner[$event_name2]}"

    local snapshot1 snapshot2 snapshot3
    # Earliest for both its $event_name1 and $event_name2.
    snapshot1=$SNAPSHOTS/$(timestamp -d "$TIMESTAMP + $step - $((2 * offset_value)) $offset_unit")

    # Earliest for only its $event_name1.
    snapshot2=$SNAPSHOTS/$(timestamp -d "$TIMESTAMP + $step - $offset_value $offset_unit")

    # Earliest for both its $event_name1 and $event_name2.
    snapshot3=$SNAPSHOTS/$(timestamp -d "$TIMESTAMP + $step")

    export LIMIT_"${event_name1^^}"=1
    export LIMIT_"${event_name2^^}"=2

    # For example, if the following parameters are used:
    #
    #   event_name1 is hourly (1 spot available)
    #   event_name2 is daily (2 spots available)
    #
    # The following snapshots are created:
    #
    #   snapshot1 @ 2001-01-01T22:00:00Z (earliest for both its hour and day)
    #   snapshot2 @ 2001-01-01T23:00:00Z (earliest only for its hour)
    #   snapshot3 @ 2001-01-02T00:00:00Z (earliest for both its hour and day)
    #
    # If, as expected, hourly spots are filled before daily, pruning will happen as follows:
    #
    #   Snapshot 3 claims the only hourly spot since it's the first for its hour.
    #   Snapshot 2 isn't the first for its day and the only hourly spot is claimed.
    #   Snapshot 1 claims a daily spot since there isn't an earlier snapshot (for any event).
    #
    # Result: Snapshot 2 is deleted.

    mkdir -p -- "$snapshot1" "$snapshot2" "$snapshot3"

    run -0 do_prune
    assert_output "fake btrfs subvolume delete -- $snapshot2"

    # If, instead, daily spots are filled before hourly, pruning would happen as follows:
    #
    #   Snapshot 3 claims a daily spot.
    #   Snapshot 2 can't claim the remaining daily spot, so it claims the only hourly spot.
    #   Snapshot 1 claims the remaining daily spot.
    #
    # Result: All snapshots survive.
}

event_claim_order=(minutely hourly daily weekly monthly quarterly yearly)

for ((i = 0; i < ${#event_claim_order[@]} - 1; i++)); do
    bats_test_function --description "${event_claim_order[i]} spots are claimed before ${event_claim_order[i + 1]}" -- \
        test_event_claim_order "${event_claim_order[i]}" "${event_claim_order[i + 1]}"
done
