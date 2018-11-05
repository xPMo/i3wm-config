#!/usr/bin/env sh
#set -euo pipefail
IFS="
" # IFS=$'\n'
#Arguments: program, program's WM_CLASS lookup, workspace
if [ $(i3-msg -t get_workspaces | grep -ic "\"$3\",\"visible\":t") -gt 0 ] ; then
	i3-msg "workspace $3"
	exec $1
else
	i3-msg "workspace $3"
	if [ i3-msg -t get_tree | jq -r 'recurse(.nodes[]) | select(.focused==true).window_properties.class|ascii_downcase' = $2 ]; then
		exec $1
	fi
fi
