export TEXT_USAGE="Manage timestamped collections of btrfs snapshots.

Usage:
    btrfs-snapshots -h
    btrfs-snapshots [-n] [-p NAME]... [ACTION]

Options:
    -h         show this help text
    -n         only report what would happen (no changes are made)
    -p NAME    perform ACTION on the NAME profile (default: all)

Arguments:
    ACTION     perform ACTION on the selected profiles (default: list)

Actions:
    list       print the full path of every recognized snapshot
    create     create a new timestamped snapshot in the configured location
    prune      delete any snapshots that fall outside of the defined limits

If no profiles are specified with -p, then every profile is selected.
"

export TEXT_INVALID="Invalid %NAME%: %VALUE%"

export TEXT_PROFILE_NOT_EXIST="Profile does not exist: %PROFILE_NAME%"
export TEXT_PROFILE_VARIABLE_NOT_SET="Invalid profile '%PROFILE_NAME%': %VARIABLE% is not set"
export TEXT_PROFILE_ABS_PATH="Invalid profile '%PROFILE_NAME%': %VARIABLE% must be an absolute path"
export TEXT_PROFILE_SNAPSHOTS_UNIQUE="Invalid profile '%PROFILE_NAME%': SNAPSHOTS value is already defined in another profile"
export TEXT_PROFILE_FAILED="Unable to load profile '%PROFILE_FILE%'"

export TEXT_DEFAULTS_SUBVOLUME="Invalid defaults: SUBVOLUME must be set in the profile configuration"
export TEXT_DEFAULTS_SNAPSHOTS_MISSING_NAME="Invalid defaults: SNAPSHOTS is missing %NAME% placeholder"
export TEXT_DEFAULTS_FAILED="Unable to load defaults: %DEFAULTS_FILE%"

export TEXT_ACTION="Performing action '%ACTION%' for profile '%PROFILE_NAME%'"
export TEXT_ACTION_FAILED="Unable to perform action '%ACTION%'"

export TEXT_CREATE_SUBVOLUME_MISSING="Skipping profile '%PROFILE_NAME%': subvolume is missing"

export TEXT_BTRFS_FAILED="The btrfs command errored with status code '%STATUS%'"
