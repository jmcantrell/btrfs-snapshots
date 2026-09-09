# btrfs-snapshots

Manage timestamped collections of btrfs snapshots.

This project is inspired by [Snapper][snapper]'s timeline and cleanup
algorithms, but with the aim of being a simpler implementation, focused solely
on [btrfs][btrfs].

The goal is not to be a drop-in replacement, but an alternative for
administrators that prefer a minimum of baked-in opinions.

## Features

- Retention policies based around recurring calendar events
- Configurable snapshot locations for subvolumes
- Minimal dependencies: bash and coreutils
- Included systemd timers, but equally usable with cron
- Included shell completion for bash and zsh

## Installation

### Manual

First, prepare the files for installation:

    PREFIX=/usr/local ./scripts/prepare

Then, install files directly to the prefix:

    PREFIX=/usr/local sudo ./scripts/install

Or, install files elsewhere, like a staging location:

    DESTDIR=./pkg PREFIX=/usr/local ./scripts/install

### Arch User Repository

There are two packages available for Arch Linux, available via the AUR:

- [btrfs-snapshots][pkg-aur] (stable, based on the latest tag)
- [btrfs-snapshots-git][pkg-aur-git] (unstable, based on the latest commit)

## Help

For command line usage:

    btrfs-snapshots --help

For detailed information:

    man 8 btrfs-snapshots
    man 5 btrfs-snapshots

## Testing

The following packages are required to run tests:

- diffutils
- parallel

To run the included tests:

    ./scripts/test

For command line usage:

    ./scripts/test -h

[pkg-aur]: https://aur.archlinux.org/packages/btrfs-snapshots/
[pkg-aur-git]: https://aur.archlinux.org/packages/btrfs-snapshots-git/
[btrfs]: https://btrfs.readthedocs.io/en/latest/index.html
[snapper]: http://snapper.io/
