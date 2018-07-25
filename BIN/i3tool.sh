#!/usr/bin/env sh
IFS="
"
set -e

# with openrc use loginctl
[ $(cat /proc/1/comm) = "systemd" ] && logind=systemctl || logind=loginctl

lock() {
	img=$(mktemp --suffix=.png)
	trap '{ rm $img; exit $?; }' INT
	maim $img 2>/dev/null || import -window root $img
	# convert inplace
	convert $img -scale 20x20% -modulate 100,50 -scale 500x500% $img
	i3lock -i $img
	rm $img
}

a=$(echo $1 | tr '[A-Z]' '[a-z]')
case $a in
	loc* ) # lock
		lock ;;
	log*|e*|x* ) # logout
		i3-msg exit ;;
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
		sock=$(find ${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/i3 -type s)
		if [ $1 = run ]; then
			shift
			exec i3-msg -s $sock -- "exec exec $@"
		else
			shift
			exec i3-msg -s $sock $@
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

This program matches the action on just the first few characters
(unless using an abbreviation). So be aware that both "log" and
"logarithms" are matched by "logout", for example.

EOF
	exit 2
esac

exit 0
