#!/bin/bash
#

set -e

cd /tmp/ramdisk

cdrdao read-cd --read-raw \
	--datafile rom_pre.bin \
	--device /dev/cdrom \
	--driver generic-mmc-raw \
	rom.toc

toc2cue -sC rom.bin \
	rom.toc \
	rom.cue

chdman createcd \
	-i rom.cue \
	-o "$DEST_PATH/$ROM_NAME.chd"

chown --reference="$DEST_PATH" "$DEST_PATH/$ROM_NAME.chd"

eject /dev/cdrom
