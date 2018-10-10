#!/usr/bin/env bash
DISPLAY=:0
USAGE="$(basename $0) [ options ]

	-n        	force launch new instance
	-x        	merge ~/.Xresources first
	-t title  	set title of window
	-o opacity	set opacity [0,100]
	-f fade   	set fade percentage [0,100]"
if command -v dtach > /dev/null; then
	export DTACH="$XDG_RUNTIME_DIR/dtach_popup_term"
	cmd="-e dtach -A $DTACH zsh"
fi
function nterm {
	DISABLE_AUTO_TITLE=true \
	PS1_HEADER=$'%{\e[38;5;246m%}δ:' \
	exec urxvtc \
	-title ${title:-popup_term} \
	-bg [${opacity:-70}]#00080a \
	-fadecolor [60]#000000 \
	-fade ${fade:-50} \
	-fn ${font:-xft:Hack:size=8} \
	$cmd # expand $cmd
}
cond() {
	swaymsg "[title=^${title:-popup_term}$]" focus 2>&1 | grep -q "ERROR"
}
font=$(xrdb -query | grep -i 'urxvt[\.\*]*font:' | cut -f2)

while getopts "hnxt:o:f:" opt; do
	case ${opt} in
		f )
			if (( 0 <= OPTARG && OPTARG <= 100 )); then
				fade="${OPTARG}"
			else echo "$USAGE"; exit 1
			fi ;;
		n ) cond(){ :; } ;;
		o )
			if (( 0 <= OPTARG && OPTARG <= 100 )); then
				opacity="$(( OPTARG ))"
			else echo "$USAGE"; exit 1
			fi ;;
		t ) title="${OPTARG}" ;;
		x ) xrdb -merge ~/.Xresources ;;
		h ) echo "$USAGE"; exit 0 ;;
	esac
done
cond && nterm
