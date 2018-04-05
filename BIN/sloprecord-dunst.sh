#!/usr/bin/env bash
IFS=$'\n\t'
set -e

usage() {
	cat >&2 <<- EOF
$(basename $0) [ -w | -s | -d ] [ FILE ]

Record screen, using dunst to control the process

	-w    record current active window
	-s    record selection
	-d    record display (default)
	-h    show this help
	FILE  destination for recording

The last provided flag before [ FILE ] will be used,
or display by default.
EOF
}

# === ENVIRONMENT VARIABLES ===
viewer=${XVVIEWER:-xdg-open}
tmpdir=${RECORD_TMPDIR:-/tmp/records}
recorddir=${RECORD_DIR:-$HOME/Videos/Records}
if [ -d $XDG_RUNTIME_DIR ]; then
	pidfile=${XDG_RUNTIME_DIR}/sloprecord.pid
else
	pidfile=$tmpdir/sloprecord.pid
fi

# === END RECORDING IF IN PROGRESS ===
if [[ -f $pidfile ]]; then
	read -r pid < $pidfile || true
	kill -2 $pid || true
	rm $pidfile
	exit 0
fi

# === GETOPTS ===
# get last opt: -w or -s
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

# === RECORD LOCATION ===
trap '{ rm $vid; kill $RECORD_PID || true; rm $pidfile; exit $?; }' INT
if (( $# )); then
	# create path if it doesn't exist
	mkdir -p $(dirname "$1")
	vid="$1"
else
	mkdir -p $tmpdir
	vid=$(mktemp "${tmpdir}/$(date +%Y-%m-%d_%T).XXX" --suffix=.mkv)
fi

# If given a valid window ID, will get the dimensions of that window
# Otherwise will get the dimensions of the root window
set_dimensions(){
	# Sets X, Y, W, H for the record function to use
	# It is important that IFS=$'\n' or $'\n\t' here
	IFS=$'\n'
	for line in $(
		[[ -n ${1:-} ]] && xwininfo -id $1 || xwininfo -root
	); do
		case $line in # xargs is a good whitespace cleaner
			*Width:* ) W=$(echo ${line##*:} | xargs) ;;
			*Height:*) H=$(echo ${line##*:} | xargs) ;;
			*Abs*X:* ) X=$(echo ${line##*:} | xargs) ;;
			*Abs*Y:* ) Y=$(echo ${line##*:} | xargs) ;;
		esac
	done
}

# === GET RECORD REGION ===
case $opt in # active window
w* ) # active window
	set_dimensions $(xdotool getactivewindow)
	;;
s* ) # selection || true because of EOF
	read -r X Y W H < <(slop -f $'%x\t%y\t%w\t%H') ||true
	;;
d* ) # whole screen
	set_dimensions
	;;
esac

# === START RECORDING ===
if [[ -n ${X:-} ]] && [[ -n ${Y:-} ]]; then
	url="${DISPLAY}+${X},${Y}"
else
	url=$DISPLAY
fi
ffmpeg -y -f x11grab -s "${W}x${H}" -i "$url" \
	-r 15 -f alsa -i pulse "$vid" >/dev/null 2>&1 &
RECORD_PID=$!
echo $RECORD_PID > "$pidfile"
notify-send --app-name=$(basename $0) \
	--icon='media-record' \
	"Recording" "Call this again to end recording."

# === STOP RECORDING ===
wait $RECORD_PID || echo $?

# === TAKE ACTION ON FILE ===
# use the same id so the notification gets replaced every time
dunst_id=$(dunstify "" -p)

# in a loop, user may want to take many actions
while
action=$(
	dunstify --appname="$(basename $0)" \
	--icon='media-record' \
	"Recording finished." "$(basename $vid)" \
	--replace=$dunst_id \
	--action="del, Delete video" \
	--action="edit, Edit video" \
	--action="gfyc, Upload video to Gfycat" \
	--action="save, Save video to $recorddir" \
	--action="view, View video with $viewer"
)
do
	case $action in
	del  ) rm $vid; break ;;
	view ) $viewer $vid ;;
	edit ) kdenlive $vid ;;
	save ) mkdir -p $recorddir; cp $vid $recorddir ;;
	gfyc ) gfycat -d $vid ;;
	# notification closed without selection
	*) break ;;
	esac
done
