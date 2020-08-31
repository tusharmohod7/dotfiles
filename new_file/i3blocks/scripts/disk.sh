#!/bin/bash

freedisk=$(df -h | awk '{
	if($6 == "/") {
		print $4
	}
}')

printf "Disk: %s\\n" "$freedisk"
