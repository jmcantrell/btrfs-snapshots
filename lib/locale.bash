export TEXT_USAGE="Manage timestamped collections of btrfs snapshots.

Usage:
    btrfs-snapshots [OPTIONS] ACTION

Options:
    -h, -?, --help                show this help text
    -p, --profile=NAME            profile to perform action on
    -C, --config-dir=DIRECTORY    directory to use for configuration

Arguments:
    ACTION    action to perform on selected profiles

Actions:
    create    create a new snapshot in the configured location
    prune     delete snapshots that fall outside of defined limits

If no profiles are specified with -p/--profile, then every profile is selected."

export TEXT_OPTION_INVALID="Invalid option: %s"
export TEXT_OPTION_MISSING_ARGUMENT="Option requires an argument: %s"
export TEXT_ACTION_MISSING="The first argument must be an action"
export TEXT_ACTION_INVALID="Invalid action: %s"
export TEXT_ACTION_FAILED="Unable to perform action: %s"
export TEXT_PROFILE_MISSING="Profile does not exist: %q"
export TEXT_PROFILE_VARIABLE_NOT_SET="Invalid profile: %q\n- %s is not set"
export TEXT_PROFILE_PATH_NOT_ABSOLUTE="Invalid profile: %q\n- %s must be an absolute path: %q"
export TEXT_PROFILE_SUBVOLUME_MISSING="Skipping profile: %q\n- Subvolume is not available: %q"
export TEXT_PROFILE_LOAD_FAILED="Unable to load profile: %q"
export TEXT_PROFILE_VALIDATION_FAILED="There was a problem while validating profiles"
export TEXT_PROFILE_SNAPSHOTS_NOT_UNIQUE="The same value for SNAPSHOTS is used for multiple profiles: %q"
export TEXT_DEFAULTS_SNAPSHOTS_MISSING_PLACEHOLDER="Invalid defaults: %q\n- SNAPSHOTS is missing the %%s placeholder"
export TEXT_SOURCE_FAILED="Unable to source file: %q"
export TEXT_BTRFS_FAILED="The btrfs command exited with non-zero status code: %s"
