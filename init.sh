#!/usr/bin/env bash
ln -s $(pwd)/CONFIG/* -t $HOME/.config/
cd scripts
for file in *
do
	echo Symlinking $file
	ln -s $(pwd)/$file $HOME/.local/bin/${file%.*}
done
