#!/bin/sh

BOLD='\e[32;1m'

dateIcon=""
dateVar=$(date '+%a %d %b')

timeIcon=""
# timeIcon=$(echo -e ${BOLD}$temp)
timeVar=$(date '+%H:%M')


res=$(echo ${BOLD}$dateIcon $dateVar " " $timeIcon $timeVar)
echo $res
