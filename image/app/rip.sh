#!/bin/bash
#

usage() {
	echo "Usage: [-d <output_subdir>] console image_name"
	exit 1
}

export DEVICE="/dev/cdrom"
export DEST_PATH="/output"
export USERID
export GROUPID

while getopts ":d:" o; do
	case "$o" in
		d)
			DEST_PATH+="/$OPTARG"
			;;
		*)
			usage
			;;
	esac
done

if [ $# -ne $(($OPTIND+1)) ]; then
	usage
fi

CONSOLE="${@:$OPTIND:1}"
export IMAGE_NAME="${@:$OPTIND+1:1}"

case "$CONSOLE" in
	ps1|psx)
		./rip_psx.sh
		;;
	*)
		echo "Unrecognized console: $CONSOLE"
		exit 1
		;;
esac
