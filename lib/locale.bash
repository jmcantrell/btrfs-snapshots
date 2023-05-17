export TEXT_USAGE="Manage timestamped collections of btrfs snapshots.

Usage:
    btrfs-snapshots [OPTIONS] ACTION

Options:
    -h              show this help text and exit
    -p NAME         perform action on profile NAME
    -C DIRECTORY    use DIRECTORY for configuration

Arguments:
    ACTION          action to perform on selected profiles

Actions:
    create          create a new snapshot in the configured location
    prune           delete snapshots that fall outside of defined limits

If no profiles are specified with -p, then every profile is selected.
"

export TEXT_OPTION_INVALID="invalid option: -%s"
export TEXT_OPTION_MISSING_ARGUMENT="option requires an argument: -%s"
export TEXT_ACTION_MISSING="the first argument must be an action"
export TEXT_ACTION_INVALID="invalid action: %s"
export TEXT_ACTION_FAILED="unable to perform action: %s"
export TEXT_PROFILE_MISSING="profile does not exist: %q"
export TEXT_PROFILE_VARIABLE_NOT_SET="invalid profile: %q\n- %s is not set"
export TEXT_PROFILE_PATH_NOT_ABSOLUTE="invalid profile: %q\n- %s must be an absolute path: %q"
export TEXT_PROFILE_SUBVOLUME_MISSING="skipping profile: %q\n- Subvolume is not available: %q"
export TEXT_PROFILE_LOAD_FAILED="unable to load profile: %q"
export TEXT_PROFILE_VALIDATION_FAILED="there was a problem while validating profiles"
export TEXT_PROFILE_SNAPSHOTS_NOT_UNIQUE="the same value for SNAPSHOTS is used for multiple profiles: %q"
export TEXT_DEFAULTS_SNAPSHOTS_MISSING_PLACEHOLDER="invalid defaults: %q\n- SNAPSHOTS is missing the %%s placeholder"
export TEXT_SOURCE_FAILED="unable to source file: %q"
export TEXT_BTRFS_FAILED="the btrfs command exited with non-zero status code: %s"
