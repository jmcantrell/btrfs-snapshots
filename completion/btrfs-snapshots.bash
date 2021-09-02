__find_array_value() {
    local needle=$1
    shift

    local i=0

    while (($# > 0)); do
        local straw=$1
        shift

        if [[ $straw == "$needle" ]]; then
            echo "$i"
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
        echo "${words[i + 1]}"
        return 0
    fi

    return 1
}

__shallow_basenames() {
    local dir=$1
    local ext=${2:-}

    [[ -d $dir ]] || return 0

    for file in "$dir"/*"${ext:+$ext}"; do
        [[ -f $file ]] || continue
        name=${file##*/}
        [[ -n $ext ]] && name=${name%"$ext"}
        echo "$name"
    done
}

_btrfs_snapshots() {
    local cur prev words
    _init_completion || return

    local etc_dir
    if ! etc_dir=$(__get_opt_arg -C "${words[@]}"); then
        etc_dir=${BTRFS_SNAPSHOTS_ETC_DIR:-/usr/local/etc/btrfs-snapshots}
    fi

    local profile_dir=$etc_dir/profile.d

    case $prev in
    -C)
        _filedir -d
        return
        ;;
    -p)
        local -a profile_names
        readarray -t profile_names < <(__shallow_basenames "$profile_dir" ".conf")
        readarray -t COMPREPLY < <(compgen -W "${profile_names[*]}" -- "$cur")
        return
        ;;
    esac

    if [[ $cur == -* ]]; then
        readarray -t COMPREPLY < <(compgen -W "-C -h -p" -- "$cur")
        return
    fi

    readarray -t COMPREPLY < <(compgen -W "create list prune" -- "$cur")
}

complete -F _btrfs_snapshots btrfs-snapshots
