# btrfs-snapshots

Manage timestamped collections of btrfs snapshots.

This project is inspired by [Snapper][snapper]'s timeline and cleanup
algorithms, but with the aim of being a simpler implementation,
focused solely on btrfs.

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

Check out the man pages for detailed information about configuration and usage:

```sh
man ./man/btrfs-snapshots.8
man ./man/btrfs-snapshots.5
```

## Testing

The following packages are needed to run tests:

- diffutils
- parallel

To run the included tests:

```sh
./scripts/test
```

To only run some tests (passes arguments to `find`):

```sh
./scripts/test -path "*/unit/*"
```

To see which tests are being run:

```sh
TESTS_VERBOSE=1 ./scripts/test
```

## Hacking

There are fake versions of `btrfs` and `mountpoint` in `./tests/bin`
that allow running `./bin/btrfs-snapshots` without any danger to the
host system. They simply pretend that an existing directory is a
mounted btrfs subvolume.

There are a few environment variables that should be present if you
want to play with the code without installing it. They will tell the
commands to look for needed files in the current directory.

Look at `./envrc.example` for the recommended environment.

You could have [direnv][direnv] load that file automatically:

```sh
cp .envrc.example .envrc
direnv allow
```

This will allow you to run commands from within the repository, but
you'll probably want to create some configuration files in
`$BTRFS_SNAPSHOTS_CONFIG_DIR`, based on the examples in `./config`.

[snapper]: http://snapper.io/
[direnv]: https://direnv.net/
[aur]: https://aur.archlinux.org/packages/btrfs-snapshots/
[aur-git]: https://aur.archlinux.org/packages/btrfs-snapshots-git/
