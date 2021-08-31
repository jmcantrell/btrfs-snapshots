# btrfs-snapshots

Manage timestamped collections of btrfs snapshots.

This project is inspired by [Snapper][snapper]'s timeline and cleanup
algorithms, but with the aim of being a simpler implementation,
focused solely on btrfs.

The goal is not to be a drop-in replacement, but an alternative for
administrators that prefer a minimum of baked-in opinions.

## Features

- Retention policies based around recurring calendar events
- Included systemd timers, but equally usable with cron
- Able to operate on one or more subvolumes at a time
- Configurable snapshot locations for subvolumes
- Minimal dependencies: bash and coreutils
- Does not alter the system in any way
- Shell completion for bash and zsh

## Installation

### Repository

To install in the default location (`/usr/local`):

```sh
sudo ./install.sh
```

To install in a different location:

```sh
INSTALL_ROOT=/usr sudo ./install.sh
```

### Arch User Repository (AUR)

There are two packages available for Arch Linux, available via the
AUR.

Stable, based on the latest tagged release:
[btrfs-snapshots][btrfs-snapshots-aur]

Unstable, based on the latest commit to the main branch:
[btrfs-snapshots-git][btrfs-snapshots-aur-git]

## Help

Check out the man pages for detailed information about configuration and usage:

```sh
man ./share/man/man8/btrfs-snapshots.8
man ./share/man/man5/btrfs-snapshots.conf.5
```

## Testing

To run the included tests:

```sh
./test.sh
```

To run a specific test (passes arguments to `find`):

```sh
./test.sh -name specific-test
./test.sh -wholename "*/unit/*"
```

## Hacking

There's a fake version of `btrfs` in `./tests/bin` that allows running
`./bin/btrfs-snapshots` without any danger to the host system. Instead
of creating and deleting snapshots, it simply copies and removes
directories.

There are a few environment variables that should be present if you
want to play with the code without installing it. They will tell the
commands to look for needed files in the current directory.

Look at `./envrc.example` for the recommended environment.

You could have [direnv][direnv] load that file automatically:

```sh
cp .envrc.example .envrc
direnv allow
```

[snapper]: http://snapper.io/
[direnv]: https://direnv.net/
[btrfs-snapshots-aur]: https://aur.archlinux.org/packages/btrfs-snapshots/
[btrfs-snapshots-aur-git]: https://aur.archlinux.org/packages/btrfs-snapshots-git/
