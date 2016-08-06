#!/bin/bash
escapedDest="~/\.i3"
dirDest=~/.i3

dirSource=$PWD

echo $dirDest
if [ ! -d $dirDest ]; then
   mkdir $dirDest
fi
cp -r config.d $dirDest
cp -r scripts $dirDest

# Set install directory for config updating and scripts
for file in $(find "$dirDest" -type f)
do
   sed -i "s@\$installDir@$escapedDest@g" $file
done

# Automatically set primary monitor and secondary monitor, if connected
sed -i "s/\$MONITOR/$(xrandr | egrep .+primary | egrep -o "^(\w|-|_)+")/" $dirDest/config.d/2-binds
sed -i "s/\$MONITOR/$(xrandr | grep \ connected\ [^p] | egrep -o "^(\w|-|_)+")/" $dirDest/config.d/2-binds
if [ ! -f $dirDest/config ]; then
   touch $dirDest/config
fi

# Initial load
cat $dirDest/config.d/* > $dirDest/config
i3-msg reload
