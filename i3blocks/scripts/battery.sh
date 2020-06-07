#!/bin/sh

# variable declarations

# get the battery state - charging or discharging
batState=$(acpi | awk '{ print $3 }' | sed 's/,//')

# get the battery power value
batValue=$(acpi | awk '{ print $4 }' | sed 's/\%//' | sed 's/,//')

nowBatPlugged() {
	retval=""
	if [ "$batState" == "Charging" ]
	then
		retval=""
	elif [ "$batState" == "Full" ]
	then
		retval="Full"
	elif [ "$batState" == "Unknown" ]
	then
		retval=""
	fi
	echo $retval
}

nowBatIcon() {
	retval=""
	if [ "$batValue" -gt "80" ]
	then
		retval=""
	elif [ "$batValue" -gt "60" ]
	then
		retval=""
	elif [ "$batValue" -gt "40" ]
	then
		retval=""
	elif [ "$batValue" -gt "15" ]
	then
		retval=""
	else
		retval=""
	fi
	echo $retval
}

batPluggedIcon=$( nowBatPlugged )
batIcon=$( nowBatIcon )

echo $batIcon $batPluggedIcon $batValue%




