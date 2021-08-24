#!/usr/bin/env bash

set -eu

name=btrfs-snapshots
src_dir=$PWD
prefix=${PREFIX:-/usr/local}

cd "$prefix"

install -Dt "$prefix/bin" "$src_dir/bin/$name"
sed -i ":/usr/local:s:/usr/local:$prefix:" "$prefix/bin/$name"

install -Dt "$prefix/lib/$name" "$src_dir/lib/$name"/*

install -Dt "$prefix/share/$name" "$src_dir/share/$name"/*

install -Dt "$prefix/share/man/man5" "$src_dir/share/man/man5"/*
install -Dt "$prefix/share/man/man8" "$src_dir/share/man/man8"/*

install -Dt "$prefix/lib/systemd/system" "$src_dir/lib/systemd/system"/*
sed -i ":/usr/local:s:/usr/local:$prefix:" "$prefix/lib/systemd/system/$name"-*.service
