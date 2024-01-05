#!/bin/bash
#

export DEST_PATH=/output

usage() {
	echo "usage: (docker run ...) console image_name"
	echo "       (docker run ...) -h"
	echo "supported consoles: psx,ps2"
	[ $# -eq 1 ] && exit $1
}

set_dest_path() {
	POTENTIAL_PATH=$(find "$DEST_PATH/" \
		-maxdepth 1 \
		-type d \
		-regextype awk \
		-iregex "$DEST_PATH/($1)$" \
		-print -quit)
	DEST_PATH=${POTENTIAL_PATH:-$DEST_PATH}
}

if [ $# -eq 2 ]; then
	CONSOLE=$1
	export IMAGE_NAME=$2
elif [ "$1" = "-h" ]; then
	usage 0
else
	usage 1
fi

case "$CONSOLE" in
	psx|ps1)
		set_dest_path 'ps[x1]?|playstation( ?[x1])?'
		time ./rip_psx.sh
		;;
	ps2)
		set_dest_path 'ps2|playstation( ?2)?'
		time ./rip_ps2.sh
		;;
	*)
		echo "Unrecognized console: $CONSOLE"
		exit 1
		;;
esac
