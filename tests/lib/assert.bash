stack_trace() {
    local -i depth=0
    while caller "$((depth++))"; do :; done | tac
}

track_exit_status() {
    local -i actual=0
    "$@" || actual=$?
    declare -gi REPLY=$actual
    return "$REPLY"
}

capture_output() {
    local stdout_file=$1
    local stderr_file=$2
    shift 2
    "$@" >"$stdout_file" 2>"$stderr_file"
}

capture_stdout() {
    local stdout_file=$1
    shift
    capture_output "$stdout_file" /dev/stderr "$@"
}

capture_stderr() {
    local stderr_file=$1
    shift
    capture_output /dev/stdout "$stderr_file" "$@"
}

assert_set() {
    local variable=$1
    if [[ ! -v $variable ]]; then
        printf "variable should have been set: %s\n" "$variable" >&2
        stack_trace >&2
        return 1
    fi
}

assert_not_set() {
    local variable=$1
    if [[ -v $variable ]]; then
        printf "variable should not have been set: %s=%s\n" "$variable" "${!variable}" >&2
        stack_trace >&2
        return 1
    fi
}

assert_equal() {
    local actual=$1
    local expected=$2
    if [[ $actual != "$expected" ]]; then
        printf "values should have been equal: %s != %s\n" "$actual" "$expected" >&2
        stack_trace >&2
        return 1
    fi
}

assert_not_equal() {
    local actual=$1
    local expected=$2
    if [[ $actual == "$expected" ]]; then
        printf "values should not have been equal: %s == %s\n" "$actual" "$expected" >&2
        stack_trace >&2
        return 1
    fi
}

assert_arrays_equal() {
    local -n _array1=${1:?missing first array}
    local -n _array2=${2:?missing second array}

    if ((${#_array1[@]} != ${#_array2[@]})); then
        printf "arrays differ in length: %d != %d\n" "${#_array1[@]}" "${#_array2[@]}" >&2
        stack_trace >&2
        return 1
    fi

    local -i i
    for ((i = 0; i < ${#_array1[@]}; i++)); do
        if [[ ${_array1[$i]} != "${_array2[$i]}" ]]; then
            printf "array items for index %d should have been equal: %s != %s\n" "$i" "${_array1[$i]}" "${_array2[$i]}" >&2
            stack_trace >&2
            return 1
        fi
    done
}

assert_match() {
    local actual=$1
    local expected_pattern=$2
    if [[ ! $actual =~ $expected_pattern ]]; then
        printf "values should have matched: %s != %s\n" "$actual" "$expected_pattern" >&2
        stack_trace >&2
        return 1
    fi
}

assert_not_match() {
    local actual=$1
    local expected_pattern=$2
    if [[ $actual =~ $expected_pattern ]]; then
        printf "values should not have matched: %s == %s\n" "$actual" "$expected_pattern" >&2
        stack_trace >&2
        return 1
    fi
}

assert_exit_status() {
    local -i expected=$1
    shift
    track_exit_status "$@" || true
    local -i actual=$REPLY
    if ((actual != expected)); then
        printf "exit status should have been %d, but was %d\n" "$expected" "$actual" >&2
        stack_trace >&2
        return 1
    fi
}

assert_success() {
    if ! track_exit_status "$@"; then
        printf "command should have succeeded, but it exited with status %d\n" "$REPLY" >&2
        stack_trace >&2
        return 1
    fi
}

assert_failure() {
    if track_exit_status "$@"; then
        printf "command should have failed\n" >&2
        stack_trace >&2
        return 1
    fi
}

assert_no_output() {
    assert_output "" "" "$@"
}

assert_no_stdout() {
    assert_output_match "" ".*" "$@"
}

assert_no_stderr() {
    assert_output_match ".*" "" "$@"
}

assert_stdout() {
    local expected=$1
    shift
    assert_output "$expected" "" "$@"
}

assert_stderr() {
    local expected=$1
    shift
    assert_output "" "$expected" "$@"
}

assert_output() {
    local expected_stdout=$1
    local expected_stderr=$2
    shift 2

    local actual_stdout_file=$TEMP_DIR/actual-stdout
    local actual_stderr_file=$TEMP_DIR/actual-stderr

    local expected_stdout_file=$TEMP_DIR/expected-stdout
    local expected_stderr_file=$TEMP_DIR/expected-stderr

    track_exit_status capture_output "$actual_stdout_file" "$actual_stderr_file" "$@"
    local -i exit_status=$REPLY

    printf "%s" "$expected_stdout" >"$expected_stdout_file"
    printf "%s" "$expected_stderr" >"$expected_stderr_file"

    local -a different=()

    local stream
    for stream in stdout stderr; do
        local actual_file_name=actual_${stream}_file
        local expected_file_name=expected_${stream}_file
        if ! diff -u "${!actual_file_name}" "${!expected_file_name}"; then
            different+=("$stream")
        fi
    done

    if ((${#different[@]} > 0)); then
        printf "command output streams should have been equal: %s\n" "${different[*]}" >&2
        stack_trace >&2
        return 1
    fi

    return "$exit_status"
}

assert_output_glob_match() {
    local expected_stdout_pattern=$1
    local expected_stderr_pattern=$2
    shift 2

    local actual_stdout_file=$TEMP_DIR/actual-stdout
    local actual_stderr_file=$TEMP_DIR/actual-stderr

    track_exit_status capture_output "$actual_stdout_file" "$actual_stderr_file" "$@"
    local -i exit_status=$REPLY

    local actual_output

    if [[ -n $expected_stdout_pattern ]]; then
        actual_output=$(<"$actual_stdout_file")
        # shellcheck disable=SC2053
        if [[ $actual_output != $expected_stdout_pattern ]]; then
            printf "expected stdout to match: %s\n" "$expected_stdout_pattern" >&2
            printf "actual stdout:\n" >&2
            printf "%s\n" "$actual_output" >&2
            stack_trace >&2
            return 1
        fi
    fi

    if [[ -n $expected_stderr_pattern ]]; then
        actual_output=$(<"$actual_stderr_file")
        # shellcheck disable=SC2053
        if [[ $actual_output != $expected_stderr_pattern ]]; then
            printf "expected stderr to match: %s\n" "$expected_stderr_pattern" >&2
            printf "actual stderr:\n" >&2
            printf "%s\n" "$actual_output" >&2
            stack_trace >&2
            return 1
        fi
    fi

    return "$exit_status"
}

assert_output_match() {
    local expected_stdout_pattern=$1
    local expected_stderr_pattern=$2
    shift 2

    local actual_stdout_file=$TEMP_DIR/actual-stdout
    local actual_stderr_file=$TEMP_DIR/actual-stderr

    track_exit_status capture_output "$actual_stdout_file" "$actual_stderr_file" "$@"
    local -i exit_status=$REPLY

    local actual_output

    if [[ -n $expected_stdout_pattern ]]; then
        actual_output=$(<"$actual_stdout_file")
        if [[ ! $actual_output =~ $expected_stdout_pattern ]]; then
            printf "expected stdout to match: %s\n" "$expected_stdout_pattern" >&2
            printf "actual stdout:\n" >&2
            printf "%s\n" "$actual_output" >&2
            stack_trace >&2
            return 1
        fi
    fi

    if [[ -n $expected_stderr_pattern ]]; then
        actual_output=$(<"$actual_stderr_file")
        if [[ ! $actual_output =~ $expected_stderr_pattern ]]; then
            printf "expected stderr to match: %s\n" "$expected_stderr_pattern" >&2
            printf "actual stderr:\n" >&2
            printf "%s\n" "$actual_output" >&2
            stack_trace >&2
            return 1
        fi
    fi

    return "$exit_status"
}

assert_stdout_match() {
    local expected_stdout_pattern=$1
    shift
    assert_output_match "$expected_stdout_pattern" "" "$@"
}

assert_stderr_match() {
    local expected_stderr_pattern=$1
    shift
    assert_output_match "" "$expected_stderr_pattern" "$@"
}

assert_exists() {
    local path=$1
    if [[ ! -e $path ]]; then
        printf "path should exist: %s\n" "$path" >&2
        stack_trace >&2
        return 1
    fi
}

assert_not_exists() {
    local path=$1
    if [[ -e $path ]]; then
        printf "path should not exist: %s\n" "$path" >&2
        stack_trace >&2
        return 1
    fi
}

assert_file() {
    local file=$1
    if [[ ! -f $file ]]; then
        printf "file should exist: %s\n" "$file" >&2
        stack_trace >&2
        return 1
    fi
}

assert_no_file() {
    local file=$1
    if [[ -f $file ]]; then
        printf "file should not exist: %s\n" "$file" >&2
        stack_trace >&2
        return 1
    fi
}

assert_file_content() {
    local file=$1
    local expected_content=$2

    local expected_file=$TEMP_DIR/expected-content
    printf "%s" "$expected_content" >"$expected_file"

    if ! diff -u "$file" "$expected_file"; then
        printf "file contents should have been equal\n" >&2
        stack_trace >&2
        return 1
    fi
}

assert_directory() {
    local directory=$1
    if [[ ! -d $directory ]]; then
        printf "directory should exist: %s\n" "$directory" >&2
        stack_trace >&2
        return 1
    fi
}

assert_no_directory() {
    local directory=$1
    if [[ -d $directory ]]; then
        printf "directory should not exist: %s\n" "$directory" >&2
        stack_trace >&2
        return 1
    fi
}
