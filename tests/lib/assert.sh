assert_set() {
    local variable=$1
    if [[ ! -v $variable ]]; then
        die "Variable '$variable' should have been set"
    fi
}

assert_equal() {
    local actual=$1
    local expected=$2

    if [[ $actual != "$expected" ]]; then
        die "Values should have been equal: $actual != $expected"
    fi
}

assert_success() {
    if ! "$@"; then
        die "Command should have succeeded"
    fi
}

assert_failure() {
    if "$@"; then
        die "Command should have failed"
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

    "$@" >"$actual_stdout_file" 2>"$actual_stderr_file"

    local result=$?

    echo -n "$expected_stdout" >"$expected_stdout_file"
    echo -n "$expected_stderr" >"$expected_stderr_file"

    for output in stdout stderr; do
        actual_file_name=actual_${output}_file
        expected_file_name=expected_${output}_file
        if ! diff -u "${!actual_file_name}" "${!expected_file_name}"; then
            die "Command output for $output should have been equal"
        fi
    done

    return "$result"
}

assert_file() {
    local file=$1
    if [[ ! -f $file ]]; then
        die "File '$file' should exist"
    fi
}

assert_no_file() {
    local file=$1
    if [[ -f $file ]]; then
        die "File '$file' should not exist"
    fi
}

assert_directory() {
    local directory=$1
    if [[ ! -d $directory ]]; then
        die "Directory '$directory' should exist"
    fi
}

assert_no_directory() {
    local directory=$1
    if [[ -d $directory ]]; then
        die "Directory '$directory' should not exist"
    fi
}

assert_exists() {
    local path=$1
    if [[ ! -e $path ]]; then
        die "Path '$path' should exist"
    fi
}

assert_not_exists() {
    local path=$1
    if [[ -e $path ]]; then
        die "Path '$path' should not exist"
    fi
}

assert_file_content() {
    local file=$1
    local content=$2

    local expected_file=$TEMP_DIR/expected-content

    echo -n "$content" >"$expected_file"

    if ! diff -u "$file" "$expected_file"; then
        die "File contents should have been equal"
    fi
}

assert_arrays_equal() {
    local -n array1=$1
    local -n array2=$2

    if ((${#array1[@]} != ${#array2[@]})); then
        die "Arrays should be the same length: ${#array1[@]} != ${#array2[@]}"
    fi

    local i mismatch=0
    for ((i = 0; i < ${#array1[@]}; i++)); do
        if [[ ${array1[i]} != "${array2[i]}" ]]; then
            echo "Array items at index '$i' should match: ${array1[i]} != ${array2[i]}" >&2
            mismatch=1
        fi
    done

    if ((mismatch)); then
        die "Array items should have been equal"
    fi
}
