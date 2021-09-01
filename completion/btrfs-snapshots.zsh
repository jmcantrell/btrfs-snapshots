#compdef btrfs-snapshots

local state state_descr context line opt_args

_arguments -S \
    "(-p 1)-h[show the help text]" \
    "(-h)*-p[select a profile]:profile:->profile" \
    "(-h -p)::action:(list create prune)" \
    && return 0

if [[ $state == profile ]]; then
    _values 'profiles' "${BTRFS_SNAPSHOTS_ETC_DIR:-/usr/local/etc/btrfs-snapshots}"/profiles.d/*.conf(N:r:t)
fi
