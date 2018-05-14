#!/usr/bin/env sh
IFS="
"

# with openrc use loginctl
[ $(cat /proc/1/comm) = "systemd" ] && logind=systemctl || logind=loginctl

lock() {
	img=$(mktemp --suffix=.png)
	trap '{ rm $img; exit $?; }' INT
	import -window root $img
	# convert inplace
	convert $img -scale 20x20% -modulate 100,50 -scale 500x500% $img
	i3lock -i $img
	rm $img
}

case "$1" in
	loc*) # lock
		lock ;;
	log*|e*|x*) # logout
		i3-msg exit ;;
	sw* ) # switch user
		dm-tool switch-to-greeter ;;
	sus*) # suspend to RAM
		lock && $logind suspend ;;
	hi*) # suspend to disk
		lock && $logind hibernate ;;
	hy*) # hybrid sleep (RAM and disk)
		lock && $logind hybrid-sleep ;;
	re*) # reboot
		$logind reboot ;;
	sh*|po*) # shutdown
		$logind poweroff ;;
	run|m*)
		shift
		[ -z ${XDG_SESSION_ID:-} ] && XDG_RUNTIME_DIR="/run/user/$(id -u)"
		i3sock=$(find ${XDG_RUNTIME_DIR}/i3 -type s)
		exec i3-msg -s $i3sock "exec '$@'"
		;;
	*)
		cat >&2 << EOF
$(basename $0) [ action ]

Actions:
	lock                 locks the session
	logout | exit | x    exits i3
	switch-user          switches user
	suspend              locks the session and suspends RAM
	hibernate            locks the session and suspends to disk
	hybrid-sleep         locks the session and suspends both RAM and disk
	reboot               reboots the machine
	shutdown | poweroff  powers off the machine
	run [prog [args ..]] runs the given program with its args via \`i3-msg exec\`
	msg [prog [args ..]] runs the given program with its args via \`i3-msg exec\`

This program matches the action on just the first few characters, so 
be aware that both "log" and "logarithms" are matched by "logout".

EOF

	exit 2
esac

exit 0
