#!/usr/bin/env bash
set -eu

eval $(slop -q -b 4 -c 0.03,0.21,0.26,0.5 -t 0 -f "X=%x Y=%y W=%w H=%h")
swaymsg floating enable && xdotool getactivewindow windowmove $X $Y && xdotool getactivewindow windowsize $W $H
