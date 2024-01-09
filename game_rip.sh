#!/bin/bash
#

# Edit these to match your system's setup.
GAME_RIP_DRIVE=${GAME_RIP_DRIVE:-/dev/sr0}
GAME_RIP_ROM_BASE_PATH=${GAME_RIP_ROM_BASE_PATH:-$HOME/Games}

# Print the usage statement.
usage() {
	echo "usage: $0 console:rom_name [console:rom_name ...]"
	echo "       $0 -h"
	# If an argument is provided, exit with its value.
	[ $# -eq 1 ] && exit $1
}

# Get the console portion of a "console:rom_name" string.
get_console() {
	echo "$1" | cut -sd: -f1
}

# Get the rom_name portion of a "console:rom_name" string.
get_rom_name() {
	echo "$1" | cut -sd: -f2
}

# Basic argument checks.
if [ $# -ge 1 ]; then
	if [ "$1" = "-h" ]; then
		usage 0
	fi
else
	usage 1
fi

# Build the docker image each time; useful during development.
# This will automatically incorporate any changes made to the image.
docker build -t game_rip ./image/

# Loop through each RIP_DEF ("console:rom_name" argument).
for RIP_DEF in "$@"; do
	# Verify that the argument is of the form "console:rom_name".
	if [[ ! "$RIP_DEF" =~ .+:.+ ]]; then
		usage 1
	fi

	echo "Next rip: $RIP_DEF"
	CONSOLE=$(get_console "$RIP_DEF")
	ROM_NAME=$(get_rom_name "$RIP_DEF")

	# Remove the container with that name if it already exists.
	if docker container inspect "game_rip.$ROM_NAME" > /dev/null 2>&1; then
		docker container rm -f "game_rip.$ROM_NAME" > /dev/null
	fi

	# Wait for the disk to be loaded, if necessary.
	if ! head --bytes=1 "$GAME_RIP_DRIVE" > /dev/null 2>&1; then
		echo "Waiting for disk drive to be ready..."
		while ! head --bytes=1 "$GAME_RIP_DRIVE" > /dev/null 2>&1; do
			sleep 5s
		done
		echo "Disk drive ready, beginning rip."
	fi

	# Run the docker container that does the actual ripping.
	docker run \
		--device="$GAME_RIP_DRIVE:/dev/cdrom" \
		--tmpfs /tmp/ramdisk \
		-v "$GAME_RIP_ROM_BASE_PATH:/output" \
		--name "game_rip.$ROM_NAME" \
		-l game_rip \
		game_rip "$CONSOLE" "$ROM_NAME"

	# Stop processing the queue if a rip fails.
	# Don't eject the disk; that's taken as a signal of successful completion.
	EXIT_CODE=$?
	if [ $EXIT_CODE -ne 0 ]; then
		echo "Rip failed with status $EXIT_CODE; terminating the rip queue."
		exit $EXIT_CODE
	fi
done
