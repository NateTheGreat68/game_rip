#!/bin/bash
#

# Edit these to match your system's setup.
: ${GAME_RIP_DRIVE:=/dev/sr0}
: ${GAME_RIP_ROM_BASE_PATH:=$HOME/Games}
: ${GAME_RIP_LOG_BASE_PATH=$GAME_RIP_ROM_BASE_PATH}
: ${OCI_COMMAND:=""}

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

# Set OCI_COMMAND and any specific arguments.
if [ -z ${OCI_COMMAND+x} ]; then
	if which docker &> /dev/null; then
		OCI_COMMAND=docker
	elif which podman &> /dev/null; then
		OCI_COMMAND=podman
	else
		echo "ERROR: No known container runtime found." 1>&2
		echo "       Docker and podman are currently supported." 1>&2
		exit 1
	fi
fi
mount_arguments=""
additional_arguments=""
case "$OCI_COMMAND" in
	docker)
		;;
	podman)
		if getsebool container_use_devices | grep off &> /dev/null; then
			echo "ERROR: SELinux container_use_devices is not on. Please run:" 1>&2
			echo "       $ sudo setsebool -P container_use_devices 1"
			echo "       and try again."
			exit 1
		fi
		mount_arguments=":Z"
		additional_arguments="--security-opt=unmask=ALL"
		;;
	*)
		;;
esac

# Build the image each time; useful during development.
# This will automatically incorporate any changes made to the image.
$OCI_COMMAND build -t game_rip ./image/

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
	if $OCI_COMMAND container inspect "game_rip.$ROM_NAME" > /dev/null 2>&1; then
		$OCI_COMMAND container rm -f "game_rip.$ROM_NAME" > /dev/null
	fi

	# Wait for the disk to be loaded, if necessary.
	if ! head --bytes=1 "$GAME_RIP_DRIVE" > /dev/null 2>&1; then
		echo "Waiting for disk drive to be ready..."
		while ! head --bytes=1 "$GAME_RIP_DRIVE" > /dev/null 2>&1; do
			sleep 5s
		done
		echo "Disk drive ready, beginning rip."
	fi

	# Run the container that does the actual ripping.
	if [ -n "$GAME_RIP_LOG_BASE_PATH" ]; then
		$OCI_COMMAND run \
			--rm \
			--device="$GAME_RIP_DRIVE:/dev/cdrom" \
			--tmpfs /tmp/ramdisk \
			-v "$GAME_RIP_ROM_BASE_PATH:/output$mount_arguments" \
			-v "$GAME_RIP_LOG_BASE_PATH:/output_logs$mount_arguments" \
			--name "game_rip.$ROM_NAME" \
			-l game_rip \
			$additional_arguments \
			game_rip "$CONSOLE" "$ROM_NAME"
	else
		$OCI_COMMAND run \
			--rm \
			--device="$GAME_RIP_DRIVE:/dev/cdrom" \
			--tmpfs /tmp/ramdisk \
			-v "$GAME_RIP_ROM_BASE_PATH:/output$mount_arguments" \
			--tmpfs /output_logs \
			--name "game_rip.$ROM_NAME" \
			-l game_rip \
			$additional_arguments \
			game_rip "$CONSOLE" "$ROM_NAME"
	fi

	# Stop processing the queue if a rip fails.
	# Don't eject the disk; that's taken as a signal of successful completion.
	EXIT_CODE=$?
	if [ $EXIT_CODE -ne 0 ]; then
		echo "Rip failed with status $EXIT_CODE; terminating the rip queue."
		exit $EXIT_CODE
	fi
done
