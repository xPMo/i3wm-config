#!/bin/bash

if i3-msg [class="irefox"] focus | grep -q ERROR; then
	i3-msg "workspace 12:WWW, exec firefox"
	echo true
fi
