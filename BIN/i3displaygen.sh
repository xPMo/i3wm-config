#!/usr/bin/env bash
IFS=$'\n'

while getopts d:Fr:m opt; do
	case $opt in
	m) mod=$OPTARG ;;
	d) disp=$OPTARG ;;
	F) F="F" ;;
	r) range=$OPTARG ;;
	*) :;;
  esac
done

shift $((OPTIND-1))

for i in range $range  :
do
	echo "workspace $i:$i output $disp"
	echo "bindsym $mod+$F$i workspace $i:$i"
	echo "bindsym $mod+Shift+$F$i workspace $i:$i"
done
echo "bindsym $mod+m workspace \"♫\"; workspace to output $disp"
echo "bindsym $mod+comma workspace \"♞\"; workspace to output $disp"
echo "bindsym $mod+Shift+m move container to workspace \"♫\""
echo "bindsym $mod+Shift+comma move container to workspace \"♞\""

