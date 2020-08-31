#!/bin/bash

batStatus=$(cat /sys/class/power_supply/BAT0/status)
batCap=$(cat /sys/class/power_supply/BAT0/capacity)

displayStatus() {
	retval=""
	case "$batStatus" in
		Charging) retval="Chr" ;;
		Discharging) retval="Dis" ;;
		Unknown) retval="Unk" ;;
		Full) retval="Full" ;;
	esac
	echo $retval
}

getStatus=$( displayStatus )

printf "Bat: %s %s\\n" "$getStatus" "$batCap"
