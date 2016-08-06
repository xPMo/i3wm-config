#!/bin/bash


if [ $(i3-msg [class="$2"] focus | grep -ic "false") -gt 0 ]; then
	i3-msg "workspace $3, exec $1"
fi
