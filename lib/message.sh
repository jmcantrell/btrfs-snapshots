export TEXT_USAGE="Manage timestamped collections of btrfs snapshots.

Usage:
    btrfs-snapshots [OPTIONS] [ACTION]

Options:
    -h, -?, --help                show this help text
    -p, --profile=NAME            profile to perform action on
    -C, --config-dir=DIRECTORY    directory to use for configuration

Arguments:
    ACTION    action to perform on selected profiles

Actions:
    list      print full path of every recognized snapshot
    create    create a new snapshot in the configured location
    prune     delete snapshots that fall outside of defined limits

If no action is specified, then it is assumed to be 'list'.
If no profiles are specified with -p/--profile, then every profile is selected."

export TEXT_OPTION_INVALID="Invalid option: %s"
export TEXT_OPTION_MISSING_ARGUMENT="Option requires an argument: %s"

export TEXT_ACTION_INVALID="Invalid action: %s"
export TEXT_ACTION_FAILED="Unable to perform action: %s"

export TEXT_PROFILE_MISSING="Profile does not exist: %s"
export TEXT_PROFILE_VARIABLE_NOT_SET="Invalid profile: %s (%s is not set)"
export TEXT_PROFILE_PATH_NOT_ABSOLUTE="Invalid profile: %s (%s must be an absolute path)"
export TEXT_PROFILE_SNAPSHOTS_NOT_UNIQUE="Invalid profile: %s (SNAPSHOTS is not unique)"
export TEXT_PROFILE_SUBVOLUME_MISSING="Skipping profile: %s (subvolume is not available: %q)"
export TEXT_PROFILE_LOAD_FAILED="Unable to load profile: %q"

export TEXT_DEFAULTS_SNAPSHOTS_MISSING_PLACEHOLDER="Invalid defaults; SNAPSHOTS is missing a %%s placeholder"

export TEXT_SOURCE_FAILED="Unable to source file: %q"

export TEXT_BTRFS_FAILED="The btrfs command exited with non-zero status code: %s"
