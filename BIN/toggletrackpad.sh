#!/usr/bin/env sh
#set -euo pipefail

IFS="
" #IFS=$'\n'

if  synclient | grep -q 'TouchpadOff             = 0'; then
	synclient TouchpadOff=1
else
	synclient TouchpadOff=0
fi
