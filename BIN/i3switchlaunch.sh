#!/usr/bin/env bash
#set -euo pipefail
#IFS=$'\n\t'
#Arguments: program, program's WM_CLASS lookup, workspace
if [ $(i3-msg -t get_workspaces | grep -ic "\"$3\",\"visible\":t") -gt 0 ] ; then
	i3-msg "workspace $3"
	exec $1
else
	i3-msg "workspace $3"
	if [ $(xprop -id $(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5) WM_CLASS | grep -c "$2") -eq 0 ]; then
		exec $1
	fi
fi
