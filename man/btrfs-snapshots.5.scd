btrfs-snapshots(5)

# NAME

btrfs-snapshots - btrfs-snapshots configuration files

# SYNOPSIS

- /usr/local/etc/btrfs-snapshots/defaults.conf
- /usr/local/etc/btrfs-snapshots/profile.d/\*.conf

# DESCRIPTION

Configuration of btrfs-snapshots involves placing a _profile.conf_ file for each
subvolume required in the _profile.d_ directory. The file name does not matter,
but it's recommended to name it after the subvolume it represents (e.g.
_@home.conf_). The extension must be ".conf" for the file to be recognized.

Additionally, default settings can be added to _defaults.conf_ (with some
caveats) that will apply to every profile.

None of these files exist by default, and configuration is left to the
administrator. Example files with the available settings are at:

	- /usr/local/share/doc/btrfs-snapshots/config/defaults.conf
	- /usr/local/share/doc/btrfs-snapshots/config/profile.conf

# OPTIONS

Both the defaults configuration file and every profile configuration file can
have the same settings, with a few enforced caveats.

- The SUBVOLUME setting is only recognized in the profile configuration and it is required.
- The SNAPSHOTS setting, if it appears in the defaults configuration file, must contain a %s placeholder so it can be differentiated for each subvolume.
- If the SNAPSHOTS setting is not defined in the defaults configuration file, it must be defined in every profile, and must be unique.

## SUBVOLUME

This option defines the location of the subvolume to use as the source for
snapshots. It's required, and must be an absolute path to the mount point of the
subvolume.

If, during snapshot creation, the subvolume is not mounted, execution continues
and a warning is emitted.

Example: *SUBVOLUME*="/path/to/subvolume"

## SNAPSHOTS

This option defines the location that will be used to store a subvolume's
snapshots.  If snapshots will be kept in a central location, like _/.snapshots_,
it's recommended to set this in the defaults configuration file (inluding the %s
placeholder). This setting could, of course, be set individually in each profile
configuration or only overridden for certain profiles.

For example, let's say it's defined in the defaults configuration file as
"/.snapshots/%s". There are three profiles in _profile.d_ named _@.conf_,
_@home.conf_, and _@var.conf_. The command to create snapshots is run at 12 noon
(UTC) on December 31st 2021.  There will be three snapshots created and stored
like so:

```
/.snapshots
├── @
│   └── 2021-12-31T12:00:00Z
├── @home
│   └── 2021-12-31T12:00:00Z
└── @var
    └── 2021-12-31T12:00:00Z
```

_Note_: When pruning snapshots, any not named using the recognized timestamp
format will be ignored. This is useful if there have been manual snapshots taken
and you don't want them to be pruned along with the timestamped ones.

Example: *SNAPSHOTS*="/path/to/snapshots"

## LIMIT_<EVENT>

Where EVENT can be one of the following: MINUTELY, HOURLY, DAILY, WEEKLY,
MONTHLY, QUARTERLY, or YEARLY.

This option defines a limit on the number of the snapshots taken during an EVENT
recurrence. Only the earliest snapshot for each unique event is retained, for
the NUMBER most recent events, up to the defined limit.

There can be zero or more limits set. If the limit for an event type is not set
in the profile configuration, the value set in the defaults configuration file
is used. If it's not set anywhere, it's assumed to be "0" (disabled, or, in
other words, keep a maximum of zero snapshots for that event type during
pruning).

Example: *LIMIT_DAILY*=12

For example, if _@home.conf_ contains the line "LIMIT_HOURLY=3" and the
following snapshots exist:

```
/.snapshots/@home
    ├── 2021-12-31T09:00:00Z
    ├── 2021-12-31T09:30:00Z
    ├── 2021-12-31T10:00:00Z
    ├── 2021-12-31T10:30:00Z
    ├── 2021-12-31T11:00:00Z
    ├── 2021-12-31T11:30:00Z
    ├── 2021-12-31T12:00:00Z
    └── 2021-12-31T12:30:00Z
```

Running the prune action will delete snapshots, leaving the tree looking like this:

```
/.snapshots/@home
    ├── 2021-12-31T10:00:00Z
    ├── 2021-12-31T11:00:00Z
    └── 2021-12-31T12:00:00Z
```

Because the hourly limit was set to "3", a total of only three snapshots could
be kept. The algorithm found the most recent three unique events' snapshots up
to the limit value, but only keeping the first snapshot (chronologically) for
each distinct hour.

Both snapshots occurring earlier than 10am were deleted because they were part
of the fourth unique event, falling outside of the limit for that event type.

# SEE ALSO

*btrfs-snapshots*(8)
