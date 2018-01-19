#!/usr/bin/env bash
IFS=$'\n'

# Rewritten for pulse-only with bluetooth switching
# TODO: 
# $default_sink will be a flag set if the instance is default
# to split the dump on newline: 

sink_names=()
sink_volumes=()
sink_mutes=()
sink_suspends=()

for line in $(pacmd dump); do
	# get first space-delimited word
	case ${line%% *} in
		set-default-sink)
			# get sink name
			default_sink=${line#* } 
			;;
		set-sink-volume)
			# get each sink's volume
			# name is 2/3, volume is 3/3
			sink_names+=($(echo -n $line | cut -d ' ' -f 2) )
			# volume is in hex (0x10000 is 100%), I could convert it, but this looks cool
			sink_volumes+=(${line##* }) ;;
		set-sink-mute)
			# mute is immediately after volume, so sink_names line up
			# sink-mute is yes/no
			sink_mutes+=(${line##* })
			;;
		suspend-sink)
			# get whether sink is muted
			# sink-suspend is yes/no
			sink_suspends+=(${line##* })
	esac
done


# The first parameter sets the step to change the volume by (and units to display)
# This may be in in % or dB (eg. 5% or 3dB)
STEP="0x1000"
default_volume=''

# Printing
for i in $(seq 0 $(( ${#sink_volumes[@]} - 1)) ); do
	[ $i -ne 0 ] && echo -n " "
	[ ${sink_names[$i]} = $default_sink ] && default_volume=${sink_volumes[$i]} && default_mute=${sink_mutes[$i]} && default_suspended=${sink_suspends[$i]} && echo -n '✓' && case $BLOCK_BUTTON in
		# right click, mute/unmute
		3) pactl set-sink-mute $default_sink toggle
		   [ $default_mute = "yes" ] && default_mute="no" || default_mute="yes"
		   [ ${sink_mutes[$i]} = "yes" ] && sink_mutes[$i]="no" || sink_mutes[$i]="yes"
		   ;;
		# scroll up, increase volume
		4) [ $((default_volume)) -ge $((0x10000)) ] && default_volume="0x10000" || default_volume=$((default_volume + STEP))
		   pacmd set-sink-volume $default_sink $((default_volume)) 
		   ;;
		# scroll up, increase
		5) default_volume=$((default_volume - STEP))
		   pacmd set-sink-volume $default_sink $((default_volume))
		   ;;
	esac
	[ ${sink_mutes[$i]} = "yes" ] && printf %s 'MUTE' || echo -n "${sink_volumes[$i]%??}"
done

# Short_text and color if mute or suspended
[ $default_mute = "yes" ] && printf \\n%s\\n%s "MUTE" "#b58900" || printf \\n%s "${default_volume%??}" && [ $default_suspended = "yes" ] &&  printf \\n%s\\n "#2aa198" 
exit 0
