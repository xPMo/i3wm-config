#!/usr/bin/env python3

# Just waits for a track change and notifies i3blocks

from gi.repository import Playerctl, GLib
import os

player = Playerctl.Player()
sh_called = "export DISPLAY=:0; pkill -RTMIN+11 i3blocks"
print(player)

def on_pause(player):
    os.system(sh_called)

def on_play(player):
    os.system(sh_called)

def on_meta(player, e):
    os.system(sh_called)

player.on('metadata', on_meta)
player.on('play', on_play)
player.on('pause', on_pause)
GLib.MainLoop().run()
