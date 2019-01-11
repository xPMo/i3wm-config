# i3wm-config
My i3, i3blocks, and accompanying config files.
The work of one year of constant tweaking,
two years of occasional tweaking,
one month of merging stuff from Manjaro-i3-CE,
and one more year of occasional tweaking.
Run `sh init.sh` to add symlinks in `~/.config/` and `~/.local/bin/`.

Default bindings which have been changed:

i3 Action | Default Binding | My Binding
--- | --- | ---
Move between windows | `$mod+[jkl;]` | `$mod+[hjkl]` (as in Vi)
Resize windows | `jkl;` | `hjkl` (as in Vi)
Reload i3 configuration | `$mod+Shift+c` | `$mod+F2`
Restart i3 in-place | `$mod+Shift+r` | `$mod+Shift+F2`
Focus Child container | `$mod+d` (commented out because of dmenu) | `$mod+z` (to complement `$mod+a`)
Focus/move window to Scratchpad | `$mod+minus` `$mod+Shift+minus` | `$mod+c` `$mod+Shift+c`
Launch dmenu | `$mod+d` | `$mod+x,d` (`$mod+x` changes modes)
Launch terminal | `$mod+Return` | `$mod+Shift+t` **OR** `$mod+Return`\* (see below for more information)
Split horizontal/vertical | `$mod+h` `$mod+v` | *unset*
Split toggle | *unset* | `$mod+n`
Exit i3 with `i3-nagbar` | `$mod+Shift+e` | `$mod+Shift+F3`

**i3wm features:**
* No titlebars
* `$mod+x` for a focus/launch mode. (Press `<key>` to attempt to focus the associated program.  It will launch if it fails. Press `Shift+<key>` to launch a new instance, without regard to running instances.)
* Locking script which pixelizes and 50% desaturates
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

**i3blocks scripts:**
* CPU: right click to get `mpstat` notification
* Playerctl: click to playpause, right click for notification with album art and info
* Disks: click to open mount location, right click for `df` notification
* Temperature: right click for detailed temperature information
* Volume: scroll to change volume, right click to toggle mute

**Associated scripts:** *(See ./BIN/README.md)*

**i3tool library function**

This function is the work of many hours over many years scripting and merging functionality.
The intension is to create a single function which could be sourced into a sh/bash/zsh \[non\]interactive shell
which could be used to wrap nicely some commonly used tasks when controlling i3 or sway.

* It can automatically detect which session is being used by looking at running processes
(or you can provide it with `--session|-s i3`).
* It encapsulates jq filters to get the current workspace, layout, or i3 version.
* It provides functions to easily focus-or-launch programs
(choose class to focus through `--class`).
* It allows multiple operations to be done at once, seperated by a lone comma (,).
* It can choose screenshotting, selection, and locking utilities that can be used with the given session
(hard-coded fallback lists, tested with `command -v`)
* It provides a simple pixelating lock function
* It will find and use the correct login daemon's commands to suspend/hibernate/power off/reboot
(`systemctl` vs `zzz`/runit scripts). **TODO:** (I don't have a runit system.)

**TODO:**
* Set `S_COLORS` for mpstat colou?ri\[zs\]ation
* Branch with Barless config: workspace notification on workspace change, workspace Rofi
* Give up.

Programs I have `bindsym exec`s for:
<!--!sort -d-->
* Arandr
* Blueman
* catfish (an mlocate wrapper)
* Clementine
* Compton
* dmenu
* \$FILEMAN via xdg-open
* File-roller
* Firefox
* GIMP
* Libreoffice
* [light](https://github.com/haikarainen/light)
* [maim](https://github.com/naelstrof/maim)
* [Neovim-GTK](https://github.com/daa84/neovim-gtk)
* pactl/pacmd
* Pass (password-store), via passmenu (either the dmenu-based one or my rofi-based one)
* Pavucontrol
* [playerctl](https://github.com/acrisci/playerctl)
* Rofi
* Steam
* Thunderbird
* Torbrowser
* xfce4-launcher
* (possibly others)
