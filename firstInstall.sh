#!/bin/bash
# installDir is a string for the sake of unexpanded ~ in config files
installDir="~/.i3"
dirDest=~/.i3
dirSource=$PWD
echo $dirDest
if [ ! -d $dirDest ]; then
   mkdir $dirDest
fi
cp -r config.d $dirDest
cp -r scripts $dirDest
for file in $(find "$dirDest" -type f)
do
   sed -i "s@\$installDir@$(echo $installDir | sed 's@\.@\\.@g')@g" $file
done
if [ ! -f $dirDest/config ]
   touch $dirDest/config
fi
cat $dirDest/config.d/* > $dirDest/config
i3-msg reload
