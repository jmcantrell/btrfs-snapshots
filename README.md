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
sudo ./scripts/install
```

To install in a different location:

```sh
INSTALL_ROOT=/usr sudo ./scripts/install
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
man ./man/btrfs-snapshots.8
man ./man/btrfs-snapshots.conf.5
```

## Testing

The following packages are needed to run tests:

- diffutils
- parallel

To run the included tests:

```sh
./scripts/test
```

To see which tests are being run:

```sh
TESTS_VERBOSE=1 ./scripts/test
```

To run a specific test (passes arguments to `find`):

```sh
./scripts/test -name specific-test
./scripts/test -path "*/unit/*"
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

That will allow you to run the command from within the repository, but
you'll probably want to create some configuration files to test it.

Then just populate whatever you set `BTRFS_SNAPSHOTS_ETC_DIR` to with
some configuration files, using the examples in
`./config/{defaults,profile}.conf`.

[snapper]: http://snapper.io/
[direnv]: https://direnv.net/
[btrfs-snapshots-aur]: https://aur.archlinux.org/packages/btrfs-snapshots/
[btrfs-snapshots-aur-git]: https://aur.archlinux.org/packages/btrfs-snapshots-git/
