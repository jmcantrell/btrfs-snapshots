#!/usr/bin/env bash

set -eu

pkg_name=btrfs-snapshots
src_dir=$PWD
dst_dir=${INSTALL_ROOT:-/usr/local}

mkdir -p "$dst_dir"
cd "$dst_dir"

install -m755 -Dt ./bin \
    "$src_dir"/bin/*

install -m644 -Dt ./lib/"$pkg_name" \
    "$src_dir"/lib/*

for n in 5 8; do
    install -m644 -Dt ./share/man/man"$n" \
        "$src_dir"/man/*."$n"
done

install -m644 -Dt ./lib/systemd/system \
    "$src_dir"/systemd/*

install -m644 -Dt ./share/doc/"$pkg_name"/config \
    "$src_dir"/config/*

install -m644 -Dt ./share/doc/"$pkg_name" \
    "$src_dir"/{README,LICENSE}.md

install -m644 -Dt ./share/zsh/site-functions \
    "$src_dir"/completion/*.zsh

install -m644 -Dt ./share/bash-completion/completions \
    "$src_dir"/completion/*.bash
