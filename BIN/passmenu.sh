#!/usr/bin/env sh
# alternative to standard passmenu:
# * replaces dmenu with rofi
# * uses POSIX sh instead of bashisms
IFS='
	'
set -e

typeit=0
if [ $1 = "--type" ]; then
	typeit=1
	shift
fi

prefix=${PASSWORD_STORE_DIR:-~/.password-store}

password=$(
	find $prefix -iname '*.gpg' |
		sed -e "s:^${prefix}/::" -e "s/....$//" |
		rofi -dmenu -i "$@"
)

[ -n ${password:-} ] || exit

if [ $typeit -eq 0 ]; then
	pass show -c $password 2>/dev/null
else
	pass show $password | tr '\n' '\0' |
		xdotool type --clearmodifiers --file -
fi
