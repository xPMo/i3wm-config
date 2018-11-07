#!/usr/bin/env bash
set -e
IFS=$'\n\t'

# Requires playerctl>=2.0
PLAYERCTL="$HOME/Repos/playerctl/mesonbuild/playerctl/playerctl"

print_loop() {
	while true; do
	$PLAYERCTL --follow metadata --format \
		$'{{status}}\t{{artist}} - {{title}} {{duration(position)}}|{{duration(mpris:length)}}' | {
		while read status line; do
			# escape [&<>] for pango formatting
			line=${line/&/&amp;}
			line=${line/>/&gt;}
			line=${line/</&lt;}
			case $status in
				Paused) echo "<span foreground=#cccc00 size=smaller>$line</span>" ;;
				Playing) echo "<small>$line</small>" ;;
				Stopped) echo '<span foreground=#073642>⏹</span>' ;;
			esac
		done
	}
	# no current players
	echo '<span foreground=#dc322f>⏹</span>'
	sleep 15
	done
}

print_loop &
while read button; do
	case $button in
		1) $PLAYERCTL play-pause ;;
		3) sys-notif media ;;
	esac
done
