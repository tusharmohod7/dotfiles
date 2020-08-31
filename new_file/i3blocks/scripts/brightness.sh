#!/bin/sh

br=$(xbacklight -get | cut -d'.' -f1)

printf "Br: %s\\n" "$br"
