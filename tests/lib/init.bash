export SELF_NAME=test
export LIB_DIR=$PWD/lib
export PATH=$PWD/bin:$PATH

source ./tests/lib/timestamp.bash

bats_require_minimum_version 1.5.0

bats_load_library bats-support
bats_load_library bats-assert
bats_load_library bats-file
