#!/usr/bin/env bash
shopt -s dotglob
set -e

#link-if-exists
function lie {
	# refer to the same file
	[[ $(realpath "$1") = $(realpath "$2") ]] && return
	diff "$1" "$2" -q 2>/dev/null && return

	if [ -e "$2" ]; then
		# path exists already
		echo "$2 exists and is not a symlink. Linking to $2.new"
		ln -s "$1" "$2.new"
	else
		# create link
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

function lie-dir-bin {
	pushd "$1"
	for file in *; do
		lie "$1/$file" "$2/${file%.*}"
	done
	popd
}

lie-dir "$(pwd)/CONFIG" "$HOME/.config"
lie-dir "$(pwd)/LIB" "$HOME/.local/lib"
lie-dir-bin "$(pwd)/BIN" "$HOME/.local/bin"
