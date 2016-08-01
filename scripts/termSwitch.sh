#!/bin/bash
#set -euo pipefail
#IFS=$'\n\t'

if i3-msg -t get_workspaces | grep -q '"11:~$","visible":t'; then
	i3-msg "workspace 11:~$; exec i3-sensible-terminal"
else
	i3-msg "workspace 11:~$"
	if ! xprop -id $(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5) WM_CLASS | grep -q "term"; then
		i3-msg "exec i3-sensible-terminal"
	fi
fi
