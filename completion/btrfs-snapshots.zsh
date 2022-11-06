#compdef btrfs-snapshots

local state state_descr context line opt_args

_arguments -s -S -A "-*" : \
    "(- : *)-h[show the help text]" \
    "(-h)-p[select a profile]:profile:->profile" \
    "(-h)-C[set the configuration directory]:configuration directory:_files -/" \
    '(-h)::action:((
        "create:create a new snapshot"
        "prune:delete old snapshots"
    ))' \
    && return

if [[ $state == profile ]]; then
    local config_dir
    if (( $+opt_args[-C] )); then
        config_dir=$opt_args[-C]
    else
        config_dir=${BTRFS_SNAPSHOTS_CONFIG_DIR:-/usr/local/etc/btrfs-snapshots}
    fi
    local -a profile_names=($config_dir/profile.d/*.conf(N:r:t))
    (($#profile_names)) && _values 'profiles' $profile_names
fi
