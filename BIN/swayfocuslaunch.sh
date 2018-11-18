#!/usr/bin/env sh
IFS="
" # IFS=$'\n'
#Arguments: program, program's WM_CLASS lookup

# class in $2, else try program name ($1)
class=${2:-$1}
# (?i) for case-insensitivity
con_id=$( swaymsg -t get_tree | jq 'recurse(.nodes[]) |
	select(.window_properties|type=="object") | select(
		(.window_properties.class | contains("'$class'"))
		or (.window_properties.instance | contains("'$class'"))
	).id
' | head -n1 )
if [ -n "${con_id:-}" ]; then
	swaymsg "[con_id=${con_id%% }]" focus
else swaymsg exec exec "$1"; fi
