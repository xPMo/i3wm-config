# i3wm-config
My i3, i3blocks, and accompanying config files.  Make of it what you will. (Also, trying to learn
more about Github workflow.)  Run `sh init.sh` to add symlinks in `~/.config/` and `~/.local/bin/`.

Features include:
* true vim-style `hjkl` movement instead of the `jkl;` movement that is default
* No titlebars unless floating
* `$mod+x` for a focus/launch mode, using accompanying scripts
* `scrotlock` script which pixelizes and 50% desaturates
* `$mod+Return` focuses the terminal workspace and launches one if not already launched; if workspace was already focused, launches new terminal. `$mod+Shift+t` for new terminal anywhere
* `$mod+Tab` backandforth, let go of `$mod` to stay on the other workspace, or let go of `Tab` to return
* Certain programs will launch on certain workspaces
* Volume displayed in hexadecimal because why not
* Special bindings that I use with my Steam Controller
* Playerctl i3block which can `notify-send` track info with album art! (I'm kinda proud of this one right now.)

**TODO:**
* Figure out how to get colors from ~/.Xresources.
* Give up.

By default, bindings for:
* [playerctl](https://github.com/acrisci/playerctl)
* pactl/pacmd
* xfce4-launcher
* Thunar
* Icedove
* Libreoffice
* Blueman
* Clementine
* Steam
* Pavucontrol
* Tor
* File-roller
* Firefox
* dmenu
