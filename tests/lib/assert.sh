assert_set() {
    local variable=$1
    if [[ ! -v $variable ]]; then
        die "should have been set: $variable"
    fi
}

assert_equal() {
    local actual=$1
    local expected=$2

    if [[ $actual != "$expected" ]]; then
        die "should have been equal: $actual != $expected"
    fi
}

assert_success() {
    if ! "$@"; then
        die "should have succeeded"
    fi
}

assert_failure() {
    if "$@"; then
        die "should have failed"
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
            die "$output should have been equal"
        fi
    done

    return "$result"
}

assert_file() {
    local file=$1
    if [[ ! -f $file ]]; then
        die "file should exist: $file"
    fi
}

assert_no_file() {
    local file=$1
    if [[ -f $file ]]; then
        die "file should not exist: $file"
    fi
}

assert_directory() {
    local directory=$1
    if [[ ! -d $directory ]]; then
        die "directory should exist: $directory"
    fi
}

assert_no_directory() {
    local directory=$1
    if [[ -d $directory ]]; then
        die "directory should not exist: $directory"
    fi
}

assert_exists() {
    local path=$1
    if [[ ! -e $path ]]; then
        die "path should exist: $path"
    fi
}

assert_not_exists() {
    local path=$1
    if [[ -e $path ]]; then
        die "path should not exist: $path"
    fi
}

assert_file_content() {
    local file=$1
    local content=$2

    local expected_file=$TEMP_DIR/expected-content

    echo -n "$content" >"$expected_file"

    if ! diff -u "$file" "$expected_file"; then
        die "$output should have been equal"
    fi
}
