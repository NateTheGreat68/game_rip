#!/bin/bash
#

USERID=$(id -u)
GROUPID=$(id -g)
DEVICE="/dev/sr0"
OUTPUT_PATH="/mnt/games"
CONTAINER_NAME="${@: -1}"

usage() {
	echo "usage: $0 [-d output_subdir] console image_name"
}

if [ "$1" = "-h" ]; then
	usage
	exit 0
fi

docker build -t game_rip ./image/

docker run -d \
	-e "USERID=$USERID" \
	-e "GROUPID=$GROUPID" \
	--device="$DEVICE:/dev/cdrom" \
	--tmpfs "/tmp/ramdisk" \
	-v "$OUTPUT_PATH:/output" \
	--name "$CONTAINER_NAME" \
	game_rip $@

echo "$CONTAINER_NAME detached."
