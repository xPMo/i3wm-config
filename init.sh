#!/usr/bin/env bash
shopt -s dotglob
set -e

#link-if-exists
function lie {
	[ -L "$2" ] && return
	if [ -f "$2" ]; then
		echo "$2 exists and is not a symlink. Linking to $2.new"
		ln -s "$1" "$2.new"
	else
		ln -s "$1" "$2"
	fi
}
function lie-dir {
	pushd "$1"
	for file in *; do
		lie "$1/$file" "$2/$file"
	done
	popd
}

lie-dir "$(pwd)/CONFIG" "$HOME/.config"
lie-dir "$(pwd)/BIN" "$HOME/.local/bin"
