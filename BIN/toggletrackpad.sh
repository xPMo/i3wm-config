#!/usr/bin/env bash
#set -euo pipefail

# POSIX doesn't allow this (yet)
#IFS=$'\n'
IFS="
" # but it does allow this

if  synclient | grep -q 'TouchpadOff             = 0'; then
	synclient TouchpadOff=1
else
	synclient TouchpadOff=0
fi
