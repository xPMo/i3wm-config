#!/usr/bin/env sh
d="$(dirname $0)"
"$d/_time_loop" &
while read button; do
	case "$button" in
		3) sys-notif date;;
	esac
done
