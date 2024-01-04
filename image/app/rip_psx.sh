#!/bin/bash
#

set -e

cd /tmp/ramdisk

cdrdao read-cd --read-raw \
	--datafile "${IMAGE_NAME}_pre.bin" \
	--device "$DEVICE" \
	--driver generic-mmc-raw \
	"$IMAGE_NAME.toc"

toc2cue -sC "$IMAGE_NAME.bin" \
	"$IMAGE_NAME.toc" \
	"$IMAGE_NAME.cue"

chdman createcd \
	-i "$IMAGE_NAME.cue" \
	-o "$DEST_PATH/$IMAGE_NAME.chd"

chown $USERID:$GROUPID "$DEST_PATH/$IMAGE_NAME.chd"

eject "$DEVICE"
