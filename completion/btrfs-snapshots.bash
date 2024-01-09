__find_array_value() {
    local needle=$1
    shift

    local i=0

    while (($# > 0)); do
        local straw=$1
        shift

        if [[ $straw == "$needle" ]]; then
            printf "%s\n" "$i"
            return 0
        fi

        i=$((i + 1))
    done

    return 1
}

__get_opt_arg() {
    local opt=$1
    shift 1

    local -a words=("$@")

    local i
    if i=$(__find_array_value "$opt" "${words[@]}"); then
        printf "%s\n" "${words[i + 1]}"
        return 0
    fi

    return 1
}

__shallow_basenames() {
    local dir=$1
    local ext=${2:-}

    [[ -d $dir ]] || return 0

    for file in "$dir"/*"${ext:+$ext}"; do
        if [[ -f $file ]]; then
            name=${file##*/}
            name=${name%"$ext"}
            printf "%s\n" "$name"
        fi
    done
}

_btrfs_snapshots() {
    local cur prev words
    _init_completion || return

    local config_dir
    if ! config_dir=$(__get_opt_arg -C "${words[@]}"); then
        config_dir=${BTRFS_SNAPSHOTS_CONFIG_DIR:-/usr/local/etc/btrfs-snapshots}
    fi

    local profiles_dir=$config_dir/profile.d

    case $prev in
    -C)
        _filedir -d
        return
        ;;
    -p)
        local -a profile_names
        readarray -t profile_names < <(__shallow_basenames "$profiles_dir" ".conf")
        readarray -t COMPREPLY < <(compgen -W "${profile_names[*]}" -- "$cur")
        return
        ;;
    esac

    case $cur in
    -*)
        readarray -t COMPREPLY < <(compgen -W '-h -p -C' -- "$cur")
        ;;
    *)
        readarray -t COMPREPLY < <(compgen -W "create prune" -- "$cur")
        ;;
    esac
}

complete -F _btrfs_snapshots btrfs-snapshots
