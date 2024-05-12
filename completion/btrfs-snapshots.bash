_btrfs_snapshots() {
    local cur prev words

    local profiles_dir=${BTRFS_SNAPSHOTS_CONFIG_DIR:-/usr/local/etc/btrfs-snapshots}/profile.d

    local options=(--help)
    local actions=(create prune)

    case $cur in
    -*)
        readarray -t COMPREPLY < <(compgen -W "${options[*]}" -- "$cur")
        ;;
    *)
        if ((${#words[@]} >= 3)); then
            local profile_name profile_names=()
            for profile_file in "$profiles_dir"/*.conf; do
                profile_name=${profile_file##*/}
                profile_name=${profile_name%.conf}
                profile_names+=("$profile_name")
            done

            readarray -t COMPREPLY < <(compgen -W "${profile_names[*]}" -- "$cur")
        else
            readarray -t COMPREPLY < <(compgen -W "${actions[*]}" -- "$cur")
        fi
        ;;
    esac
}

complete -F _btrfs_snapshots btrfs-snapshots
