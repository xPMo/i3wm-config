#!/bin/bash
img=/tmp/lock.png
if [ ! -f $img ]; then
	touch $img
fi
scrot $img
convert $img -blur 0x12 $img
i3lock -i $img -d -I 10
