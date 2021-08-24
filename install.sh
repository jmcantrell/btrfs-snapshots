#!/usr/bin/env bash

set -eu

name=btrfs-snapshots
src_dir=$PWD
prefix=${PREFIX:-/usr/local}

cd "$prefix"

install -Dt "$prefix/usr/bin" "$src_dir/bin/$name"
sed -i ":/usr/local:s:/usr/local:$prefix:" "$prefix/usr/bin/$name"

install -Dt "$prefix/usr/lib/$name" "$src_dir/lib/$name"/*

install -Dt "$prefix/usr/share/$name" "$src_dir/share/$name"/*

install -Dt "$prefix/usr/share/man/man5" "$src_dir/share/man/man5"/*
install -Dt "$prefix/usr/share/man/man8" "$src_dir/share/man/man8"/*

install -Dt "$prefix/usr/lib/systemd/system" "$src_dir/lib/systemd/system"/*
sed -i ":/usr/local:s:/usr/local:$prefix:" "$prefix/usr/lib/systemd/system/$name"-*.service

install -Dt "$prefix/usr/share" "$src_dir"/{README,LICENSE}.md
