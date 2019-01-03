#!/usr/bin/env bash
set -e

err() {
	echo >&2 "$@"
	exit 1
}

# i3 || sway
while true; do
	case "$DESKTOP_SESSION" in
	i3)
		msg=(i3-msg)
		if command -v maim 2>/dev/null; then
			scrot=(maim)
		else
			scrot=(import -window root)
		fi
		if lock -h | grep -q -- -m; then
			lock=(i3lock -m -i)
		else
			lock=(i3lock -i)
		fi
		export DISPLAY="${DISPLAY:-:0}"
		export XAUTHORITY="${XAUTHORITY:-:0}"
		break
		;;
	sway)
		msg=(swaymsg)
		# really the only option at this point
		scrot=(grim)
		lock=(swaylock -i)
		# needs testing
		sock="$(WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-0} sway --get-socketpath)"
		break
		;;
	*)
		if pkill -0 '^sway$'; then
			DESKTOP_SESSION=sway
		elif pkill -0 '^i3$'; then
			DESKTOP_SESSION=i3
		else
			err "Could not find i3 or sway."
		fi
	esac
done


# with openrc use loginctl
[[ $(cat /proc/1/comm) = "systemd" ]] && logind=systemctl || logind=loginctl

lock() {
	img=$(mktemp --suffix=.png)
	trap '{ rm "$img"; exit $?; }' INT
	"${scrot[@]}" "$img" 2>/dev/null
	# convert inplace
	convert "$img" -scale 20x20% -modulate 100,50 -scale 500x500% "$img"
	# add -m flag (ignore media keys) if i3lock is patched to support it
	"${lock[@]}" "$img"
	rm "$img"
} 
a=$(echo $1 | tr '[A-Z]' '[a-z]')
case $a in
	f-launch)
		shift
		# class in $2, else try program name ($1)
		class="${2:-"$1"}"
		# (?i) for case-insensitivity
		con_id="$("${msg[@]}" -t get_tree | jq 'recurse(.nodes[]) |
			select(.window_properties|type=="object") | select(
				(.window_properties.class | contains("'$class'"))
				or (.window_properties.instance | contains("'$class'"))
			).id
		' | head -n1 )"
		if [[ -n "${con_id:-}" ]]; then
			"${msg[@]}" "[con_id=${con_id%% }]" focus
		else "${msg[@]}" exec exec "$1"; fi
		;;
	w-launch)
		shift
		# Arguments: program, program's WM_CLASS lookup, workspace
		if "${msg[@]}" -t get_workspaces | grep -iq "\"$3\",\"visible\":t"; then
			"${msg[@]}" "workspace $3"
			"${msg[@]}" exec $1
		else
			"${msg[@]}" "workspace $3"
			if ! [ $("${msg[@]}" -t get_tree | jq -r 'recurse(.nodes[]) | select(.focused==true).window_properties.class|ascii_downcase') = $2 ]; then
				"${msg[@]}" exec $1
			fi
		fi
		;;
	lock )
		lock ;;
	switch* ) # switch user
		dm-tool switch-to-greeter ;;
	suspend ) # suspend to RAM
		lock && "$logind" suspend ;;
	hibernate ) # suspend to disk
		lock && "$logind" hibernate ;;
	hybrid-sleep ) # hybrid sleep (RAM and disk)
		lock && "$logind" hybrid-sleep ;;
	reboot ) # reboot
		"$logind" reboot ;;
	poweroff|shutdown ) # shutdown
		"$logind" poweroff ;;
	h|help )
		cat >&2 << EOF
Usage: $(basename $0) [ action ]

Logind/init Actions:
	suspend | hibernate | hybrid-sleep | reboot | shutdown | poweroff

i3 Actions:
	f-launch             focuses program || launches program
	w-launch             focuses program on workspace || launches program on workspace
	lock                 locks the session
	switch*              switches user
	[ other ]            run with \`${msg[@]}\`

	h | help             show this help
EOF
	;;
	*)
		"${msg[@]}" "$@" || err "usage: \`$(basename $0) help\`" ;;
esac
