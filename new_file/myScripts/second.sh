#!/bin/bash

mkdir .myGitRepos
cd .myGitRepos

git clone https://github.com/tusharmohod7/dotfiles.git

mkdir -p ~/.config/alacritty
cp ~/.myGitRepos/dotfiles/alacritty/alacritty.yml ~/.config/alacritty/alacritty.yml

mkdir -p ~/.config/i3blocks
mkdir -p ~/.config/i3blocks/scripts
cp /etc/i3blocks.conf ~/.config/i3blocks/config

mkdir -p ~/.config/picom
cp /etc/xdg/picom.conf ~/.config/picom/picom.conf


# just in case an error appears for betterlockscreen
rm -rf ~/.cache/i3lock
betterlockscreen -u ~/Pictures/ant.jpg
