#!/usr/bin/env sh
IFS="
"
img=$(mktemp --suffix=.png)
trap '{ rm $img; exit $?; }' INT
import -window root $img
# convert inplace
convert $img -scale 20x20% -modulate 100,50 -scale 500x500% $img
i3lock -i $img
rm $img
