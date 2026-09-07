# btrfs-snapshots

Manage timestamped collections of btrfs snapshots.

This project is inspired by [Snapper][snapper]'s timeline and cleanup algorithms, but with the aim of being a simpler implementation, focused solely on [btrfs][btrfs].

The goal is not to be a drop-in replacement, but an alternative for administrators that prefer a minimum of baked-in opinions.

## Features

- Retention policies based around recurring calendar events
- Configurable snapshot locations for subvolumes
- Minimal dependencies: bash and coreutils
- Included systemd timers, but equally usable with cron
- Included shell completion for bash and zsh

## Installation

### Manual

To install in the default location (`/usr/local`):

    sudo ./scripts/install

To install in a different location:

    PREFIX=/usr ./scripts/prepare
    sudo PREFIX=/usr ./scripts/install

*NOTE*: `./scripts/prepare` mutates files in the working tree. Run it against a
clean checkout. If you need to change `PREFIX`, discard local changes first
(`git checkout .`) and re-run.

To install in a staging location, set `DESTDIR` for the install script:

    DESTDIR=./pkg ./scripts/install

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

    ./scripts/test --help

[pkg-aur]: https://aur.archlinux.org/packages/btrfs-snapshots/
[pkg-aur-git]: https://aur.archlinux.org/packages/btrfs-snapshots-git/
[btrfs]: https://btrfs.readthedocs.io/en/latest/index.html
[snapper]: http://snapper.io/
