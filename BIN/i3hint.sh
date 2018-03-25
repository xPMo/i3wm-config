#!/usr/bin/env sh
notification() {
	notify-send "$1" "$2" --category="i3-hint" --urgency=low
}
while [ $# -gt 0 ]; do
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
	* ) # use the raw argument as notification text
		notification "$1"
		;;
	esac
	shift
done
