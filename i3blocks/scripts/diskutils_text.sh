#!/bin/sh

case "$BLOCK_BUTTON" in
    1) notify-send "Disk: $(df -h | awk '{ if($6=="/") { print $3 " of " $2 " [" $5 "]" } }')" ;;
    3) killall dunst ;;
esac

diskFree=$(df -h | awk '{
	if($6 == "/") {
		print $4 
	}
}')

echo DISK $diskFree
