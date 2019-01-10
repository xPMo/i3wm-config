#!/usr/bin/env sh

i3tool()(
	# {{{ Utility/hidden functions
	# if $SHELL supports it, unset all functions
	if [ -n "${BASH_VERSION:-}" ]; then
		_is_fn_() {
			# shellcheck disable=2039
			[[ "$(type -t "$1")" = function ]]
		}
	elif [ -n "${ZSH_VERSION:-}" ]; then
		_is_fn_() {
			# shellcheck disable=2039
			typeset -f "$1" >/dev/null
		}
	else
		_is_fn_() {
			type "$1" | grep -Fq ' function'
		}
	fi
	_prog="i3tool"
	unset session class

	_test_cmd_() {
		for c in "$@"; do
			if command -v "${c%% *}" >/dev/null 2>&1; then
				echo "$c"
				return 0
			fi
		done
		return 1
	}

	help_(){
		cat >&2 << EOF
$_prog [ options ] [ command ] ([ argument ... ])

Options:
	-h|--help               print this help
	-s|--session [i3|sway]  use this session
	-c|--class [CLASS]      use this WM_CLASS for (focus|switch)launch

Subcommands:
	help                            print this help
	get_logind                      simply runs \`cat /proc/1/comm\`
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
	poweroff|reboot                 do the associated logind action
	suspend|hibernate|hybridsleep   lock (as above) and do the logind action
	_*                              (utility functions, can be called if desired)
EOF
	}
	# }}}
	# {{{ System functions
	get_logind_(){
		cat /proc/1/comm
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
			i3)   _test_cmd_ maim scrot xfce4-screenshooter "import -window root" && return 0 ;;
			sway) _test_cmd_ grim && return 0 ;;
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
			_test_cmd_ swaylock && return 0 ;;
		i3)
			_test_cmd_ i3lock && return 0 ;;
		*) echo >&2 "Invalid argument: $session"; return 1 ;;
		esac
		echo >&2 "No locking program could be found."
		return 1
	}

	msg_(){
		case "$session" in
			i3) i3-msg "$@";;
			sway) swaymsg "$@" ;;
			*) return 1 ;;
		esac
	}

	exit_(){
		msg_ exit
	}

	reboot_(){
		"${logind:-$(get_logind_)}" reboot
	}

	poweroff_(){
		"${logind:-$(get_logind_)}" poweroff
	}

	suspend_(){
		lock_
		"${logind:-$(get_logind_)}" suspend
	}

	hybridsleep_(){
		lock_
		"${logind:-$(get_logind_)}" hybrid-sleep
	}

	hibernate_(){
		lock_
		"${logind:-$(get_logind_)}" hibernate
	}
	# }}}
	# {{{ i3/sway functions
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
		set +x
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
		trap '{ rm "$img"; exit $?; }' INT
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
	# {{{ Get opts
	eval set -- "$(getopt -o hs:c: -l help,session:,class: -- "$@")"
	while
		case "$1" in
			-h|--help) help; exit 0 ;;
			-c|--class) class="$2"; shift ;;
			-s|--session) session="$2"; shift ;;
			-v|--verbose) verbosity="$((verbosity + 1))" ;;
			--) shift; break ;;
			*) help; exit 1
		esac
		shift
	do :; done
	session="${session:-"$(get_session_)"}" || return 1
	# }}}
	action="$1"
	shift
	if _is_fn_ "${action}_"; then
		"${action}_" "$@"
	else
		help_
		return 1
	fi
)
# vim: foldmethod=marker
