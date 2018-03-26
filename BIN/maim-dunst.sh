#!/usr/bin/env bash
# POSIX doesn't allow this (yet)
IFS=$'\n'
set -e

ssdir=${SCREENSHOT_DIRECTORY:-$HOME/Pictures/Screenshots}
[ -z "${img}" ] && img=$(mktemp "$(date +%Y-%m-%d_%T).XXX" --suffix=.png)
case $1 in # active window / selection / whole screen
	w* ) maim -q -u -i $(xdotool getactivewindow) $img ;;
	s* ) maim -q -u -s $img ;;
	*  ) maim -q -u $img ;;
esac

dunst_id=$(dunstify "" -p)
while
action=$(
	dunstify --appname="$(basename $0)" \
	"Screenshot taken." "$(basename $img)" \
	--replace=$dunst_id \
	--action="clip,Copy image to clipboard" \
	--action="edit,Edit image with GIMP" \
	--action="imgur,Upload image to Imgur" \
	--action="save,Save image to $ssdir" \
	--action="view,View image with $XIVIEWER"
)
do
	case $action in
	clip ) xclip -selection clipboard -t $(file -b --mime-type $img) < $img ;;
	view ) $XIVIEWER $img ;;
	edit ) gimp $img ;;
	save ) [ -d $ssdir ] || mkdir -p $ssdir; cp $img $ssdir ;;
	imgur) imgur -d $img ;;
	*) break ;;
	esac
done
