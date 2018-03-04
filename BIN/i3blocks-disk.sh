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

DIR="${BLOCK_INSTANCE:-$HOME}"
ALERT_LOW="${1:-10}" # color will turn red under this value (default: 10%)

case $BLOCK_BUTTON in
	#click, open file-manager on root
	1) thunar "$DIR" & ;;
	2) notify-send "Disk Usage: $DIR" "df -h $DIR" --icon harddisk --app-name df & ;;
esac

exec df -h -P -l "$DIR" | awk -v alert_low=$ALERT_LOW '
/\/.*/ {
	# full text (FS Size Used Avail Use% Mount
	print $3 "/" $2

	# short text
	print $4

	use=$5

	# no need to continue parsing
	exit 0
}

END {
	gsub(/%$/,"",use)
	if (100 - use < alert_low) {
		# color
		print "#dc322f"
	}
}
'
