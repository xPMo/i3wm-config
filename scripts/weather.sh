#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

# shell script to prepend i3status with more stuff

i3status | while :
do
        read line
	weather=$( weather 64505 | egrep -o '([0-9])+\.[0-9] C' )
	echo "$weather | $line"
done
