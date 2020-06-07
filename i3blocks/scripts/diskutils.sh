#!/bin/sh

diskFree=$(df -h | awk '{
	if($6 == "/") {
		print $4
	}
}')

echo $diskFree
