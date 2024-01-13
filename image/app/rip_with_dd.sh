#!/bin/bash
#

# Exit if anything fails (returns a non-zero exit status).
set -e

# Work in the ramdisk folder.
cd "$WORKING_PATH"

# Rip the disk contents into a .iso file.
echo "Ripping with dd; you may not see any output for a while."
dd if=/dev/cdrom of=rom.iso

# Compress the .iso file into a .chd file, stored and name as determined by
# the environment variables.
chdman createcd \
	-i rom.iso \
	-o "$STAGE_PATH/$ROM_NAME.chd"
