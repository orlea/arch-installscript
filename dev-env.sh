#!/bin/sh
set -eu

# AUR helper
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

# utils
sudo pacman -S htop bluez bluez-utils gnome-bluetooth rclone gnome-boxes gimp ffmpeg neofetch --noconfirm

# browser
sudo pacman -S firefox chromium --noconfirm

# editor
sudo pacman -S nano code --noconfirm

# environment
sudo pacman -S docker docker-compose --noconfirm
