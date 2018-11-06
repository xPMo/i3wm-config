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

i3wm features:
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
