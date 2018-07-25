# BIN: Associated Scripts:

### i3tool

A helper script to provide easy access to various functionality: 

* logind (loginctl or systemctl)
* i3lock
* run a program via i3-msg

Originally from Manjaro's i3 Community Edition, changed the lock script to my own and added `hybrid-sleep` support.

### i3focuslaunch

A script to focus a program's window.  If it fails, it will then launch the program.

### i3pklaunch

A script with nearly the same behaviour of `i3focuslaunch`.
It uses `pkill` to attempt to find the given program; otherwise it will launch it.
Lastly, it will attempt to focus using both class and title.

This is reimplemented for the sake of Swaywm, where swaymsg doesn't givce feedback on whether the window was successfully focused.

### i3hint

A script to provide context information to the user:  Most usefully, the current layout (splitv/splith/tabbed/stacked) and workspace.

Also has an option which I use to provide help for `$gaps_mode` in my i3 config.

### i3slopsize

Shamelessly stolen from Airblader, allows resizing a window via drawing a rectangle with slop.


### i3switchlaunch

This script is only used for the terminal workspace.  The approximate form is as follows:

```
if $workspace is focused:
    launch $program
else:
    focus workspace
    if $program is not focused:
        launch $program
```

### i3volumectl

Calling this script without any arguments toggles mute.  Otherwise, the argument is used to change the default sink's volume.


### imgur

This is a heavily modified fork of the well-known `imgur.sh` modified to make use of `dunstify` to control what actions to take on the urls.  I use this in conjunction with my `maim-dunst` script for full notification-based control.

It also has a `-e` option which prints out statements to be `eval`'d by bash for use in other scripts.

### ix-dunst

A fork of `ix` which uses `dunstify` actions for control.


### maim-dunst

A wrapper script for maim which uses `dunstify` to take actions on the resulting screenshot.  These actions are supported:

* Viewing the file via `$XIVIEWER` or `xdg-open`
* Editing the file with GIMP
* Uploading the file to Imgur
* Copying the screenshot to the clipboard with `xclip`
* Moving the screenshot to `$SCREENSHOT_DIR`
* Deleting the image

### passmenu

A fork of the default `passmenu` using Rofi instead of dmenu.


### popup-term

### sloprecord-dunst

A wrapper script for `ffmpeg` and `parecord` which uses `dunstify` to take actions on the recording.  It uses a lock in `$XDG_RUNTIME_DIR` to prevent multiple recordings at once.  Calling it a second time is the standard way of stopping the recording.

These actions are supported:

* Viewing the file with `$XVVIEWER` or `xdg-open`
* Editing the file with Kdenlive or Audacity
* Copying the recording to `$RECORD_DIR`
* Deleting the file
* Uploading the file to TODO

### toggletrackpad

An old script for toggling the trackpad using `synclient`.  I haven't looked at the documentation for `libinput` for porting it.
