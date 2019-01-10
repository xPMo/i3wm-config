#!/usr/bin/env sh
IFS='
'
s="$(pacmd dump | awk '/^set-default-si/{print $2}')"
# The first parameter sets the step to change the volume by (and units to display)
# Expected in the form "(+|-)([0-9]+)%"
if [ -z "${1:-}" ]; then
	pactl set-sink-mute "$s" toggle
else
	pactl set-sink-mute "$s" false
	# This may be in in % or dB (eg. 5% or 3dB)
	pactl set-sink-volume "$s" "$@"
fi
exec pkill -RTMIN+10 i3blocks
