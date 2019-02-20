#!/bin/sh
set -eu

# Create partition
sgdisk --clear /dev/sda
sgdisk --new "0::+512M" /dev/sda
sgdisk --new /dev/sda

# Format and mount filesystem


# Select a mirror
cp /etc/pacman.d/mirrorlist /tmp/mirrorlist
grep "\.jp" /tmp/mirrorlist > /etc/pacman.d/mirrorlist

# Install base system


# Generate fstab


# locale


# keymap


# time


# packages


# Bootloader



