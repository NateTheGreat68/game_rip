#!/bin/bash
#

# Exit if anything fails (returns a non-zero exit status).
set -e

# Work in the ramdisk folder.
cd /tmp/ramdisk

# Rip the disk contents into a .iso file.
echo "Ripping with dd; you may not see any output for a while."
dd if=/dev/cdrom of=rom.iso

# Compress the .iso file into a .chd file, stored and name as determined by
# the environment variables.
chdman createcd \
	-i rom.iso \
	-o "$DEST_PATH/$ROM_NAME.chd"

# Set permissions on the .chd file.
chown --reference="$DEST_PATH" "$DEST_PATH/$ROM_NAME.chd"

# Show the completed file.
cd "$DEST_PATH"
ls -sh "$ROM_NAME.chd"

# Eject the disk drive.
eject /dev/cdrom
