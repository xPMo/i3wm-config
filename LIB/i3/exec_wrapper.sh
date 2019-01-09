#!/usr/bin/env sh
"$@"
status="$?"
case "$status" in
	0) exit ;;
	127) msg="Command not found: $*" ;;
	*) msg="Status $status: $*" ;;
esac
notify-send "$1 failed with status $status" "$msg"
echo  "$*: $msg" >> "$HOME/.xsession-errors"
