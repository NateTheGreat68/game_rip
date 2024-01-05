#!/bin/bash
#

set -e

cd /tmp/ramdisk

dd if=/dev/cdrom of=rom.iso

chdman createcd \
	-i rom.iso \
	-o "$DEST_PATH/$ROM_NAME.chd"

chown --reference="$DEST_PATH" "$DEST_PATH/$ROM_NAME.chd"

eject /dev/cdrom
