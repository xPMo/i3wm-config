#!/usr/bin/env sh
IFS='
	'
notif(){
	title=$1
	shift
	dunstify --replace $id $title "$*" --appname="i3-hint" --urgency=low
}
while [ $# -ne 0 ]; do
	case "$1" in
	help|h )
		id=${id:--4}
		notif "i3hint arguments:" \
		'help: display this help' \
		'layout: display split direction' \
		'workspace: show workspace name' \
		'version: show i3 version' \
		'[something else]: display raw text'
		exit 0
		;;
	layout|l )
		id=${id:--5}
		layout=$(
			i3-msg -t get_tree | jq --raw-output \
			'recurse(.nodes[]) | select(.nodes[].focused==true).layout'
		)
		case $layout in
		splith ) layout="split horizontal" ;;
		splitv ) layout="split vertical" ;;
		* ) ;;
		esac
		notification=$(printf '%s\n' $notification "Layout: $layout")
		;;
	workspace|w )
		id=${id:--6}
		workspace=$(
			i3-msg -t get_workspaces | jq --raw-output \
			'.[] | select(.focused==true).name'
		)
		notification=$(printf '%s\n' $notification "Workspace: $workspace")
		;;
	version|V )
		id=-7
		version=$(
			i3-msg -t get_version | jq --raw-output \
			'(.human_readable)'
		)
		notification=$(printf '%s\n' $notification "i3 Version: $version" )
		;;
	* ) # use the raw argument as notification
		id=-9
		notification=$(printf '%s\n' $notification "$@" )
		;;
	esac
	shift
done
notif $notification
