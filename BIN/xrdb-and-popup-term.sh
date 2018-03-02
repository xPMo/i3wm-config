#!/usr/bin/env bash
DISPLAY=:0
xrdb -merge ~/.Xresources
i3-msg "[title=^popup_term$]" focus 2>&1 | grep -q "ERROR" \
	&& exec i3-msg exec -- "--no-startup-id DISABLE_AUTO_TITLE=true exec urxvt -title 'popup_term' -bg '[80]#000c0f' -fadecolor '[60]#000000'"
