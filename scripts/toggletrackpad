#!/usr/bin/env bash
#set -euo pipefail
#IFS=$'\n\t'

if  synclient | grep -q 'TouchpadOff             = 0'; then
	synclient TouchpadOff=1
else
	synclient TouchpadOff=0
fi
