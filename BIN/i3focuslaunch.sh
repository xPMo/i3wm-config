#!/usr/bin/env sh
IFS="
" # IFS=$'\n'
#Arguments: program, program's WM_CLASS lookup

# class in $2, else try program name ($1)
# (?i) for case-insensitivity
class=${2:-(?i)$1}
# focus $class if possible, else exec $1
# TODO: i3-msg -t get_tree | jq "recurse(.nodes[])|select(.window_properties.class==\"$class\").id"
i3-msg "[class=^$class]" focus 2>&1 | grep -q "ERROR" \
	&& i3-msg "[title=^$class]" focus 2>&1 | grep -q "ERROR" \
	&& i3-msg exec exec "$1"
