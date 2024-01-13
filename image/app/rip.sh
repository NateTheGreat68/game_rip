#!/bin/bash
#

set -e

DEST_PATH=/output
LOG_PATH=/output_logs
STAGE_PATH=/tmp/output
mkdir -p "$STAGE_PATH"

# Print the usage statement.
usage() {
	echo "usage: (docker run ...) console rom_name"
	echo "       (docker run ...) -h"
	echo "supported consoles: psx,ps2"
	# If an argument is provided, exit with its value.
	[ $# -eq 1 ] && exit $1
}

# Append a subdirectory to the first argument,
# if one exists which matches regex provided as the second argument.
# Otherwise, echo an empty string.
set_path() {
	POTENTIAL_PATH=$(find "$1/" \
		-maxdepth 1 \
		-type d \
		-regextype awk \
		-iregex "$1/($2)$" \
		-print -quit)
	echo "${POTENTIAL_PATH:-$1}"
}

# Set both DEST_PATH and LOG_PATH, using the regex provided as the argument.
# Set WORKING_PATH based on available capacity.
set_paths() {
	DEST_PATH=$(set_path "$DEST_PATH" "$1")
	LOG_PATH=$(set_path "$LOG_PATH" "$1")

	# Check if /tmp/ramdisk is mounted (the path will exist regardless).
	if df /tmp/ramdisk > /dev/null 2>&1; then
		disk_size=$(lsblk -bo SIZE /dev/cdrom | tail -n1)
		ramdisk_free=$(df -B1 --output=avail /tmp/ramdisk | tail -n1)
		# Check if ramdisk capacity is at least 125% of the disk size
		if [ $(($disk_size*5/4)) -le $ramdisk_free ]; then
			WORKING_PATH=/tmp/ramdisk/working
		else
			WORKING_PATH=/tmp/working
		fi
	else
		WORKING_PATH=/tmp/working
	fi
	mkdir -p "$WORKING_PATH"
}

# Move the output file(s) to the destination path.
move_rom_to_dest() {
	cd "$STAGE_PATH"
	chown -R --reference="$DEST_PATH" ./*
	ls -shR | grep -ve '^total' -e '^.:$'
	mv --backup=numbered ./* "$DEST_PATH/"
}

# Basic argument check.
if [ $# -eq 2 ]; then
	CONSOLE=$1
	ROM_NAME=$2
elif [ "$1" = "-h" ]; then
	usage 0
else
	usage 1
fi

# Find the correct console script to use and run it.
case "$CONSOLE" in
	psx|ps1)
		set_paths 'ps[x1]?|playstation( ?[x1])?'
		SCRIPT_PATH=./rip_psx.sh
		;;
	ps2)
		set_paths 'ps2|playstation ?2'
		SCRIPT_PATH=./rip_ps2.sh
		;;
	*)
		echo "Unrecognized console: $CONSOLE"
		exit 1
		;;
esac
time {
	date && \
	source "$SCRIPT_PATH" && \
	move_rom_to_dest
} |& tee -a "$LOG_PATH/.$ROM_NAME.log"
# Throw the exit code before tee for the sake of `set -e`.
# Otherwise, a failure in the block above wouldn't exit the script.
( exit ${PIPESTATUS[0]}; )

# Eject the disk.
eject /dev/cdrom
