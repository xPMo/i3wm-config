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

# The first parameter sets the step to change the volume by
STEP="${1:-0x1000}"

# Printing
for i in $(seq 0 $(( ${#sink_volumes[@]} - 1)) ); do
	[[ $i -ne 0 ]] && echo -n " "

	if [[ ${sink_names[$i]} = $default_sink ]]; then
		def=$i
		echo -n '✓'

		case $BLOCK_BUTTON in
		3) # right click, mute/unmute
			pactl set-sink-mute ${sink_names[$i]} toggle
			[[ ${sink_mutes[$i]} = "yes" ]] && sink_mutes[$i]="no" || sink_mutes[$i]="yes"
			;;
		4) # scroll up, increase volume
			sink_volumes[$i]=$(printf '0x%x\n' $((sink_volumes[$i] + STEP)))
			(( sink_volumes[i] > 0x10000)) && sink_volumes[$i]="0x10000"
			pacmd set-sink-volume ${sink_names[$i]} $((sink_volumes[$i]))
			;;
		5) # scroll up, increase
			sink_volumes[$i]=$(printf '0x%x\n' $((sink_volumes[$i] - STEP)))
			((sink_volumes[$i] < 0)) && sink_volumes[$i]="0x000"
			pacmd set-sink-volume ${sink_names[$i]} $((sink_volumes[$i]))
			;;
		esac

	fi

	[[ ${sink_mutes[$i]} = "yes" ]] && printf %s 'MUTE' || echo -n "${sink_volumes[$i]%??}"
done

# Short_text and color if mute or suspended
if [[ ${sink_mutes[$def]} = "yes" ]]; then
	printf \\n%s\\n%s "MUTE" "#b58900"
else
	printf \\n%s "${sink_volumes[$def]%??}"
	[[ ${sink_suspends[$def]} = "yes" ]] &&  printf \\n%s\\n "#2aa198" 
exit 0
