#!/bin/sh

getBatStatus=$(cat /sys/class/power_supply/BAT0/status)

getBatCapacity=$(cat /sys/class/power_supply/BAT0/capacity)

[ "$getBatStatus" = "Full" ] && export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus && notify-send -u normal "Battery is full charged."

[ "$getBatStatus" = "Charging" ] && exit

[ "$getBatCapacity" -lt 20 ] && export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus && notify-send -u critical "Battery critically low."
