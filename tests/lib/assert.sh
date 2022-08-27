assert_set() {
    local variable=$1
    if [[ ! -v $variable ]]; then
        printf "Variable '%s' should have been set\n" "$variable" >&2
        return 1
    fi
}

assert_equal() {
    local actual=$1
    local expected=$2

    if [[ $actual != "$expected" ]]; then
        printf "Values should have been equal: %s != %s\n" "$actual" "$expected" >&2
        return 1
    fi
}

assert_success() {
    if ! "$@"; then
        printf "Command should have succeeded\n" >&2
        return 1
    fi
}

assert_failure() {
    if "$@"; then
        printf "Command should have failed\n" >&2
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

    local different=0

    for output in stdout stderr; do
        actual_file_name=actual_${output}_file
        expected_file_name=expected_${output}_file
        if ! diff -u "${!actual_file_name}" "${!expected_file_name}"; then
            different=1
            printf "Command output for %s should have been equal\n" "$output" >&2
        fi
    done

    ((different)) && return 1

    return "$result"
}

assert_file() {
    local file=$1
    if [[ ! -f $file ]]; then
        printf "File '%s' should exist\n" "$file" >&2
        return 1
    fi
}

assert_no_file() {
    local file=$1
    if [[ -f $file ]]; then
        printf "File '%s' should not exist\n" "$file" >&2
        return 1
    fi
}

assert_directory() {
    local directory=$1
    if [[ ! -d $directory ]]; then
        printf "Directory '%s' should exist\n" "$directory" >&2
        return 1
    fi
}

assert_no_directory() {
    local directory=$1
    if [[ -d $directory ]]; then
        printf "Directory '%s' should not exist\n" "$directory" >&2
        return 1
    fi
}

assert_exists() {
    local path=$1
    if [[ ! -e $path ]]; then
        printf "Path '%s' should exist\n" "$path" >&2
        return 1
    fi
}

assert_not_exists() {
    local path=$1
    if [[ -e $path ]]; then
        printf "Path '%s' should not exist\n" "$path" >&2
        return 1
    fi
}

assert_file_content() {
    local file=$1
    local content=$2

    local expected_file=$TEMP_DIR/expected-content

    printf "%s" "$content" >"$expected_file"

    if ! diff -u "$file" "$expected_file"; then
        printf "File contents should have been equal\n" >&2
        return 1
    fi
}

assert_arrays_equal() {
    local -n array1=$1
    local -n array2=$2

    if ((${#array1[@]} != ${#array2[@]})); then
        printf "Arrays should be the same length: %d != %d\n" "${#array1[@]}" "${#array2[@]}" >&2
        return 1
    else
        local i
        for ((i = 0; i < ${#array1[@]}; i++)); do
            if [[ ${array1[i]} != "${array2[i]}" ]]; then
                printf "Array items at index %d should be equal: %s != %s\n" "$i" "${array1[i]}" "${array2[i]}" >&2
                return 1
            fi
        done
    fi
}
