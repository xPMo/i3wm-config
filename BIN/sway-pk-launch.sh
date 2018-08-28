#!/usr/bin/env sh
# i3pklaunch: uses pkill to test if a program exists before launching,
# then attempts to focus with i3-msg

# Arguments: "program [args]", program's WM_CLASS lookup

prog=${1%% *}
pkill -0 $prog || i3-msg exec exec $1

# class in $2, else try program name ($1)
# (?i) for case-insensitivity
class=${2:-(?i)$prog}
swaymsg "[class=^$class]" focus
swaymsg "[title=^$class]" focus
