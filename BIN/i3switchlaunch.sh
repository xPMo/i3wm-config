#!/usr/bin/env sh
set -eu
IFS="
	"
#Arguments: program, program's WM_CLASS lookup, workspace
if [ $(swaymsg -t get_workspaces | grep -ic "\"$3\",\"visible\":t") -gt 0 ] ; then
	swaymsg "workspace $3"
	exec $1
else
	swaymsg "workspace $3"
	if ! [ $(swaymsg -t get_tree | jq -r 'recurse(.nodes[]) | select(.focused==true).window_properties.class|ascii_downcase') = $2 ]; then
		exec $1
	fi
fi
