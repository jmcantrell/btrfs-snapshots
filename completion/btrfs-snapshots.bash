_btrfs-snapshots() {
    local cur prev words cword
    _init_completion || return

    local profiles_dir=${BTRFS_SNAPSHOTS_ETC_DIR:-/usr/local/etc/btrfs-snapshots}/profiles.d

    local -a profile_names=()

    if [[ -d $profiles_dir ]]; then
        readarray -t profile_names < <(
            find "$profiles_dir" -type f -name "*.conf" -exec basename "{}" .conf \;
        )
    fi

    # Remove any profile names that have already been used.
    local i
    for i in "${!profile_names[@]}"; do
        local profile_name=${profile_names[i]}
        local j
        for j in "${!words[@]}"; do
            local word=${words[j]}
            if [[ -n $word && $word == -p && ${words[$((j + 1))]} == "$profile_name" ]]; then
                unset profile_names["$i"]
            fi
        done
    done

    case $prev in
    -p)
        readarray -t COMPREPLY < <(compgen -W "${profile_names[*]}" -- "$cur")
        return
        ;;
    esac

    local actions=" list create prune "
    local options=" -h "

    readarray -t COMPREPLY < <(compgen -W "-p $options $actions" -- "$cur")

    local i j word comp

    # Determine if an action has already been used, and remove options if so.
    for i in "${!words[@]}"; do
        if ((i != cword)); then
            if [[ "$actions" == *\ ${words[i]}\ * ]]; then
                for j in "${!COMPREPLY[@]}"; do
                    if [[ "${COMPREPLY[j]}" == -* ]]; then
                        unset COMPREPLY["$j"]
                    fi
                done
                break
            fi
        fi
    done

    for i in "${!COMPREPLY[@]}"; do
        comp=${COMPREPLY[i]}

        # Determine if there are any more profile names to use with -p.
        if [[ "$comp" == -p ]]; then
            for j in "${!profile_names[@]}"; do
                for word in "${words[@]}"; do
                    if [[ "${profile_names[j]}" == "$word" ]]; then
                        unset profile_names["$j"]
                        break
                    fi
                done
            done

            # All profile names have been used, so remove -p.
            if ((${#profile_names[@]} == 0)); then
                unset COMPREPLY["$i"]
            fi

            continue
        fi

        # Determine if any action has already been provided.
        if [[ "$actions" == *\ $comp\ * ]]; then
            for j in "${!words[@]}"; do
                if ((j != cword)); then
                    if [[ "$actions" == *\ ${words[j]}\ * ]]; then
                        unset COMPREPLY["$i"]
                        break
                    fi
                fi
            done
            continue
        fi

        # Determine if this singleton option has already been used.
        if [[ "$options" == *\ $comp\ * ]]; then
            for j in "${!words[@]}"; do
                if ((j != cword)); then
                    if [[ "${words[j]}" == "$comp" ]]; then
                        unset COMPREPLY["$i"]
                        break
                    fi
                fi
            done
            continue
        fi
    done
}

complete -F _btrfs-snapshots btrfs-snapshots

# vi:ft=sh