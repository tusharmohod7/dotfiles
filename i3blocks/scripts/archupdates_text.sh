#!/bin/sh

updates=$(checkupdates | wc -l)

if [ "$updates" -eq "0" ]
then
	echo "System up to date"
else
	echo $updates "update(s) available"
fi
