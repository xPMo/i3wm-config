#!/bin/bash
set -euo pipefail
IFS=$'\n\t'

#
 #low battery in %
LOW_BATTERY="10"
 #critical battery in % (execute action)
CRITICAL_BATTERY="5"
 #sleep time 4 script
SLEEP="60"
 #acpi battery name
BAT="BAT0"
 #action
ACTION="/sbin/poweroff"
 #display icon
ICON="/usr/share/icons/Adwaita/48x48/devices/battery.png"
 #notify sound
# PLAY="aplay /usr/local/bin/bears01.wav"

MAX_BATTERY=$(cat /proc/acpi/battery/BAT0/info | grep 'last full' | awk '{print$4}')
LOW_BATTERY=$(($LOW_BATTERY*$MAX_BATTERY/100))
CRITICAL_BATTERY=$(($CRITICAL_BATTERY*$MAX_BATTERY/100))

while [ true ]; do
    if [ -e "/proc/acpi/battery/$BAT/state" ]; then
        PRESENT=$(grep "present:" /proc/acpi/battery/$BAT/state | awk '{print $2}')
        if [ "$PRESENT" = "yes" ]; then
            
            STATE=$(grep "charging state" /proc/acpi/battery/$BAT/state | awk '{print $3}')
            CAPACITY=$(grep "remaining capacity" /proc/acpi/battery/$BAT/state | awk '{print $3}')

            if [ "$CAPACITY" -lt "$LOW_BATTERY" ] && [ "$STATE" = "discharging" ]; then
                #$($PLAY)
                DISPLAY=:0.0 notify-send -u critical -t 5000 -i "$ICON" "Low battery." "remaining $CAPACITY mah, will auto-shutdown @ $CRITICAL_BATTERY"
            fi

            if [ "$CAPACITY" -lt "$CRITICAL_BATTERY" ] && [ "$STATE" = "discharging" ]; then
                $($ACTION)
            fi
        fi
    fi
    sleep $SLEEP
done
