#!/bin/sh

# Prints the current volume or 🔇 if muted. Uses PulseAudio by default,
# uncomment the ALSA lines if you remove PulseAudio.

case $BLOCK_BUTTON in
	#1) setsid "$TERMINAL" -e alsamixer & ;;
	#2) amixer sset Master toggle ;;
	#4) amixer sset Master 5%+ >/dev/null 2>/dev/null ;;
	#5) amixer sset Master 5%- >/dev/null 2>/dev/null ;;
	#1) setsid "$TERMINAL" -e pulsemixer & ;;
	1) pulsemixer --toggle-mute ;;
	4) pulsemixer --change-volume +5 --max-volume 100;;
	5) pulsemixer --change-volume -5 --max-volume 100;;
esac

volstat="$(pactl list sinks)"

echo "$volstat" | grep -q "Mute: yes" && printf " Mute\\n" && exit

vol="$(echo "$volstat" | grep '^[[:space:]]Volume:' | sed "s,.* \([0-9]\+\)%.*,\1,;1q")"

if [ "$vol" -gt "70" ]; then
	icon=""
elif [ "$vol" -lt "30" ]; then
	icon=""
else
	icon=""
fi

printf "%s %s%%\\n" "$icon" "$vol"
