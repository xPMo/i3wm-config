#!/usr/bin/env bash
DISPLAY=:0
function usage {
	echo "$0 [ options ]

	-n        	force launch new instance
	-x        	merge ~/.Xresources first
	-t title  	set title of window
	-o opacity	set opacity [0,100]
	-f fade   	set fade percentage [0,100]"
	exit 1
}
function nterm {
	i3-msg exec -- "--no-startup-id DISABLE_AUTO_TITLE=true \
		exec urxvt \
		-title '${title:-popup_term}' \
		-bg '[${opacity:-70}]#00080a' \
		-fadecolor '[60]#000000' \
		-fade ${fade:-30}"
}
cond() {
	i3-msg "[title=^${title:-popup_term}$]" focus 2>&1 | grep -q "ERROR"
}
while getopts "hnxt:o:f:" opt; do
	case ${opt} in
		f )
			if (( 0 <= OPTARG && OPTARG <= 100 )); then
				fade="${OPTARG}"
			else usage
			fi ;;
		n ) cond(){ :; } ;;
		o )
			if (( 0 <= OPTARG && OPTARG <= 100 )); then
				opacity="$(( OPTARG ))"
			else usage
			fi ;;
		t ) title="${OPTARG}" ;;
		x ) xrdb -merge ~/.Xresources ;;
		h ) usage ;;
	esac
done
cond && nterm
