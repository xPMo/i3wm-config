#!/usr/bin/env bash

# Examples:
#	 ix hello.txt			  # paste file (name/ext will be set).
#	 echo Hello world. | ix	# read from STDIN (won't set name/ext).
#	 ix -n 1 self_destruct.txt # paste will be deleted after one read.
#	 ix -i ID hello.txt		# replace ID, if you have permission.
#	 ix -d ID

notif() {
	dunstify --appname="ix.io" "$@"
}

ix() {
	local opts
	local OPTIND
	[ -f "$HOME/.netrc" ] && opts='-n'
	while getopts ":hd:i:n:" x; do
		case $x in
			h) echo "ix [-d ID] [-i ID] [-n N] [opts]"; return 1;;
			d) notif$(curl $opts -X DELETE ix.io/$OPTARG); exit 0;;
			i) opts="$opts -X PUT"; local id="$OPTARG";;
			n) opts="$opts -F read:1=$OPTARG";;
		esac
	done
	shift $((OPTIND - 1))
	[ -t 0 ] && {
		local filename="$1"
		shift
		[ "$filename" ] && {
			curl $opts -F f:1=@"$filename" $* ix.io/$id
			return
		}
		echo "^C to cancel, ^D to send."
	}
	curl $opts -F f:1='<-' $* ix.io/$id
}

if url=$(ix $*); then
	action=$(notif "Uploaded $url" \
		--action="echo ${url} | xsel -b,copy URL to clipboard" \
		--action="ix -d ${url##*/},delete paste" \
		--action="xdg-open ${url},open URL in browser"
	)
	[ -n ${action:-} ] && eval $action
else
	notif "Failed to upload"
	exit 1
fi
