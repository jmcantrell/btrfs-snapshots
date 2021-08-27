export TEXT_USAGE="Manage timestamped collections of btrfs snapshots.

Usage: btrfs-snapshots [OPTIONS] ACTION

Options:
    -h         show this help message
    -n         only report what would happen (no changes are made)
    -p NAME    only perform ACTION on the NAME profile (default: all)

Arguments:
    ACTION     perform ACTION on the selected profiles (default: list)

Actions:
    create     create a new snapshot
    list       print the full path of every recognized snapshot
    prune      delete any snapshots that fall outside of the defined limits
"

export TEXT_INVALID="Invalid %NAME%: %VALUE%"

export TEXT_PROFILE_NOT_EXIST="Profile does not exist: %PROFILE_NAME%"
export TEXT_PROFILE_VARIABLE_NOT_SET="Invalid profile '%PROFILE_NAME%': %VARIABLE% is not set"
export TEXT_PROFILE_ABS_PATH="Invalid profile '%PROFILE_NAME%': %VARIABLE% must be an absolute path"
export TEXT_PROFILE_FAILED="Unable to load profile '%PROFILE_FILE%'"

export TEXT_CONFIG_FAILED="Unable to load configuration: %CONFIG_FILE%"

export TEXT_ACTION="Performing action '%ACTION%' for profile '%PROFILE_NAME%'"
export TEXT_ACTION_FAILED="Unable to perform action '%ACTION%'"

export TEXT_CREATE_SUBVOLUME_MISSING="Skipping profile '%PROFILE_NAME%': subvolume is missing"

export TEXT_BTRFS_FAILED="The btrfs command errored with status code '%STATUS%'"
