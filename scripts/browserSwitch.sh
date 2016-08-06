#!/bin/bash

if [ $(i3-msg [class="irefox"] focus | grep -ic "false") -gt 0 ]; then
	i3-msg "workspace $1, exec firefox"
	echo hitrue
fi
