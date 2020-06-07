#!/bin/sh

if [[ -z "$INTERFACE" ]] ; then
    INTERFACE="${BLOCK_INSTANCE:-enp3s0}"
fi

if [ ! -d /sys/class/net/${INTERFACE}/wireless ] 
then
	exit
fi

if [ "$(cat /sys/class/net/$INTERFACE/operstate)" == 'down' ]
then
    echo " Not connected"
    exit
fi

SSID=$(iw "$INTERFACE" info | awk '/ssid/ {print $2}')

QUALITY=$(grep $INTERFACE /proc/net/wireless | awk '{ print int($3 * 100 / 70) }')

echo  $SSID [$QUALITY%]
