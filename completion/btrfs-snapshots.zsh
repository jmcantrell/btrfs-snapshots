#compdef btrfs-snapshots

local state state_descr context line opt_args
local config_dir=${BTRFS_SNAPSHOTS_CONFIG_DIR:-/usr/local/etc/btrfs-snapshots}

_arguments -S \
    "(- 1)"{-h,-\?,--help}"[show the help text]" \
    {-p,--profile}"[select a profile]:profile:->profile" \
    {-C,--config-dir}"[set the configuration directory]:configuration directory:_files -/" \
    "(-)::action:(create prune)" \
    && return 0

(( $+opt_args[-C] )) && config_dir=$opt_args[-C]

if [[ $state == profile ]]; then
    local -a profile_names=($config_dir/profile.d/*.conf(N:r:t))
    (($#profile_names)) && _values 'profiles' $profile_names
fi
