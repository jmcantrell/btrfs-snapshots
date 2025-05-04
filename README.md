# btrfs-snapshots

Manage timestamped collections of btrfs snapshots.

This project is inspired by [Snapper][snapper]'s timeline and cleanup
algorithms, but with the aim of being a simpler implementation,
focused solely on [btrfs][btrfs].

The goal is not to be a drop-in replacement, but an alternative for
administrators that prefer a minimum of baked-in opinions.

## Features

- Retention policies based around recurring calendar events
- Configurable snapshot locations for subvolumes
- Minimal dependencies: bash and coreutils
- Included systemd timers, but equally usable with cron
- Included shell completion for bash and zsh

## Installation

### Repository

To install in the default location (`/usr/local`):

```sh
sudo ./scripts/install
```

To install in a different location:

```sh
PREFIX=/usr sudo ./scripts/install
```

### Arch User Repository (AUR)

There are two packages available for Arch Linux, available via the
AUR.

Stable, based on the latest tagged release:
[btrfs-snapshots][aur]

Unstable, based on the latest commit to the main branch:
[btrfs-snapshots-git][aur-git]

## Help

For command line usage:

```sh
btrfs-snapshots --help
```

For detailed information:

```sh
man 8 btrfs-snapshots
man 5 btrfs-snapshots
```

## Testing

The following packages are required to run tests:

- diffutils
- parallel

To run the included tests:

```sh
./scripts/test
```

For command line usage:

```sh
./scripts/test --help
```

[btrfs]: https://btrfs.readthedocs.io/en/latest/index.html
[snapper]: http://snapper.io/
[aur]: https://aur.archlinux.org/packages/btrfs-snapshots/
[aur-git]: https://aur.archlinux.org/packages/btrfs-snapshots-git/
