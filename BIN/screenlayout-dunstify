#!/usr/bin/env sh
IFS="
	"
set -euf
dir=$HOME/.screenlayout

# get user choice
layout=$(ls $dir | sed 's/.sh$//' | rofi -i -p "Display layout" -dmenu)

# run script (source to avoid unnecessary process)
. $dir/${layout}.sh

# notification informing user of change
dunstify --icon=preferences-desktop-display \
	--appname=Screenlayout --replace=-17 \
	"Display: $layout"
