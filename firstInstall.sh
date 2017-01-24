#!/bin/bash
escapedDest="~/\.i3"
dirDest=~/.i3
escapedStatusDest="~/.config/i3status"
statusDirDest=~/.config/i3status
dirSource=$PWD

echo $dirDest
if [ ! -d $dirDest ]; then
   mkdir $dirDest
fi
cp -r conf.d $dirDest
cp -r scripts $dirDest
cp -r i3status $statusDirDest

# Automatically set primary monitor and secondary monitor, if connected

sed -i "s/\$BROWSERCLASS/$browserClass/" $dirDest/conf.d/2-binds
sed -i "s/\$MAILCLASS/$mailClass/" $dirDest/conf.d/2-binds
sed -i "s/\$TERMCLASS/$termClass/" $dirDest/conf.d/2-binds
sed -i "s/\$BROWSER/$browser/" $dirDest/conf.d/2-binds
sed -i "s/\$TERM/$terminal/" $dirDest/conf.d/2-binds
sed -i "s/\$MAIL/$mail/" $dirDest/conf.d/2-binds

if [ ! -f $dirDest/config ]; then
   touch $dirDest/config
fi

# Initial load
cat $dirDest/conf.d/* > $dirDest/config
i3-msg reload
