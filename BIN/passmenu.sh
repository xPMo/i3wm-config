#!/usr/bin/env sh
# alternative to standard passmenu:
# * replaces dmenu with rofi
# * uses POSIX sh instead of bashisms
IFS='
	'
set -e

typeit=0
action=show
while
	case $1 in
	"--type") typeit=1 ;;
	"--action"|"-a") action="$2" ;;
	esac
	[ $# -ne 0 ]
do shift; done

prefix=${PASSWORD_STORE_DIR:-~/.password-store}

password=$(
	find $prefix -iname '*.gpg' |
		sed -e "s:^${prefix}/::" -e "s/....$//" |
		rofi -p "pass $action" -dmenu -i "$@"
)

[ -n ${password:-} ] || exit

if [ $typeit -eq 0 ]; then
	pass $action -c $password 2>/dev/null
else
	pass $action $password | tr '\n' '\0' |
		xdotool type --clearmodifiers --file -
fi
