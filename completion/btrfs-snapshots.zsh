#compdef btrfs-snapshots

local state state_descr context line opt_args

_arguments -S \
    "(-n -p 1)-h[show the help text]" \
    "(-h)-n[only report what would happen]" \
    "(-h)*-p[select a profile]:profile:->profile" \
    "(-h -n -p)::action:(list create prune)" \
    && return 0

if [[ $state == profile ]]; then
    _values 'profiles' /usr/local/etc/btrfs-snapshots/profiles.d/*.conf(N:r:t)
fi
