# BIN: Associated Scripts:

## i3tool

Simply sources and runs the `i3tool` library function from `../LIB`

## i3hint

A script to provide context information to the user:  Most usefully, the current layout (splitv/splith/tabbed/stacked) and workspace.

Also has an option which I use to provide help for `$gaps_mode` in my i3 config.

## i3volumectl

Calling this script without any arguments toggles mute.  Otherwise, the argument is used to change the default sink's volume.


## imgur

This is a heavily modified fork of the well-known `imgur.sh` modified to make use of `dunstify` to control what actions to take on the urls.  I use this in conjunction with my `maim-dunst` script for full notification-based control.

It also has a `-e` option which prints out statements to be `eval`'d by bash for use in other scripts.

## ix-dunst

A fork of `ix` which uses `dunstify` actions for control.


## maim-dunst

A wrapper script for maim which uses `dunstify` to take actions on the resulting screenshot.  These actions are supported:

* Viewing the file via `$XIVIEWER` or `xdg-open`
* Editing the file with GIMP
* Uploading the file to Imgur
* Copying the screenshot to the clipboard with `xclip`
* Moving the screenshot to `$SCREENSHOT_DIR`
* Deleting the image

## passmenu

A fork of the default `passmenu` using Rofi instead of dmenu.


## popup-term

Launches an instance of `urxvtc` with certain flags/vars set for dropdown use.

## sloprecord-dunst

A wrapper script for `ffmpeg` and `parecord` which uses `dunstify` to take actions on the recording.  It uses a lock in `$XDG_RUNTIME_DIR` to prevent multiple recordings at once.  Calling it a second time is the standard way of stopping the recording.

These actions are supported:

* Viewing the file with `$XVVIEWER` or `xdg-open`
* Editing the file with Kdenlive or Audacity
* Copying the recording to `$RECORD_DIR`
* Deleting the file
* Uploading the file to TODO

## screenlayout-dunstify

A simple script for interactively choosing saved ARandR/xrandr scripts from ~/.screenlayout

## sys-notif

Notify the user about various system information:

* Media playing via `playerctl`
* Temperature/power via `sensors`
* Disk usage via `df`
* CPU usage via `mpstat`
* IP address via `ip`
* Current time via `date`

Requires grc and ansifilter to colou?rize the output.

## toggletrackpad

A script for toggling the touchpad. Requires using `xinput`+`libinput`.
