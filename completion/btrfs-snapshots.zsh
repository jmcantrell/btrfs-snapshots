#compdef btrfs-snapshots

local curcontext=$curcontext context state state_descr line opt_args

_arguments -C -s -S -A "-*" : \
    "(- : *)--help[show the help text]" \
    ':action:((
        "create\:create a new snapshot"
        "prune\:delete old snapshots"
    ))' \
    "*: :->profile" \
    && return

service=$line[1]
curcontext=${curcontext%:*}-$service

case $state in
profile)
    local config_dir=${BTRFS_SNAPSHOTS_CONFIG_DIR:-/usr/local/etc/btrfs-snapshots}
    local expl names=($config_dir/profile.d/*.conf(N:r:t))
    _wanted values expl "profile" compadd -a names && return
    ;;
esac

return 1
