#!/bin/sh

updates=$(checkupdates | wc -l)

if [ "$updates" -eq "0" ]
then
	echo  No updates
else
	echo  $updates "updates"
fi
