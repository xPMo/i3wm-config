#!/bin/bash
#set -euo pipefail
#IFS=$'\n\t'

# First argument: Primary monitor
# Second argument: Secondary monitor
if  xrandr | grep -q "$2 d"; then
	xrandr --output "$2" --off
else
	xrandr --output "$2" --auto
	xrandr --output "$2" --right-of "$1"
fi
sh ~/.fehbg
