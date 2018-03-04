#!/usr/bin/env bash
DISPLAY=:0
USAGE="$0 [ options ]

	-n        	force launch new instance
	-x        	merge ~/.Xresources first
	-t title  	set title of window
	-o opacity	set opacity [0,100]
	-f fade   	set fade percentage [0,100]"
function nterm {
	i3-msg exec -- "--no-startup-id DISABLE_AUTO_TITLE=true \
		exec urxvt \
		-title '${title:-popup_term}' \
		-bg '[${opacity:-70}]#00080a' \
		-fadecolor '[60]#000000' \
		-fade ${fade:-30} \
		-fn '${font:-xft:Hack:size=8}' \
		-letsp ${letsp:- -1}
	"
}
cond() {
	i3-msg "[title=^${title:-popup_term}$]" focus 2>&1 | grep -q "ERROR"
}
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
