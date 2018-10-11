#!/usr/bin/env sh
set -eu

IFS="
"
dev=$(xinput list --name-only | grep Touchpad)
xinput list-props $dev | grep -q 'Device Enabled.*1$' &&
	exec xinput disable $dev || exec xinput enable $dev
