#!/bin/bash
#

DEVICE=${DEVICE:-/dev/sr0}
OUTPUT_PATH=${OUTPUT_PATH:-$HOME/Games}

usage() {
	echo "usage: $0 console:rom_name"
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
	elif [[ "$1" =~ : ]]; then
		CONSOLE=$(get_console "$1")
		ROM_NAME=$(get_rom_name "$1")
	else
		usage 1
	fi
else
	usage 1
fi

docker build -t game_rip ./image/

docker run -d \
	--device="$DEVICE:/dev/cdrom" \
	--tmpfs /tmp/ramdisk \
	-v "$OUTPUT_PATH:/output" \
	--name "$ROM_NAME" \
	-l game_rip \
	game_rip "$CONSOLE" "$ROM_NAME"

echo "$ROM_NAME detached."

docker logs -f "$ROM_NAME"
