#!/usr/bin/env bash
IFS=$'\n'
set -e

function toclip {
	board="$board"$'\n'"$*"
	if command -v xsel >/dev/null 2>&1; then
		echo -e "$board" | xsel -b
	elif command -v xclip >/dev/null 2>&1; then
		echo -e "$board" | xclip -selection clipboard
	else
		echo "$@" >> "$HOME/.clip"
	fi
}

function getclip { echo "$board"; }

function usage_imgur {
	cat >&2 << EOF
Imgur usage:
\$1: filename to upload
\$IMGUR_CLIENT_ID: IMGUR_CLIENT_ID to use

Will unset IMGUR_{ERROR,URL,DELETE} imgur_upload

Either returns nonzero and sets:
    IMGUR_ERROR=<errmsg>
Or returns zero and sets:
    IMGUR_URL=<url>
    IMGUR_DELETE=<url>
EOF
}

function usage {
	cat >&2 << EOF
Usage: $(basename "$0") -h | -H | [ -d ] IMAGE

Upload IMAGE to Imgur

	-e    Print out statements to be \`eval\`d,
	      putting urls in \$imgur_urls and \$imgur_delete
	      and errors in \$imgur_errors.
	      Only works where Bash-style arrays are supported
	-d    Use dunstify to control the process
	-h    Show this help
	-H    Show help about the imgur shell function
	      (for use in your own scripts)
EOF
}

function imgur {
	unset IMGUR_ERROR IMGUR_URL IMGUR_DELETE
	unset -f imgur_upload
	# Function to output usage instructions

	# API in IMGUR_CLIENT_ID env variable
	# > fallback to $XDG_DATA_HOME/imgur/client.id
	# > fallback to ~/.local/share/imgur/client.id
	# > fallback to ~/.imgur/client.id
	# > fallback to ~/.imgur
	if [[ -z "${IMGUR_CLIENT_ID:-}" ]]; then
		if [[ -f "${XDG_DATA_DIR:-$HOME/.local/share}/imgur/client.id" ]]; then
			read -r IMGUR_CLIENT_ID < "${XDG_DATA_DIR:-$HOME/.local/share}/imgur/client.id"
		elif [[ -f "$HOME/.imgur/client.id" ]]; then
			read -r IMGUR_CLIENT_ID < "$HOME/.imgur/client.id"
		elif [[ -f "$HOME/.imgur" ]]; then
			read -r IMGUR_CLIENT_ID < "$HOME/.imgur"
		else
			IMGUR_ERROR="No client ID found."
			return 1
		fi
	fi

	# Function to upload a path
	# First argument should be a content spec understood by curl's -F option
	function imgur_upload {
		curl -H "Authorization: Client-ID $IMGUR_CLIENT_ID" -H "Expect: " -F "image=$1" https://api.imgur.com/3/image.xml
		# The "Expect: " header is to get around a problem when using this through
		# the Squid proxy. Not sure if it's a Squid bug or what.
	}

	# Check arguments

	# Check curl is available
	if ! command -v curl >/dev/null 2>&1; then
		IMGUR_ERROR="Could not find curl, which is required."
		return 17
	fi

	local file="$1"

	# Upload the image
	if [[ "$file" =~ ^https?:// ]]; then
		# URL -> imgur
		response=$(imgur_upload "$file") 2>/dev/null
	else
		# File -> imgur
		# Check file exists
		if [ "$file" != "-" ] && [ ! -f "$file" ]; then
			IMGUR_ERROR="File does not exist"
			return 1
		fi
		response=$(imgur_upload "@$file") 2>/dev/null
	fi

	if echo "$response" | grep -q 'success="0"'; then
		msg="${response##*<error>}"
		IMGUR_ERROR="Imgur error:${msg%%</error>*}"
		return 1
	fi

	local url
	local delete_hash
	# Parse the response and output our stuff
	url="${response##*<link>}"
	url="${url%%</link>*}"
	delete_hash="${response##*<deletehash>}"
	delete_hash="${delete_hash%%</deletehash>*}"
	IMGUR_URL="${url/^http:/https:}"
	IMGUR_DELETE="https://imgur.com/delete/$delete_hash"
}

function imgur-notif {
	while (( $# )); do
		if imgur "$1"; then
			action=$(
				dunstify --appname="$(basename "$0")" \
				"Image uploaded" "$IMGUR_URL" \
				--timeout=0 \
				--action="Vd,View on Imgur, copy delete URL to clipboard" \
				--action="vd,Copy both URLs to clipboard" \
				--action="D,Open delete URL on Imgur" \
				--action="vVdD,Copy and open both URLs" \
				--action="VD,Open both URLs on Imgur"
			)
			[[ $action == *v* ]] && toclip "View: $IMGUR_URL"
			[[ $action == *V* ]] && xdg-open "$IMGUR_URL"
			[[ $action == *d* ]] && toclip "Delete: $IMGUR_DELETE"
			[[ $action == *D* ]] && xdg-open "$IMGUR_DELETE"
			[[ $action == [12] ]] && break
		else
			notify-send "Upload failed." "$IMGUR_ERROR"
		fi
		shift
	done
	exit 0
}

function imgur-cli {
	while (( $# )); do
		if imgur "$1"; then
			echo "Uploaded $1. Open URLs? (y/N)" >&2
			read y
			if [[ "$y" == [yY]* ]]; then
				xdg-open "$IMGUR_URL"
				xdg-open "$IMGUR_DELETE"
			else
				toclip "View: $IMGUR_URL"$'\n'"Delete: $IMGUR_DELETE"
				echo "Copied to clipboard" >&2
			fi
		else
			echo "$IMGUR_ERROR" >&2
		fi
		shift
	done
}

function imgur-eval {
	echo 'unset imgur_urls imgur_delete imgur_errors'
	echo 'declare -a imgur_urls imgur_delete imgur_errors'
	function f { # run in parallel
		if imgur "$1"; then
			echo "imgur_urls+=( '$IMGUR_URL' )"
			echo "imgur_delete+=( '$IMGUR_DELETE' )"
		else
			echo "imgur_errors+=( '$IMGUR_ERROR' )"
		fi
	}
	while (( $# )); do
		f "$1" &
		shift
	done
	exit 0
}

getopts ":edhH" opt || imgur-cli "$@"
case $opt in
	d) shift; imgur-notif "$@" ;;
	e) shift; imgur-eval "$@" ;;
	h) usage ;;
	H) usage_imgur ;;
esac
