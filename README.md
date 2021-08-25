# btrfs-snapshots

Manage collections of btrfs snapshots.

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

## Testing

To run the included tests:

```sh
./test.sh
```

If there's no output then every test succeeded.

## Configuration

Example configuration files are located at
`/usr/share/btrfs-snapshots`. That location and others detailed below
might be different depending on how it was installed.

### Subvolume Profiles

To make btrfs-snapshots aware of a subvolume, add a configuration file
with the extension `.conf` to `/etc/btrfs-snapshots.d`.
This directory
does not exist by default, so you will have to create it.

For example, you might have the following in `/etc/btrfs-snapshots.d/@home.conf`:

```conf
SUBVOLUME=/home
SNAPSHOTS=/.snapshots/@home
LIMIT_HOURLY=12
LIMIT_DAILY=7
LIMIT_MONTHLY=3
LIMIT_YEARLY=1
```

The `SUBVOLUME` setting is the only strict requirement, and will error
if not set to an absolute path. While there is no requirement that any
limits are set, any that are not set will default to zero (unless
defaults are set, described below). If every limit is set to zero
(implicitly or explicitly), the `prune` command will always remove
every snapshot for the affected subvolume, which is unlikely to be the
desired behavior.

See `man 5 btrfs-snapshots.d` for more details.

### Default Profile Settings

If you want to set defaults for every subvolume, you might have the
following in the main configuration file at
`/etc/btrfs-snapshots.conf`:

```conf
DEFAULT_SNAPSHOTS=/.snapshots/%NAME%
DEFAULT_LIMIT_HOURLY=10
DEFAULT_LIMIT_WEEKLY=10
DEFAULT_LIMIT_QUARTERLY=10
```

For `DEFAULT_SNAPSHOTS`, every instance of the placeholder `%NAME%`
will be replaced with the subvolume profile name and is available as
the default for `SNAPSHOTS`. Of course, `DEFAULT_SNAPSHOTS` isn't
required, but if undefined, `SNAPSHOTS` will be required for every
profile, and will error if not set.

See `man 5 btrfs-snapshots.conf` for more details.

## Usage

To see the full usage text:

```sh
btrfs-snapshots -h
```

To perform an action on the configured subvolumes:

```sh
btrfs-snapshots [-n] [-p NAME...] ACTION
```

If the `-n` option is used, btrfs-snapshots will report what would
happen for the command, but not actually do anything. In other words,
a dry-run.

See `man 8 btrfs-snapshots` for more details.

### Action: `create`

Any time this action is performed, a new snapshot is taken for every
selected profile.

The intention is that this will be run periodically by a scheduling
daemon like systemd timers or cron. If the included systemd timer is
used, this will be every hour, but it is easily customizable.

The snapshots are created in the directory defined in `SNAPSHOTS` (or
`DEFAULT_SNAPSHOTS` if undefined). The base name of the snapshot will
be an ISO-8601 formatted UTC timestamp corresponding to when it was
created.

For example, if `DEFAULT_SNAPSHOTS=/.snapshots/%NAME%` is in
`/etc/btrfs-snapshots.conf` and `/etc/btrfs-snapshots.d` contains the
profiles `@etc.conf` and `@home.conf`, then when the `create` action
is performed for those profiles, the snapshot tree will look similar
to this (with different timestamps, obviously):

```
/.snapshots
├── @etc
│   └── 2021-08-24T21:00:00Z
└── @home
    └── 2021-08-24T21:00:00Z
```

### Action: `prune`

Any time this action is performed, all of the snapshots that fall
outside of the defined limits for every selected profile are deleted.

The intention is that this will be run periodically by a scheduling
daemon like systemd timers or cron. If the included systemd timer is
used, this will be every day, but it is easily customizable.

For example, if `LIMIT_DAILY=3` is in
`/etc/btrfs-snapshots.d/@home.conf` and the snapshot tree looks like
this:

```
/.snapshots
└── @home
    ├── 2021-08-21T00:00:00Z
    ├── 2021-08-22T00:00:00Z
    ├── 2021-08-22T01:00:00Z
    ├── 2021-08-23T00:00:00Z
    ├── 2021-08-23T01:00:00Z
    ├── 2021-08-24T00:00:00Z
    └── 2021-08-24T01:00:00Z
```

After performing the `prune` action, the snapshot tree will look like
this:

```
/.snapshots
└── @home
    ├── 2021-08-22T00:00:00Z
    ├── 2021-08-23T00:00:00Z
    └── 2021-08-24T00:00:00Z
```

Notice that what's left represents the earliest snapshot taken for the
most recent three daily events.

[snapper]: http://snapper.io/
[btrfs-snapshots-aur]: https://aur.archlinux.org/packages/btrfs-snapshots/
[btrfs-snapshots-aur-git]: https://aur.archlinux.org/packages/btrfs-snapshots-git/
