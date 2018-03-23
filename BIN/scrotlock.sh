#!/usr/bin/env sh

# POSIX doesn't allow this (yet)
#IFS=$'\n'
IFS="
" # but it does allow this

img=$(mktemp --suffix=.png)
if command -v maim > /dev/null; then
	maim $img
elif command -v scrot > /dev/null; then
	scrot $img
else
	import -window root $img
fi
# convert inplace
convert $img -scale 20x20% -modulate 100,50 -scale 500x500% $img
i3lock -i $img
rm $img
