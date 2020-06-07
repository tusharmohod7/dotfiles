#!/bin/sh

cpuStat=$(sensors | awk '/^temp1/ { print $2 }')

echo $cpuStat
