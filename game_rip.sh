#!/bin/bash
#

DEVICE=${DEVICE:-/dev/sr0}
ROM_BASE_PATH=${ROM_BASE_PATH:-$HOME/Games}

usage() {
	echo "usage: $0 console:rom_name [console:rom_name ...]"
	echo "       $0 -h"
	[ $# -eq 1 ] && exit $1
}

get_console() {
	echo "$1" | cut -sd: -f1
}

get_rom_name() {
	echo "$1" | cut -sd: -f2
}

if [ $# -ge 1 ]; then
	if [ "$1" = "-h" ]; then
		usage 0
	fi
else
	usage 1
fi

docker build -t game_rip ./image/

for RIP_DEF in "$@"; do
	if [[ ! "$RIP_DEF" =~ : ]]; then
		usage 1
	fi

	CONSOLE=$(get_console "$RIP_DEF")
	ROM_NAME=$(get_rom_name "$RIP_DEF")

	# Remove the container with that name if it already exists.
	if docker container inspect "game_rip.$ROM_NAME" > /dev/null 2>&1; then
		docker container rm -f "game_rip.$ROM_NAME" > /dev/null
	fi

	# Wait for the disk to be loaded, if necessary.
	if ! head --bytes=1 "$DEVICE" > /dev/null 2>&1; then
		echo "Waiting for disk drive to be ready..."
		while ! head --bytes=1 "$DEVICE" > /dev/null 2>&1; do
			sleep 5s
		done
		echo "Disk drive ready, beginning rip."
	fi

	docker run \
		--device="$DEVICE:/dev/cdrom" \
		--tmpfs /tmp/ramdisk \
		-v "$ROM_BASE_PATH:/output" \
		--name "game_rip.$ROM_NAME" \
		-l game_rip \
		game_rip "$CONSOLE" "$ROM_NAME"
done
