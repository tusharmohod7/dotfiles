#!/bin/sh

case "$BLOCK_BUTTON" in
    1) notify-send "$(ps axch -o cmd:15,%cpu --sort=-%cpu | head)" ;;
    3) killall dunst ;;
esac

cpuStat=$(sensors | awk '/^temp1/ { print $2 }' | sed 's/+//' | sed 's/°C//' )

echo TEMP $cpuStat
