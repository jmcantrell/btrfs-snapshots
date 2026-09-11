#!/usr/bin/env bash

set -euo pipefail

if [[ -v TEST_FAKE_ERROR_MESSAGE ]]; then
    printf "%s\n" "$TEST_FAKE_ERROR_MESSAGE" >&2
fi

exit "${TEST_FAKE_EXIT_STATUS:-1}"
