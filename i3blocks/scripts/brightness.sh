#!/bin/sh

case "$BLOCK_BUTTON" in
	4) xbacklight -inc 5 ;;
	5) xbacklight -dec 5 ;;
esac

brightness=$(xbacklight -get | awk -F'.' '{ print $1 }')

echo $brightness%
