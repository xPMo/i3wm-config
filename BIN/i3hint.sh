#!/usr/bin/env sh
IFS='
	'
# shellcheck disable=1090
. "$(dirname "$(realpath "$0")")/../LIB/i3/i3tool.sh"
id=$I3HINTID

notif(){
	title=$1
	shift
	dunstify --replace "$id" "$title" "$*" --appname="i3-hint" --urgency=low
}

while [ $# -ne 0 ]; do
	case "$1" in
	help|h )
		id="${id:--4}"
		# shellcheck disable=SC2016
		notif "i3hint arguments:" \
		'h|help: display this help' \
		'l|layout: display split direction' \
		'w|workspace: show workspace name' \
		'V|version: show i3 version' \
		'g|gaps: show $gaps_mode help' \
		'[something else]: display raw text'
		exit 0
		;;
	layout|l )
		id="${id:--5}"
		layout="$(i3tool --session i3 get_layout)"
		case "$layout" in
		splith ) layout="split horizontal" ;;
		splitv ) layout="split vertical" ;;
		#stacked|tabbed) layout=$layout ;;
		esac
		notification="$(printf '%s\n' "$notification" "Layout: $layout")"
		;;
	workspace|w )
		id="${id:--6}"
		workspace="$(i3tool --session i3 get_workspace)"
		notification=$(printf '%s\n' "$notification" "Workspace: $workspace")
		;;
	version|V )
		id="${id:--7}"
		version="$(i3tool --session i3 get_version)"
		notification="$(printf '%s\n' "$notification" "i3 Version: $version" )"
		;;
	gaps|g )
		id="${id:--8}"
		notification="$(printf '%s\n' "$notification" "Change gaps:" \
		"  [ <b>+</b> | <b>-</b> ]: Increase/decrease gaps for all workspaces" \
		"  [ <b>0</b> | <b>5</b> ]: Set gaps for all workspaces to 0 or 5" \
		"  Shift+[ <b>+</b> | <b>-</b> | <b>0</b> | <b>5</b> ] change gaps for just this workspace"
		)"
		;;
	* ) # use the raw argument as notification
		id="${id:--9}"
		notification=$(printf '%s\n' "$notification" "$@" )
		;;
	esac
	shift
done
# call notif() with splitting
# shellcheck disable=SC2086
notif $notification
