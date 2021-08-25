#!/usr/bin/env bash

set -eu

pkg_name=btrfs-snapshots
src_dir=$PWD
dst_dir=${INSTALL_ROOT:-/usr/local}

mkdir -p "$dst_dir"
cd "$dst_dir"

install -m755 -Dt ./bin "$src_dir/bin/$pkg_name"
install -m644 -Dt ./lib/"$pkg_name" "$src_dir/lib/$pkg_name"/*
install -m644 -Dt ./share/"$pkg_name" "$src_dir/share/$pkg_name"/*
install -m644 -Dt ./share/man/man5 "$src_dir/share/man/man5"/*
install -m644 -Dt ./share/man/man8 "$src_dir/share/man/man8"/*
install -m644 -Dt ./lib/systemd/system "$src_dir/lib/systemd/system"/*
install -m644 -Dt ./share/bash-completion/completions "$src_dir/share/bash-completion/completions"/*
install -m644 -Dt ./share/zsh/functions/Completion/Linux "$src_dir/share/zsh/functions/Completion/Linux"/*
install -m644 -Dt ./share "$src_dir"/{README,LICENSE}.md
