#!/bin/sh

# get the battery state - charging or discharging
batState=$(acpi | awk '{ print $3 }' | sed 's/,//')

# get the battery power value
batValue=$(acpi | awk '{ print $4 }' | sed 's/\%//' | sed 's/,//')

nowBatPlugged() {
	retval=""
	if [ "$batState" == "Charging" ]
	then
		retval="CHR"
	elif [ "$batState" == "Full" ]
	then
		retval="FULL"
	elif [ "$batState" == "Unknown" ]
	then
		retval="UNK"
	fi
	echo $retval
}

batPluggedIcon=$( nowBatPlugged )

timeRem() {
    if [ "$batPluggedIcon" == "CHR" ]
    then
        t=$(acpi | awk '{ print $5 }')
        notify-send "Time to charge completely: $t"
    else
        t=$(acpi | awk '{ print $5 }')
        notify-send "Time Remaining: $t"
    fi
}

case "$BLOCK_BUTTON" in
    1) $( timeRem ) ;;
    3) killall dunst ;;
esac

echo BAT $batPluggedIcon $batValue

