#!/usr/bin/env bash
shopt -s dotglob
set -e

#link-if-exists
function lie {
	[ -L "$1" ] || ln -s "$2" "$1"
}
function lie-dir {
	pushd "$1"
	for file in *; do
		lie "$2/$file" "$1/$file"
	done
	popd
}

lie-dir "$(pwd)/CONFIG" "$HOME/.config"
lie-dir "$(pwd)/BIN" "$HOME/.local/bin"
