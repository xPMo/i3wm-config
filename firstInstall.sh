#!/bin/bash
escapedDest="~/\.i3"
dirDest=~/.i3
escapedStatusDest="~/.config/i3status"
statusDirDest=~/.config/i3status
dirSource=$PWD

browser="firefox"
terminal="xfce4-terminal"
mail="icedove"
# Some subtring for WM_CLASS lookup
browserClass="irefox"
termClass="erm"
mailClass="Icedove"

echo $dirDest
if [ ! -d $dirDest ]; then
   mkdir $dirDest
fi
cp -r config.d $dirDest
cp -r scripts $dirDest
cp -r i3status $statusDirDest

# Set install directory for config updating and scripts
for file in $(find "$dirDest" -type f)
do
   sed -i "s@\$installDir@$escapedDest@g" $file
   sed -i "s@\$statusDir@$escapedStatusDest@g" $file
done

# Automatically set primary monitor and secondary monitor, if connected
sed -i 0,/\$MONITOR/{s/\$MONITOR/$(xrandr | egrep .+primary | egrep -o '^(\w|-|_)+')/} $dirDest/config.d/2-binds

sed -i 0,/\$MONITOR/{s/\$MONITOR/$(xrandr | grep \ connected\ [^p] | egrep -o "^(\w|-|_)+")/} $dirDest/config.d/2-binds

sed -i "s/\$BROWSERCLASS/$browserClass/" $dirDest/config.d/2-binds
sed -i "s/\$MAILCLASS/$mailClass/" $dirDest/config.d/2-binds
sed -i "s/\$TERMCLASS/$termClass/" $dirDest/config.d/2-binds
sed -i "s/\$BROWSER/$browser/" $dirDest/config.d/2-binds
sed -i "s/\$TERM/$terminal/" $dirDest/config.d/2-binds
sed -i "s/\$MAIL/$mail/" $dirDest/config.d/2-binds

if [ ! -f $dirDest/config ]; then
   touch $dirDest/config
fi

# Initial load
cat $dirDest/config.d/* > $dirDest/config
i3-msg reload
