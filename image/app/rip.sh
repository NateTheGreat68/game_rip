#!/bin/bash
#

set -e

DEST_PATH=/output
LOG_PATH=/output_logs

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

# Move the output file to the destination path.
move_rom_to_dest() {
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
		DEST_PATH=$(set_path "$DEST_PATH" 'ps[x1]?|playstation( ?[x1])?')
		LOG_PATH=$(set_path "$LOG_PATH" 'ps[x1]?|playstation( ?[x1])?')
		SCRIPT_PATH=./rip_psx.sh
		;;
	ps2)
		DEST_PATH=$(set_path "$DEST_PATH" 'ps2|playstation( ?2)?')
		LOG_PATH=$(set_path "$LOG_PATH" 'ps2|playstation( ?2)?')
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
