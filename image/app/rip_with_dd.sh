#!/bin/bash
#

set -e

cd /tmp/ramdisk

dd if=/dev/cdrom of=rom.iso

chdman createcd \
	-i rom.iso \
	-o "$DEST_PATH/$IMAGE_NAME.chd"

chown --reference="$DEST_PATH" "$DEST_PATH/$IMAGE_NAME.chd"

eject /dev/cdrom
