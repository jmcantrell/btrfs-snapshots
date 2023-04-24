btrfs-snapshots(8)

# NAME

btrfs-snapshots - Manage timestamped collections of btrfs snapshots

# SYNOPSIS

btrfs-snapshots [_OPTIONS_] [_ACTION_]

# DESCRIPTION

The purpose of *btrfs-snapshots* is to make the process of taking subvolume
snapshots automatic and predictable.

It makes no assumptions about the subvolume layout.  It does not modify the
system in any way.  It does have two strict requirements, however, which are
debatably painless:

- A snapshot's base name is the ISO-8601 formatted UTC timestamp when it was taken (i.e. %Y-%m-%dT%H:%M:%SZ).
- The snapshots for each subvolume must be in their own directory.

# ACTIONS

*create*
	Create a new snapshot in the configured directory for the selected profiles.
	Any subvolumes that are not mounted will be skipped with a warning message.

*prune*
	Delete all snapshots for the selected profiles that fall outside of the
	configured limits.

# OPTIONS

*-h*
	Display the help message and exit.

*-p* _NAME_
	Select a profile to perform ACTION on.  Can be specified multiple times.

*-C* _DIRECTORY_
	Look for configuration files in _DIRECTORY_ instead of
	_/usr/local/etc/btrfs-snapshots_.

# TIMERS

While not a requirement, the intention is that snapshots will be automatically
created and pruned using the included *systemd.timer*(5).  Both timers must be
enabled explicitly.

_btrfs-snapshots-create.timer_
	This timer creates snapshots for all configured subvolumes at a regular
	interval (hourly, by default).

_btrfs-snapshots-prune.timer_
	This timer deletes all of the snapshots that fall outside of the configured
	limits at a regular interval (daily, by default).

You could, of course, configure those for a different schedule, or use another
scheduler, like cron.

# SHELL COMPLETION

Completion functions for bash and zsh are included and will be available by
default, provided shell completion is enabled and configured correctly.

# SEE ALSO

*btrfs-snapshots*(5)
