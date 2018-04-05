#!/usr/bin/env sh

# with openrc use loginctl
[ $(cat /proc/1/comm) = "systemd" ] && logind=systemctl || logind=loginctl

case "$1" in
	lock) scrotlock ;;
	logout) i3-msg exit ;;
	switch_user) dm-tool switch-to-greeter ;;
	suspend) scrotlock && $logind suspend ;;
	hybrid-sleep) scrotlock && $logind hybrid-sleep ;;
	hibernate) scrotlock && $logind hibernate ;;
	reboot) $logind reboot ;;
	shutdown) $logind poweroff ;;
	*)
		cat >&2 <<- EOF

== ! i3exit: missing or invalid argument ! ==
Supported arguments:
lock | logout | switch_user | suspend | hibernate | hybrid-sleep | reboot | shutdown
EOF

		exit 2
esac

exit 0
