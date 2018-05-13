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
	lock) lock ;;
	logout) i3-msg exit ;;
	switch_user) dm-tool switch-to-greeter ;;
	suspend) lock && $logind suspend ;;
	hybrid-sleep) lock && $logind hybrid-sleep ;;
	hibernate) lock && $logind hibernate ;;
	reboot) $logind reboot ;;
	shutdown) $logind poweroff ;;
	run)
		shift
		[ -z ${XDG_SESSION_ID:-} ] && XDG_RUNTIME_DIR="/run/user/$(id -u)"
		i3sock=$(find ${XDG_RUNTIME_DIR}/i3 -type s)
		exec i3-msg -s $i3sock "exec '$@'"
		;;
	*)
		cat >&2 <<- EOF

== ! i3tool: missing or invalid argument ! ==
Supported arguments:
lock | logout | switch_user | suspend | hibernate | hybrid-sleep | reboot | shutdown
EOF

		exit 2
esac

exit 0
