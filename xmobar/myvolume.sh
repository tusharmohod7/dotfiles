#!/bin/sh

case $BLOCK_BUTTON in
	1) pulsemixer --toggle-mute ;;
	4) pulsemixer --change-volume +5 --max-volume 100;;
	5) pulsemixer --change-volume -5 --max-volume 100;;
esac

volstat="$(pactl list sinks)"

echo "$volstat" | grep -q "Mute: yes" && printf "Vol: Mute\\n" && exit

vol="$(echo "$volstat" | grep '^[[:space:]]Volume:' | sed "s,.* \([0-9]\+\)%.*,\1,;1q")"

printf "Vol: %s\\n" "$vol"
