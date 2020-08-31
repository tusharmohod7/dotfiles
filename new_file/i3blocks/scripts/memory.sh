#!/bin/bash

memStat=$(free -h | awk '{ if($1 == "Mem:") { print $3 " of " $2 } }')

printf "Mem: %s\\n" "$memStat"
