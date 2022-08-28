assert_set() {
    local variable=$1
    if [[ ! -v $variable ]]; then
        printf "$TEXT_ASSERT_SET\n" "$variable" >&2
        stack_trace >&2
        return 1
    fi
}

assert_not_set() {
    local variable=$1
    if [[ -v $variable ]]; then
        printf "$TEXT_ASSERT_NOT_SET\n" "$variable" "${!variable}" >&2
        stack_trace >&2
        return 1
    fi
}

assert_equal() {
    local actual=$1
    local expected=$2

    if [[ $actual != "$expected" ]]; then
        printf "$TEXT_ASSERT_EQUAL\n" "$actual" "$expected" >&2
        stack_trace >&2
        return 1
    fi
}

assert_not_equal() {
    local actual=$1
    local expected=$2

    if [[ $actual == "$expected" ]]; then
        printf "$TEXT_ASSERT_NOT_EQUAL\n" "$actual" "$expected" >&2
        stack_trace >&2
        return 1
    fi
}

assert_success() {
    if ! "$@"; then
        printf "$TEXT_ASSERT_SUCCESS\n" >&2
        stack_trace >&2
        return 1
    fi
}

assert_failure() {
    if "$@"; then
        printf "$TEXT_ASSERT_FAILURE\n" >&2
        stack_trace >&2
        return 1
    fi
}

assert_no_output() {
    assert_output "" "" "$@"
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

    local result=0
    "$@" >"$actual_stdout_file" 2>"$actual_stderr_file" || result=$?

    printf "%s" "$expected_stdout" >"$expected_stdout_file"
    printf "%s" "$expected_stderr" >"$expected_stderr_file"

    local different=()

    for stream in stdout stderr; do
        actual_file_name=actual_${stream}_file
        expected_file_name=expected_${stream}_file
        if ! diff -u "${!actual_file_name}" "${!expected_file_name}"; then
            different+=("$stream")
        fi
    done

    if ((${#different[@]} > 0)); then
        printf "$TEXT_ASSERT_OUTPUT\n" "${different[*]}" >&2
        stack_trace >&2
        return 1
    fi

    return "$result"
}

assert_exists() {
    local path=$1
    if [[ ! -e $path ]]; then
        printf "$TEXT_ASSERT_PATH_EXISTS\n" "$path" >&2
        stack_trace >&2
        return 1
    fi
}

assert_not_exists() {
    local path=$1
    if [[ -e $path ]]; then
        printf "$TEXT_ASSERT_PATH_NOT_EXISTS\n" "$path" >&2
        stack_trace >&2
        return 1
    fi
}

assert_file() {
    local file=$1
    if [[ ! -f $file ]]; then
        printf "$TEXT_ASSERT_FILE_EXISTS\n" "$file" >&2
        stack_trace >&2
        return 1
    fi
}

assert_no_file() {
    local file=$1
    if [[ -f $file ]]; then
        printf "$TEXT_ASSERT_FILE_NOT_EXISTS\n" "$file" >&2
        stack_trace >&2
        return 1
    fi
}

assert_file_content() {
    local file=$1
    local content=$2

    local expected_file=$TEMP_DIR/expected-content

    printf "%s" "$content" >"$expected_file"

    if ! diff -u "$file" "$expected_file"; then
        printf "$TEXT_ASSERT_FILE_CONTENTS" >&2
        stack_trace >&2
        return 1
    fi
}

assert_directory() {
    local directory=$1
    if [[ ! -d $directory ]]; then
        printf "$TEXT_ASSERT_DIRECTORY_EXISTS\n" "$directory" >&2
        stack_trace >&2
        return 1
    fi
}

assert_no_directory() {
    local directory=$1
    if [[ -d $directory ]]; then
        printf "$TEXT_ASSERT_DIRECTORY_NOT_EXISTS\n" "$directory" >&2
        stack_trace >&2
        return 1
    fi
}
