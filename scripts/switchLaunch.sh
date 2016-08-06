#!/bin/bash
#set -euo pipefail
#IFS=$'\n\t'

# Arguments: program, program's WM_CLASS lookup, workspace

if i3-msg -t get_workspaces | grep -q "\"$2\",\"visible\":t"; then
	i3-msg "workspace $3; exec $1"
else
	i3-msg "workspace $3"
	if ! xprop -id $(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5) WM_CLASS | grep -q "$2"; then
		i3-msg "exec $1"
	fi
fi
