#!/usr/bin/env bash
IFS=$'\n'
set -e

usage() {
	cat >&2 <<- EOF
$(basename $0) [ -w | -s | -d ] [ FILE ]

Record screen, using dunst to control the process

	-w    screenshot current active window
	-s    screenshot selection
	-d    screenshot display (default)
	-h    show this help
	FILE  destination for screenshot

The last provided flag before [ FILE ] will be used,
or display by default.
EOF
}

# === ENVIRONMENT VARIABLES ===
# using xdg-open is a good second guess
# simply set $XIVIEWER in .xinitrc / .profile
# to change
viewer=${XIVIEWER:-xdg-open}
TMP=${TMPDIR:-/tmp}
tmpdir=${SCREENSHOT_TMPDIR:-$TMP/screenshots}
ssdir=${SCREENSHOT_DIRECTORY:-$HOME/Pictures/Screenshots}

# === GETOPTS ===
# if no opt provided, don't shift
# `|| true` necessary because `set -e`
opt="display"
while getopts ":dhsw" o; do
case $o in
d ) opt="display" ;;
s ) opt="selection" ;;
w ) opt="window" ;;
h ) usage && exit 0 ;;
esac
done

# === IMAGE LOCATION ===
if (( $# )); then
	# create path if it doesn't exist
	mkdir -p $(dirname "$1")
	img="$1"
else
	mkdir -p $tmpdir
	img=$(mktemp "${tmpdir}/$(date +%Y-%m-%d_%T).XXX" --suffix=.png)
fi

# === TAKE SCREENSHOT ===
case $opt in # active window / selection / whole screen
	w* ) maim -q -u -i $(xdotool getactivewindow) $img ;;
	s* ) maim -q -u -s $img ;;
	d* ) maim -q -u $img ;;
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
	--action="clip,1 Copy image to clipboard" \
	--action="del,2 Delete image" \
	--action="edit,3 Edit image with GIMP" \
	--action="imgur,4 Upload image to Imgur" \
	--action="save,5 Save image to $ssdir" \
	--action="view,6 View image with $viewer"
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
