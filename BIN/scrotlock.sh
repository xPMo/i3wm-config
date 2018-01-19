#!/usr/bin/env sh

# POSIX doesn't allow this (yet)
#IFS=$'\n'
IFS="
" # but it does allow this

img=/tmp/lock.png
if [ ! -f $img ]; then
	touch $img
fi
scrot $img
convert $img -scale 20x20% -modulate 100,50 -scale 500x500% $img
exec i3lock -i $img
