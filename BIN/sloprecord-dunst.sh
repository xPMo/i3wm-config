#!/usr/bin/env bash
IFS=$'\n\t'
set -e

usage() {
	cat >&2 << EOF
$(basename $0) [ -w | -s | -d ] [ FILE ]

Record screen, using dunst to control the process

Use capitalized options to record with audio

	-W -w record current active window
	-S -s record selection
	-D -d record display
	-a    record audio only
	-i    interactive mode: ask method via dunst
	-h    show this help
	FILE  destination for recording

The last provided flag before [ FILE ] will be used,
or display by default.
EOF
}

# === ENVIRONMENT VARIABLES ===
viewer=${XVVIEWER:-xdg-open}
aviewer=${XAVIEWER:-xdg-open}
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
opt="display"
while getopts ":dhsw" o; do
	case $o in
	d|s|w) audio="off" ;;
	D|S|W) audio="on"  ;;
	esac
	case $o in
	d|D) opt="display"; shift ;;
	s|S) opt="selection"; shift ;;
	w|W) opt="window"; shift ;;
	a  ) opt="audio"; shift ;;
	h  ) usage && exit 0 ;;
	esac
done

# === MANUAL RECORD LOCATION ===
trap '{ rm $dest; kill $RECORD_PID || true; rm $pidfile; exit $?; }' INT
if (( $# )); then
	# create path if it doesn't exist
	mkdir -p $(dirname "$1")
	dest="$1"
fi

# === PARECORD ===
if [ $opt = "audio" ]; then
	if [ -z ${dest:-} ]; then
		mkdir -p $tmpdir
		dest=$(mktemp "${tmpdir}/$(date +%Y-%m-%d_%T).XXX" --suffix=.ogg)
	fi

	# === START RECORDING ===
	case ${dest##*.} in
		ogg )
			parec $PAREC_OPTS | oggenc -b 192 -o $dest --raw - &
			RECORD_PID=$!
			;;
		mp3 )
			parec $PAREC_OPTS --format=s16le | \
			lame -r --quiet -q 3 --lowpass 17 --abr 192 - $dest
			RECORD_PID=$!
			;;
		* ) echo "Unsupported format" >&2; exit 1 ;;
	esac

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
		"Recording finished." "$(basename $dest)" \
		--replace=$dunst_id \
		--action="del, Delete audio file" \
		--action="edit, Edit audio" \
		--action="dir, Open containing directory" \
		--action="save, Save audio to $recorddir" \
		--action="view, Listen to audio with $aviewer"
	)
	do
		case $action in
		del  ) rm $dest; break ;;
		view ) $aviewer $dest ;;
		dir  ) xdg-open $(dirname $dest) ;;
		edit ) audacity $dest ;;
		save ) mkdir -p $recorddir; cp $dest $recorddir ;;
		# notification closed without selection
		*) break ;;
		esac
	done

# === FFMPEG ===
else
	if [ -z ${dest:-} ]; then
		mkdir -p $tmpdir
		dest=$(mktemp "${tmpdir}/$(date +%Y-%m-%d_%T).XXX" --suffix=.mkv)
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
		-r 15 -f alsa -i pulse "$dest" >/dev/null 2>&1 &
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
		"Recording finished." "$(basename $dest)" \
		--replace=$dunst_id \
		--action="del, Delete video" \
		--action="edit, Edit video" \
		--action="dir, Open containing directory" \
		--action="gfyc, Upload video to Gfycat" \
		--action="save, Save video to $recorddir" \
		--action="view, View video with $viewer"
	)
	do
		case $action in
		del  ) rm $dest; break ;;
		view ) $viewer $dest ;;
		dir  ) xdg-open $(dirname $dest) ;;
		edit ) kdenlive $dest ;;
		save ) mkdir -p $recorddir; cp $dest $recorddir ;;
		gfyc ) gfycat -d $dest ;;
		# notification closed without selection
		*) break ;;
		esac
	done
fi
