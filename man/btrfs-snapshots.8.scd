btrfs-snapshots(8)

# NAME

btrfs-snapshots - Manage timestamped collections of btrfs snapshots

# SYNOPSIS

btrfs-snapshots -h
btrfs-snapshots ACTION [NAME...]

# DESCRIPTION

The purpose of *btrfs-snapshots* is to make the process of taking subvolume
snapshots automatic and predictable.

It makes no assumptions about the subvolume layout.  It does not modify the
system in any way.  It does have two strict requirements, however, which are
debatably painless:

- A snapshot's base name is the ISO-8601 formatted UTC timestamp when it was taken (i.e. %Y-%m-%dT%H:%M:%SZ).
- The snapshots for each subvolume must be in their own directory.

# OPTIONS

*-h*
	Display the help message and exit.

# ARGUMENTS

ACTION
	Action to perform on selected profiles.

NAME
	Profile name to perform action on (default: all profiles).

# ACTIONS

*create*
	Create a new snapshot in the configured directory for the selected profiles.
	Any subvolumes that are not mounted will be skipped with a warning message.

*prune*
	Delete all snapshots for the selected profiles that fall outside of the
	configured limits.

# SEE ALSO

*btrfs-snapshots*(5)
