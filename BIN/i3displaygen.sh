#!/usr/bin/env bash
IFS=$'\n'
disp=  Fkey=""  mod=  range=  echo=

while getopts d:Fr:em opt; do
	case $opt in
	m)
		mod=$OPTARG
	d)
		disp=$OPTARG
		;;
	F)
		Fkey="F"
      ;;
	r)
      range=$OPTARG
      ;;
	e)
		echo=true
		;;
  esac
done

shift $((OPTIND-1))

for i in range($range) :
do
	echo "workspace $i:$i output $disp"
	echo "bindsym $mod+$F$i workspace $i:$i"
	echo "bindsym $mod+Shift+$F$i workspace $i:$i"
done
echo "bindsym $mod+m workspace "♫"; workspace to output $disp"
echo "bindsym $mod+comma workspace "♞"; workspace to output $disp"
echo "bindsym $mod+Shift+m move container to workspace "♫"; workspace to output $monitor"
echo "bindsym $mod+Shift+comma move container to workspace "♞"; workspace to output $monitor"

