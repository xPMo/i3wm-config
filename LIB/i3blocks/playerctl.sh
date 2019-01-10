#!/usr/bin/env bash
set -e
IFS=$'\n\t'

seek=3

while true; do
	# requires playerctl>=2.0
	playerctl --follow metadata --format \
		$'{{status}}\t{{artist}} - {{title}} {{duration(position)}}|{{duration(mpris:length)}}' |
	while read -r status line; do
		# escape [&<>] for pango formatting
		line="${line/&/&amp;}"
		line="${line/>/&gt;}"
		line="${line/</&lt;}"
		case $status in
			Paused) echo '<span foreground="#cccc00" size="smaller">'"$line"'</span>' ;;
			Playing) echo "<small>$line</small>" ;;
			*) echo '<span foreground="#073642">⏹</span>' ;;
		esac
	done
	# no current players
	echo '<span foreground=#dc322f>⏹</span>'
	sleep 15
done &

# requires i3blocks@6e8b51d or later
while read -r button; do
	case "$button" in
		1) playerctl play-pause ;;
		3) sys-notif media ;;
		4) playerctl position "$seek+" ;;
		5) playerctl position "$seek-" ;;
	esac
done
