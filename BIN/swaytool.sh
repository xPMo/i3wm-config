#!/usr/bin/env sh
IFS="
	"
set -e

# with openrc use loginctl
[ $(cat /proc/1/comm) = "systemd" ] && logind=systemctl || logind=loginctl

sock=$(find ${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/i3 -type s)
lock() {
	img=$(mktemp --suffix=.png)
	trap '{ rm $img; exit $?; }' INT
	swaygrab -s $sock $img
	# convert inplace
	convert $img -scale 20x20% -modulate 100,50 -scale 500x500% $img
	# add -m flag (ignore media keys) if i3lock is patched to support it
	i3lock $(i3lock -h 2>&1 | grep -o -- -m || true) -i $img
	rm $img
}

a=$(echo $1 | tr '[A-Z]' '[a-z]')
case $a in
	loc* ) # lock
		lock ;;
	log*|e*|x* ) # logout
		swaymsg -s $sock exit ;;
	sw*|su ) # switch user
		dm-tool switch-to-greeter ;;
	sus* ) # suspend to RAM
		lock && $logind suspend ;;
	hi* ) # suspend to disk
		lock && $logind hibernate ;;
	hy*|hs ) # hybrid sleep (RAM and disk)
		lock && $logind hybrid-sleep ;;
	re*|rb ) # reboot
		$logind reboot ;;
	sh*|po*|sd ) # shutdown
		$logind poweroff ;;
	run|m* )
		if [ $1 = run ]; then
			shift
			exec swaymsg -s $sock -- "exec exec $@"
		else
			shift
			exec swaymsg -s $sock -- "$@"
		fi
		;;
	* )
		cat >&2 << EOF
Usage: $(basename $0) [ action ]

Actions:
	lock                      locks the session
	logout | exit | x         exits i3
	switch-user | su          switches user
	suspend                   locks the session and suspends RAM
	hibernate                 locks the session and suspends to disk
	hybrid-sleep | hs         locks the session and suspends both RAM and disk
	reboot | rb               reboots the machine
	shutdown | poweroff | sd  powers off the machine
	run [prog [args ..]]      runs the given program with its args
	                          via \`i3-msg exec\`
	msg [cmd [cmd ...]]       runs the i3 command(s) via \`i3-msg\`
	help                      show this help

This program matches the action on just the first few characters
(unless using an abbreviation). So be aware that both "log" and
"logarithms" are matched by "logout", for example.

EOF
	case $a in
		--h*|-h*|h*) exit 0 ;;
		*) exit 1
	esac
esac
