#compdef btrfs-snapshots

local state state_descr context line opt_args
local config_dir=${BTRFS_SNAPSHOTS_ETC_DIR:-/usr/local/etc/btrfs-snapshots}

_arguments -S \
    "(-p -C 1)-h[show the help text]" \
    "(-h)*-p[select a profile]:profile:->profile" \
    "(-h)-C[set the configuration directory]:configuration directory:_files -/" \
    "(-h -p -C)::action:(list create prune)" \
    && return 0

(( $+opt_args[-C] )) && config_dir=$opt_args[-C]

if [[ $state == profile ]]; then
    local -a profiles=($config_dir/profile.d/*.conf(N:r:t))
    (($#profiles)) && _values 'profiles' $profiles
fi
