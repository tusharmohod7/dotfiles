#!/bin/bash

timedatectl set-ntp true

yay -S nerd-fonts-mononoki
yay -S nerd-fonts-ubuntu-mono
yay -S betterlockscreen xcpvinfo bc
yay -S polybar pacman-contrib ttf-awesome siji-git pulseaudio alsa-utils


pacman -S alacritty neofetch ttf-ubuntu-font-family pulseaudio pulsemixer xorg-xbacklight i3blocks feh ttf-awesome
