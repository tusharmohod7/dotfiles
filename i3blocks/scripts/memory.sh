#!/bin/sh

memStat=$(free -h | awk '{
	if($1 == "Mem:") {
		print $3 " of " $2
	}
}')

echo $memStat
