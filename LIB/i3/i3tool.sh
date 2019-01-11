#!/usr/bin/env sh

i3tool()(
# {{{ Hidden functions
if [ -n "${BASH_VERSION:-}" ]; then
	is_fn() {
		# shellcheck disable=2039
		[[ "$(type -t "$1")" = function ]]
	}
elif [ -n "${ZSH_VERSION:-}" ]; then
	is_fn() {
		# shellcheck disable=2039
		typeset -f "$1" >/dev/null
	}
else
	is_fn() {
		type "$1" | grep -Fq ' function'
	}
fi
_prog="i3tool"
unset session class

test_cmd() {
	for c in "$@"; do
		if command -v "${c%% *}" >/dev/null 2>&1; then
			echo "$c"
			return 0
		fi
	done
	return 1
}

with_flag() {
	flag="$1"
	help="$2"
	shift 2
	printf %s "$*"
	"$1" "$help" 2>&1 | grep -Fq -- "$flag" && printf ' %s\n' "$flag"
}
# }}}
# {{{ Utility functions
help_(){
	cat >&2 << EOF
$_prog [options] [subcommand [arg ... ]) [, [command [arg ...] ]] ...

Subcommands are separated by a lone comma (,)

Options:
	-h|--help               print this help
	-s|--session [i3|sway]  use this session
	-c|--class [CLASS]      use this WM_CLASS for (focus|switch)launch

Subcommands:
	help                            print this help
	get_loginctl                    runs \`cat /proc/1/comm\` to get whether systemctl or (?)
	get_session                     echos back i3 or sway, depending on which is detected
	get_scrot [SESSION]             prints an installed screenshotting  for SESSION
	get_lock [SESSION]              prints an installed locking program for SESSION
	msg [...]                       pass arguments to (i3-|sway)msg
	flaunch [prog [args ...]]       if a program exists, focus it, otherwise launch
	slaunch [ws] [prog [args ...]]  focus the workspace, launch program if workspace was
	                                already focused or the program was not running there
	exec [prog [args ...]]          alias to 'msg -- exec'
	sresize                         resize with mouse selection
	lock                            lock screen with a desaturated, pixelized screenshot
	poweroff|reboot                 do the associated loginctl action
	suspend|hibernate|hybridsleep   lock (as above) and do the loginctl action
EOF
}

msg_(){
	case "$session" in
		i3) i3-msg "$@";;
		sway) swaymsg "$@" ;;
		*) return 1 ;;
	esac
}
# }}}
# {{{ System info functions
get_loginctl_(){
	case "$(cat /proc/1/comm)" in
		systemd) echo systemctl ;;
		*) test_cmd zzz ;;
	esac
}

get_session_() {
	case "$DESKTOP_SESSION" in
		i3) echo i3; return ;;
		sway) echo sway; return ;;
	esac
	if pkill -0 '^sway$'; then
		echo sway; return
	elif pkill -0 '^i3$'; then
		echo i3; return
	else
		echo >&2 "Could not find i3 or sway."
		return 1
	fi
}

get_scrot_() {
	case "$session" in
		i3)   test_cmd maim scrot xfce4-screenshooter "import -window root" && return 0 ;;
		sway) test_cmd grim && return 0 ;;
		*)    echo >&2 "Invalid session: $session"; return 1 ;;
	esac
	echo >&2 "No screenshot program could be found."
	return 1
}

get_config_path_(){
	msg_ --moreversion | awk '/config/{print $4}'
}

get_lock_() {
	case "$session" in
	sway)
		l="$(test_cmd swaylock)"
		with_flag -m -h "$l"
		return 0 ;;
	i3)
		l="$(test_cmd i3lock)"
		with_flag -m -h "$l"
		return 0 ;;
	*) echo >&2 "Invalid argument: $session"; return 1 ;;
	esac
	echo >&2 "No locking program could be found."
	return 1
}
# }}}
# {{{ System action functions

exit_(){
	msg_ exit
}

reboot_(){
	reboot
}

poweroff_(){
	poweroff
}

suspend_(){
	lock_
	"${loginctl:-$(get_loginctl_)}" suspend
}

hybridsleep_(){
	lock_
	"${loginctl:-$(get_loginctl_)}" hybrid-sleep
}

hibernate_(){
	lock_
	"${loginctl:-$(get_loginctl_)}" hibernate
}
# }}}
# {{{ $session info functions
get_layout_() {
	msg_ -t get_tree | jq --raw-output \
	'recurse(.nodes[]) | select(.nodes[].focused==true).layout'
}

get_workspace_() {
	msg_ -t get_workspaces | jq --raw-output \
	'.[] | select(.focused==true).name'
}

get_version_() {
	msg_ -t get_version | jq --raw-output '(.human_readable)'
}
# }}}
# {{{ $session action functions
exec_(){
	msg_ -- exec "$@"
}

flaunch_(){
	class="${class:-"$1"}"
	con_id="$(msg_ -t get_tree | jq -f /dev/fd/3 3<<- EOF |
	.nodes[].nodes[].nodes[] | (.nodes + .floating_nodes)[] | recurse(.nodes[]) |
	select(.window_properties | type=="object") | select(
		(.window_properties.class | contains("$class"))
		or (.window_properties.instance | contains("$class"))
	).id
	EOF
	head -n1)"
	if [ -n "${con_id:-}" ]; then
		msg_ "[con_id=${con_id%% }]" focus
	else msg_ -- exec "$@"; fi
}

slaunch_(){
	class="${class:-"$1"}"
	if msg_ -t get_workspaces | grep -iq "\"$1\",\"visible\":t"; then
		msg_ workspace "$1"
		shift
		"$@"
	else
		msg_ workspace "$1"
		shift
		if ! [ "$(msg_ -t get_tree | jq -r 'recurse(.nodes[]) | select(.focused==true).window_properties.class|ascii_downcase')" = "$class" ]; then
			msg_ -- exec "$@"
		fi
	fi
}

lock_(){
	# shellcheck disable=2119
	scrot="$(get_scrot_)" || return 1
	# shellcheck disable=2119
	lock="$(get_lock_)" || return 1
	img="$(mktemp --suffix=.png)"
	trap '{ rm "$img"; return $?; }' INT
	eval "$scrot \"$img\""
	# convert inplace
	convert "$img" -scale 20x20% -modulate 100,50 -scale 500x500% "$img"
	eval "$lock -i \"$img\""
	rm "$img"
}

sresize_(){
	case "$session" in
		i3) eval "$(slop -q -b 4 -c 0.03,0.21,0.26,0.5 -t 0 -f \
			"i3-msg floating enable, move position %x %y, resize set %w %h")" ;;
		sway)
			# -f flag not supported (yet)
			slurp -w 4 -c '#dc322f' | {
				# shellcheck disable=2162
				IFS=', x' read x y w h
				swaymsg floating enable, move position "$x" "$y", resize set "$w" "$h"
			} ;;
		*) return 1 ;;
	esac
}
# }}}
# {{{ Main logic
unset flag
for a in "$@" ,; do
	# unset arguments on first iteration
	if [ -z "${flag:-}" ]; then
		set --
		flag=1
	fi
	case "$a" in
	,)
		# execute built action
		eval set -- "$(getopt -o hs:c: -l help,session:,class: -- "$@")"
		while
			case "$1" in
				-h|--help) help_; return ;;
				-c|--class) class="$2"; shift ;;
				-s|--session) session="$2"; shift ;;
				-v|--verbose) verbosity="$((verbosity + 1))" ;;
				--) shift; break ;;
				*) help_; return 1
			esac
			shift
		do :; done
		session="${session:-"$(get_session_)"}" || return 1
		action="$1"
		if shift 2>/dev/null && is_fn "${action}_"; then
			"${action}_" "$@"
		else
			help_
			return 1
		fi
		# unset arguments for next
		set -- ;;
	*)
		# rebuild arguments
		set -- "$@" "$a" ;;
	esac
done
# }}}
)
# vim: foldmethod=marker
