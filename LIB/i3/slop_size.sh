#!/usr/bin/env sh
eval "$(slop -q -b 4 -c 0.03,0.21,0.26,0.5 -t 0 -f \
	"i3-msg floating enable, move position %x %y, resize set %w %h")"
