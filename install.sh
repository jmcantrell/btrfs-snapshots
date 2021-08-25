#!/usr/bin/env bash

set -eu

pkg_name=btrfs-snapshots
src_dir=$PWD
dst_dir=${INSTALL_ROOT:-/usr/local}

mkdir -p "$dst_dir"
cd "$dst_dir"

install -Dt ./bin "$src_dir/bin/$pkg_name"
install -Dt ./lib/"$pkg_name" "$src_dir/lib/$pkg_name"/*
install -Dt ./share/"$pkg_name" "$src_dir/share/$pkg_name"/*
install -Dt ./share/man/man5 "$src_dir/share/man/man5"/*
install -Dt ./share/man/man8 "$src_dir/share/man/man8"/*
install -Dt ./lib/systemd/system "$src_dir/lib/systemd/system"/*
install -Dt ./share/bash-completion/completions "$src_dir/share/bash-completion/completions"/*
install -Dt ./share/zsh/functions/Completion/Linux "$src_dir/share/zsh/functions/Completion/Linux"/*
install -Dt ./share "$src_dir"/{README,LICENSE}.md
