#!/usr/bin/env sh
notification() { # dunst uses positive numbers by default, just take id=-8
	dunstify --replace -8 "$1" "$2" --appname="i3-hint" --urgency=low
}
case "$1" in
layout )
	layout=$(
		i3-msg -t get_tree | jq --raw-output \
		'recurse(.nodes[]) | select(.nodes[].focused==true).layout'
	)
	case $layout in
	splith ) layout="split horizontal" ;;
	splitv ) layout="split vertical" ;;
	* ) ;;
	esac
	notification "Layout: $layout"
	;;
workspace )
	workspace=$(
		i3-msg -t get_workspaces | jq --raw-output \
		'.[] | select(.focused==true).name'
	)
	notification "Workspace: $workspace"
	;;
version )
	version=$(
		i3-msg -t get_version | jq --raw-output \
		'(.human_readable)'
	)
	notification "Version: $version"
	;;
gaps )
	notification "Change gaps:" \
	"[ <b>+</b> | <b>-</b> ]: Increase/decrease gaps for all workspaces
[ <b>0</b> | <b>5</b> ]: Set gaps for all workspaces to 0 or 5
Shift+[ <b>+</b> | <b>-</b> | <b>0</b> | <b>5</b> ] change gaps for just this workspace"
	;;
* ) # use the raw argument as notification
	notification "$@"
	;;
esac
shift
