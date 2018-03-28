#!/usr/bin/env bash
IFS=$'\n'
set -e

# === ENVIRONMENT VARIABLES ===
viewer=${XIVIEWER:-sxiv} # I use feh, but sxiv is more common
tmpdir=${SCREENSHOT_TMPDIR:-/tmp/screenshots}
ssdir=${SCREENSHOT_DIRECTORY:-$HOME/Pictures/Screenshots}

# === GETOPTS ===
# if no opt provided, don't shift
# `|| true` necessary because `set -e`
getopts ":ws" opt && shift || true

# === IMAGE LOCATION ===
if (( $# )); then
	# create path if it doesn't exist
	mkdir -p $(dirname "$1")
	img="$1"
else
	mkdir -p $tmpdir
	img=$(mktemp "${tmpdir}$(date +%Y-%m-%d_%T).XXX" --suffix=.png)
fi

# === TAKE SCREENSHOT ===
case $opt in # active window / selection / whole screen
	w ) maim -q -u -i $(xdotool getactivewindow) $img ;;
	s ) maim -q -u -s $img ;;
	* ) maim -q -u $img ;;
esac

# === TAKE ACTION ON FILE ===
# use the same id so the notification gets replaced every time
dunst_id=$(dunstify "" -p)

# in a loop, user may want to take many actions
while
action=$(
	dunstify --appname="$(basename $0)" \
	"Screenshot taken." "$(basename $img)" \
	--replace=$dunst_id \
	--action="clip,Copy image to clipboard" \
	--action="del,Delete image" \
	--action="edit,Edit image with GIMP" \
	--action="imgur,Upload image to Imgur" \
	--action="save,Save image to $ssdir" \
	--action="view,View image with $viewer"
)
do
	case $action in
	clip ) xclip -selection clipboard -t $(file -b --mime-type $img) < $img ;;
	del  ) rm $img; break ;;
	view ) $viewer $img ;;
	edit ) gimp $img ;;
	save ) mkdir -p $ssdir; cp $img $ssdir ;;
	imgur) imgur -d $img ;;
	# notification closed without selection
	*) break ;;
	esac
done
