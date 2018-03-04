#!/usr/bin/env sh
# Copyright (C) 2014 Julien Bonjean <julien@bonjean.info>

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

# POSIX doesn't allow this (yet)
#IFS=$'\n'
IFS="
" # but it does allow this

INTERFACE="${BLOCK_INSTANCE:-eth0}"

state="$(cat /sys/class/net/$INTERFACE/operstate)"

[ -z "$state" ] && exit 1

if [ "$state" = "down" ]; then
	printf -- '-\n-\n#dc322f'
else
	speed="$(cat /sys/class/net/$INTERFACE/speed 2> /dev/null)"

	id=$(nmcli -t -f name,device c show --active | grep $INTERFACE | cut -d ':' -f 1)
	realip="$(ip addr show $INTERFACE | perl -n -e'/inet (.+)\// && print $1')"
	ip="${realip:-<i>0.0.0.0</i>}"

	# full text
	[ -n "$id" ] && echo -n "<small>$id "
	echo -n "$ip</small>"
	[ -n "$speed" ] && echo " ($speed Mbits/s)" || echo

	# short text
	echo "<small>$ip</small>"
fi
case $BLOCK_BUTTON in
	#click for connection editor
	1) nm-connection-editor & ;;
	# right click for more information in a notification
	3) exec notify-send $realip "$(nmcli c | grep $INTERFACE | sed 's/\ \ /\n/g' | grep . )" \
		--app-name nmcli --icon network-transmit-receive ;;
esac
