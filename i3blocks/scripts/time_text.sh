#!/bin/sh

# 24 hour format
timeStr=$(date '+%H:%M' | tr '[a-z]' '[A-Z]')

# 12 hour format
#timeStr=$(date '+%I:%M %p' | tr '[a-z]' '[A-Z]')

echo TIME $timeStr
