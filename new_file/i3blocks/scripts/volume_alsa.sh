#!/bin/sh

case $BLOCK_BUTTON in
	1) amixer sset Master toggle ;;
	4) amixer sset Master 5%+ >/dev/null 2>/dev/null ;;
	5) amixer sset Master 5%- >/dev/null 2>/dev/null ;;
esac

volstat="$(pactl list sinks)"

echo "$volstat" | grep -q "Mute: yes" && printf "Vol: Mute\\n" && exit

vol="$(echo "$volstat" | grep '^[[:space:]]Volume:' | sed "s,.* \([0-9]\+\)%.*,\1,;1q")"

printf "Vol: %s\\n" "$vol"
