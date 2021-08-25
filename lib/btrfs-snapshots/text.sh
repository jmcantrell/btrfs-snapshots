export TEXT_USAGE="Manage btrfs file system snapshots based on retention policies.

Usage: btrfs-snapshots [OPTIONS] ACTION

Options:
    -h         show this help message
    -n         only report what would happen (no changes are made)
    -p NAME    only perform ACTION on the NAME profile (default: all)

Arguments:
    ACTION     perform ACTION on the selected profiles

Actions:
    create     create a new snapshot
    prune      delete any snapshots that fall outside of the defined limits
"

export TEXT_MISSING="missing %NAME%"
export TEXT_INVALID="invalid %NAME%: %VALUE%"
export TEXT_SINGLETON="only one instance is allowed to run at a time"

export TEXT_CONFIG_FAILED="unable to load configuration"

export TEXT_PROFILE_NOT_EXIST="profile does not exist: %PROFILE_NAME%"
export TEXT_PROFILE_NOT_SET="invalid profile: %PROFILE_NAME%; %VARIABLE% is not set"
export TEXT_PROFILE_ABS_PATH="invalid profile: %PROFILE_NAME%; %VARIABLE% must be an absolute path"
export TEXT_PROFILE_MISSING="skipping profile: %PROFILE_NAME%; subvolume is missing"
export TEXT_PROFILE_FAILED="unable to load profile: %PROFILE_FILE%"

export TEXT_CREATE="creating snapshot: profile=%PROFILE_NAME% timestamp=%TIMESTAMP%"
export TEXT_PRUNE="deleting snapshot: profile=%PROFILE_NAME% timestamp=%TIMESTAMP%"

export TEXT_ACTION_FAILED="unable to perform action: %ACTION%"

export TEXT_BTRFS_FAILED="btrfs exited with a non-zero status: %STATUS%"
