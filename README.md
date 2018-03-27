# i3wm-config
My i3, i3blocks, and accompanying config files.  Make of it what you will. (Also, trying to learn
more about Github workflow.)  Run `sh init.sh` to add symlinks in `~/.config/` and `~/.local/bin/`.

Default bindings which have been changed:
* true vim-style `hjkl` movement instead of the `jkl;` movement that is default
* i3 reload/restart are now `$mod+F1` and `$mod+Shift+F1`
* i3 exit is `$mod+Shift+F2` (lock is `$mod+F2`)
* Scratchpad is `$mod+(Shift+)c`
* Focus child is `$mod+z`
* Only split toggle (on `$mod+n`), no splith/v bindings

i3wm features:
* No titlebars
* `$mod+x` for a focus/launch mode. (Press `<key>` to attempt to focus the associated program.  It will launch if it fails. Press `Shift+<key>` to launch a new instance, without regard to running instances.)
* `scrotlock` script which pixelizes and 50% desaturates
* `$mod+Return` focuses the terminal workspace and launches one if not already launched; if workspace was already focused, launches new terminal. `$mod+Shift+t` for new terminal anywhere
* `$mod+Tab` backandforth, let go of `$mod` to stay on the other workspace, or let go of `Tab` to return
* Certain programs will launch on certain workspaces
* Volume displayed in hexadecimal because why not
* Special bindings that I use with my Steam Controller
* Click events for most blocks
* Keyboard shortcuts to get notifications with system information
* Uses dunstify for `--replace`ing notifications
* Layout notification on layout change
* Uses `Xresources` to set gaps, colors, and (coming) more!

i3blocks scripts:
* CPU: right click to get `mpstat` notification
* Playerctl: click to playpause, right click for notification with album art and info
* Disks: click to open mount location, right click for `df` notification
* Temperature: right click for detailed temperature information
* Volume: scroll to change volume, right click to toggle mute


**TODO:**
* Set `S_COLORS` for mpstat colou?ri\[zs\]ation
* Branch with Barless config: workspace notification on workspace change, workspace Rofi
* Continue to customize click events for i3blocks
* Create sway-compatible bindings for upcoming Wayland migration
* Give up.

By default, bindings for:
* [playerctl](https://github.com/acrisci/playerctl)
* pactl/pacmd
* xfce4-launcher
* Thunar
* Libreoffice
* Blueman
* Clementine
* Steam
* Pavucontrol
* Tor
* File-roller
* Firefox
* dmenu
* (more)
