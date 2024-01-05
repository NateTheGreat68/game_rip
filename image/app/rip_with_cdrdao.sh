#!/bin/bash
#

# Exit if anything fails (returns a non-zero exit status).
set -e

# Work in the ramdisk folder.
cd /tmp/ramdisk

# Rip the disk contents into a .toc and .bin file.
cdrdao read-cd --read-raw \
	--datafile rom_pre.bin \
	--device /dev/cdrom \
	--driver generic-mmc-raw \
	rom.toc

# Convert the .toc file to .cue, correcting audio endianness along the way.
toc2cue -sC rom.bin \
	rom.toc \
	rom.cue

# Compress the .cue and .bin file into a .chd file, stored and named
# as determined by the environment variables.
chdman createcd \
	-i rom.cue \
	-o "$DEST_PATH/$ROM_NAME.chd"

# Set permissions on the .chd file.
chown --reference="$DEST_PATH" "$DEST_PATH/$ROM_NAME.chd"

# Show the completed file.
cd "$DEST_PATH"
ls -sh "$ROM_NAME.chd"

# Eject the disk drive.
eject /dev/cdrom
