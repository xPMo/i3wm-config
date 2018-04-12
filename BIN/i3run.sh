#!/usr/bin/env sh
[ -z ${XDG_SESSION_ID:-} ] && XDG_RUNTIME_DIR="/run/user/$(id -u)"
i3sock=$(find ${XDG_RUNTIME_DIR}/i3 -type s)
exec i3-msg -s $i3sock "exec '$@'"
