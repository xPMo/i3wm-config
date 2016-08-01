#!/bin/bash
#set -euo pipefail
#IFS=$'\n\t'

if i3-msg -t get_workspaces | grep -q '"31:~#","visible":t'; then
	i3-msg "workspace 31:~#"
	i3-msg "exec i3-sensible-terminal"
else
	i3-msg "workspace 31:~#"
	if ! xprop -id $(xprop -root _NET_ACTIVE_WINDOW | cut -d ' ' -f 5) WM_CLASS | grep -q "term"; then
		i3-msg "exec i3-sensible-terminal"
	fi
fi
