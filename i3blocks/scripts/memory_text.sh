#!/bin/sh

case "$BLOCK_BUTTON" in
    1) notify-send "$(ps axch -o cmd:15,%mem --sort=-%mem | head)" ;;
    3) killall dunst ;;
esac

memStat=$(free -h | awk '{
	if($1 == "Mem:") {
		print $3 " OF " $2
	}
}' | sed 's/i//g')


echo MEM $memStat
