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
    local cur prev words cword
    _init_completion || return

    local -A actions=([list]=1 [create]=1 [prune]=1)
    local -A options=([-h]=1 [-C]=1 [-p]=0)

    local {etc,profile}_dir
    local profile_{name,file}
    local i word next option has_action=0

    local -A used_options=()
    local -A used_profile_names=()
    local -a unused_profile_names=()
    local -a comp_choices=()

    if ! etc_dir=$(__get_opt_arg -C "${words[@]}"); then
        etc_dir=${BTRFS_SNAPSHOTS_ETC_DIR:-/usr/local/etc/btrfs-snapshots}
    fi

    profile_dir=$etc_dir/profile.d

    for i in "${!words[@]}"; do
        ((i == cword)) && continue
        word=${words[i]}
        if [[ $word == -* ]]; then
            used_options[$word]=1
            if [[ $word == -p ]]; then
                next=${words[$((i + 1))]}
                [[ -n $next ]] && used_profile_names[$next]=1
            fi
        elif [[ -v actions[$word] ]]; then
            has_action=1
        fi
    done

    while IFS= read -r -d $'\n' profile_name; do
        if [[ ! -v used_profile_names[$profile_name] ]]; then
            unused_profile_names+=("$profile_name")
        fi
    done < <(__shallow_basenames "$profile_dir" ".conf")

    case $prev in
    -C)
        _filedir -d
        return
        ;;
    -p)
        readarray -t COMPREPLY < <(compgen -W "${unused_profile_names[*]}" -- "$cur")
        return
        ;;
    esac

    if ((!has_action)); then
        if ((${#unused_profile_names[@]} > 0)); then
            comp_choices+=(-p)
        fi

        for option in "${!options[@]}"; do
            if [[ ${options[$option]} != 1 || ! -v used_options[$option] ]]; then
                comp_choices+=("$option")
            fi
        done

        comp_choices+=("${!actions[@]}")
    fi

    readarray -t COMPREPLY < <(compgen -W "${comp_choices[*]}" -- "$cur")
}

complete -F _btrfs_snapshots btrfs-snapshots

# vi:ft=sh
