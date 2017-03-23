#!/usr/bin/env bash

#click, play/pause
[ $BLOCK_BUTTON = 1 ] && playerctl play-pause

player_status=$(playerctl status)
title=''
artist=''

# exit 0 lets the block text be cleared
if [ -z $player_status ]; then exit 0; fi
if [ $player_status = "Stopped" ]; then
	printf "⏹\\n⏹\\n#073642"
else
	title=$(playerctl metadata title)
	artist=$(playerctl metadata artist)

	# Substring: if length>24, substring 0-22 with ellipsis
	[ ${#title} -gt 24 ] && echo -n "${title:0:23}‥ - " || echo -n "$title - "
	# Substring: if length>20, substring 0-19 with ellipsis
	[ ${#artist} -gt 20 ] && echo "${artist:0:19}‥" || echo "$artist"

	# Short text
	# Substring: if length>12, substring 0-11 with ellipsis
	[ ${#title} -gt 12 ] && echo -n "${title:0:11}‥|" || echo -n "$title"
	# Substring: if length>20, substring 0-18 with ellipsis
	[ ${#artist} -gt 8 ] && echo "${artist:0:7}‥" || echo "$artist"
	[ $player_status = "Paused" ] && echo -n "#cccc00"
fi

# Right click, get notification with info
[ $BLOCK_BUTTON = 3 ] && notify-send "$title" "by $artist\non $(playerctl metadata album)" -i $(playerctl metadata mpris:artUrl)
exit 0