#!/usr/bin/env sh
#set -euo pipefail
IFS="
" # IFS=$'\n'

#Arguments: program, program's WM_CLASS lookup, workspace
if [ $(swaymsg -t get_workspaces | grep -ic "\"$3\",\"visible\":t") -gt 0 ] ; then
	swaymsg "workspace $3"
	exec $1
else
	swaymsg "workspace $3"
	if [ $(xprop -id $(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5) WM_CLASS | grep -c "$2") -eq 0 ]; then
		exec $1
	fi
fi
