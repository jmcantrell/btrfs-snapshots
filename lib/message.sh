export TEXT_USAGE="Manage timestamped collections of btrfs snapshots.

Usage:
    btrfs-snapshots -h
    btrfs-snapshots [-p NAME]... [ACTION]

Options:
    -h              show this help text
    -p NAME         profile to perform action on (can be used multiple times)
    -C DIRECTORY    directory to use for configuration

Arguments:
    ACTION          action to perform on selected profiles (default: list)

Actions:
    list            print full path of every recognized snapshot
    create          create a new snapshot in the configured location
    prune           delete snapshots that fall outside of defined limits

If no profiles are specified with -p, then every profile is selected."

export TEXT_INVALID="Invalid %s '%s'"

export TEXT_PROFILE_NOT_EXIST="Profile '%s' does not exist"
export TEXT_PROFILE_VARIABLE_NOT_SET="Invalid profile '%s'; %s is not set"
export TEXT_PROFILE_ABS_PATH="Invalid profile '%s'; %s must be an absolute path"
export TEXT_PROFILE_SNAPSHOTS_UNIQUE="Invalid profile '%s'; SNAPSHOTS value is already defined in another profile"
export TEXT_PROFILE_LOAD_FAILED="Unable to load profile '%s'"

export TEXT_DEFAULTS_SNAPSHOTS_MISSING_PLACEHOLDER="Invalid defaults; SNAPSHOTS is missing a %%s placeholder"
export TEXT_DEFAULTS_LOAD_FAILED="Unable to load defaults '%s'"

export TEXT_ACTION_FAILED="Unable to perform action '%s'"

export TEXT_CREATE_SUBVOLUME_MISSING="Skipping profile '%s'; subvolume is missing"

export TEXT_BTRFS_FAILED="The btrfs command exited with status code '%s'"
