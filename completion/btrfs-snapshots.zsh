#compdef btrfs-snapshots

local context state state_descr line opt_args

_arguments -s -S -A "-*" : \
    "(- : *)-h[show the help text]" \
    "-p[select a profile]:profile:->profile" \
    "-C[set the configuration directory]:configuration directory:_files -/" \
    '1::action:((
        "create:create a new snapshot"
        "prune:delete old snapshots"
    ))' \
    && return

case $state in
profile)
    local config_dir
    if (( $+opt_args[-C] )); then
        config_dir=$opt_args[-C]
    else
        config_dir=${BTRFS_SNAPSHOTS_CONFIG_DIR:-/usr/local/etc/btrfs-snapshots}
    fi

    local -a profile_names=($config_dir/profile.d/*.conf(N:r:t))
    (($#profile_names)) && _values 'profiles' $profile_names
    ;;
esac
