#!/usr/bin/env bash
IFS=$'\n\t'
set -ex

# === ENVIRONMENT VARIABLES ===
viewer=${XVVIEWER:-xdg-open} # I use feh, but sxiv is more common
tmpdir=${RECORD_TMPDIR:-/tmp/records}
recorddir=${RECORD_DIR:-$HOME/Videos/Records}
if [ -d $XDG_RUNTIME_DIR ]; then
	pidfile=${XDG_RUNTIME_DIR}/sloprecord.pid
else
	pidfile=$tmpdir/sloprecord.pid
fi

# === END RECORDING IF IN PROGRESS ===
if [[ -f $pidfile ]]; then
	read pid -r < $pidfile || true
	kill $pid || true
	rm $pidfile
	exit 0
fi

# === GETOPTS ===
# if no opt provided, don't shift
# `|| true` necessary because `set -e`
getopts ":ws" opt && shift || true

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
w ) # active window
	set_dimensions $(xdotool getactivewindow)
	;;
s ) # selection || true because of EOF
	read -r X Y W H < <(slop -f $'%x\t%y\t%w\t%H') ||true
	;;
* ) # whole screen
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
wait $RECORD_PID
rm "$pidfile"

# === TAKE ACTION ON FILE ===
# use the same id so the notification gets replaced every time
dunst_id=$(dunstify "" -p)

# in a loop, user may want to take many actions
while
action=$(
	dunstify --appname="$(basename $0)" \
	"Screenshot taken." "$(basename $vid)" \
	--replace=$dunst_id \
	--action="del, Delete video" \
	--action="edit, Edit video" \
	--action="gfyc, Upload video to gfycat" \
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
