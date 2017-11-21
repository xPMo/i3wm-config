#!/usr/bin/env bash
SINK=$(pacmd dump | grep lt-si | cut --delimiter=' ' -f 2)
# The first parameter sets the step to change the volume by (and units to display)
# Expected in the form "(+|-)([0-9]+)%"
if [ -z $1 ]; then
	pactl set-sink-mute $SINK toggle
else
	pactl set-sink-mute $SINK false
	# This may be in in % or dB (eg. 5% or 3dB)
	pactl set-sink-volume $SINK ${1}
fi
exec pkill -RTMIN+10 i3blocks
