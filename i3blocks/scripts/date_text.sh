#!/bin/sh

case "$BLOCK_BUTTON" in
	1) notify-send "$(cal)" ;;
	3) killall dunst ;;
esac

dateStr=$(date '+%a %d %b' | tr '[a-z]' '[A-Z]')

echo DATE $dateStr
