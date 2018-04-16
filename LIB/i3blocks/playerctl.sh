#!/usr/bin/env bash
IFS=$'\n'
#click, play/pause
[[ $BLOCK_BUTTON = 1 ]] && playerctl play-pause

player_status=$(playerctl status)

pango_escape() {
	sed -e 's/&/\&amp;/g; s/</&lt;/g; s/>/\&gt;/g'
}

# exit 0 lets the block text be cleared
if [ -z $player_status ]; then exit 0; fi
if [ $player_status = "Stopped" ]; then
	printf "⏹\\n⏹\\n#073642"
else
	title="$(playerctl metadata title | pango_escape)"
	artist="$(playerctl metadata artist | pango_escape)"
	length="${title:- }${artist:- }"

	# small text if longer than 20 characters
	[ ${#length} -gt 20 ] && p="$p<small>"	
	# Substring: if title>32, substring 0-31 with ellipsis
	[ ${#title} -gt 32 ] && p="$p${title:0:31}‥ - " || p="$p$title - "
	# Substring: if artist>20, substring 0-19 with ellipsis
	[ ${#artist} -gt 20 ] && p="$p${artist:0:19}‥" || p="$p$artist"
	[ ${#length} -gt 20 ] && echo "$p</small>" || echo $p

	# Short text, always small
	echo -n "<small>"
	# Substring: if length>12, substring 0-11 with ellipsis
	[ ${#title} -gt 12 ] && echo -n "${title:0:11}‥|" || echo -n "$title|"
	# Substring: if length>20, substring 0-18 with ellipsis
	[ ${#artist} -gt 8 ] && echo -n "${artist:0:7}‥" || echo -n "$artist"
	echo "</small>"
	[ $player_status = "Paused" ] && echo -n "#cccc00"
fi

# Right click, get notification with info
# dunstify uses postive ids by default, so use a negative id here
# cheat and use $IFS as newline
[[ $BLOCK_BUTTON = 3 ]] && dunstify --replace=-310 \
	"$title" "by $artist${IFS}on $(playerctl metadata album)" \
	--icon=$(playerctl metadata mpris:artUrl) --appname=playerctl
exit 0
