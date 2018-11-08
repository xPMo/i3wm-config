#!/usr/bin/env sh
IFS="
	"
set -e

a=$(echo $1 | tr '[A-Z]' '[a-z]')
case $a in
player|media)
	#TODO
	playerctl metadata --format \
'{{status}}
{{mpris:artUrl}}
{{artist}}</b> by<b>{{title}}
on <b>{{album}}</b> {{year}}
{{duration(position)}} of {{duration(length)}} | Play count: {{xesam:useCount}}
<small>{{xesam:url}}
{{xesam:comment}}</small>' | {
	read status
	read icon
	read summary
	body=$(cat)
}
	id=-200
	[ $status = Paused ] && hint='string:fgcolor:#eee785'
	app="playerctl"
	;;
sensors)
	summary="Sensors"
	body="$(sensors | grep '(')"
	icon=psensor
	id=-201
	hint=int:0:0
	app=sensors
	;;
disk)
	summary='Disk Usage:'
	body="$(grc --colour=on df -h -T -x tmpfs -x overlay -x devtmpfs |
		ansifilter -M -f --map $HOME/.local/lib/ansifilter/solarized)"
	icon=harddrive
	app=df
	hint=int:0:0
	id=-202
	;;
cpu)
	summary="CPU Usage:"
	body="$(mpstat -P ALL | tail -n +3 | cut -c 14-48 )"
	icon=indicator-cpufreq
	app=mpstat
	hint=int:0:0
	id=-203
	;;
ip)
	summary="IP"
	body="$(grc --colour=on ip route | sed 's/^\(.*\)dev \([^ ]*\)/\2: \1/g' |
		ansifilter -M -f --map $HOME/.local/lib/ansifilter/solarized)"
	icon=network-transmit-receive
	app=Address
	hint=int:0:0
	id=-204
	;;
time|date)
	summary="<big>$(date +%T)</big>"
	body=$(date "+%A %Y-%m-%d%n(%Z | %z)" )
	icon=clock
	hint=int:0:0
	id=-204
	app=date
	;;
* )
	cat >&2 <<- EOF
	Usage: $(basename $0) [ action ]

	Actions:

	This program matches the action on just the first few characters
	(unless using an abbreviation). So be aware that both "log" and
	"logarithms" are matched by "logout", for example.

	EOF
	exit 2
esac

# dunstify and notify-send use slightly different flags
if command -v dunstify > /dev/null; then
	dunstify "$summary" "$body" --appname="$app" --icon="$icon" \
		--replace="$id" --hints="$hint"
else
	notify-send "$summary" "$body" --app-name="$app" --icon="$icon" \
		--hint="$hint" --urgency=low
fi


exit 0

