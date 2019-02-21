#!/bin/sh
set -eu

# Create partition
sgdisk -o /dev/sda
sgdisk --new "0::+512M" /dev/sda
sgdisk --new "0::0" /dev/sda

# Format and mount filesystem
mkfs.vfat -F32 /dev/sda1
mkfs.ext4 /dev/sda2
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot

# Select a mirror
cp /etc/pacman.d/mirrorlist /tmp/mirrorlist
grep "\.jp" /tmp/mirrorlist > /etc/pacman.d/mirrorlist

# Install base system
pacstrap /mnt base base-devel

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Create setup script
cat << _EOF_ >> /mnt/setup.sh
#!/bin/bash

# timezone
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
hwclock --systohc --utc

# locale
echo en_US.UTF-8 UTF-8 >> /etc/locale.gen
echo ja_JP.UTF-8 UTF-8 >> /etc/locale.gen
locale-gen
echo LANG=en_US.UTF-8 > /etc/locale.conf

# keymap
echo KEYMAP=jp106 > /etc/vconsole.conf

# Network
echo asterism-arch > /etc/hostname
echo "127.0.1.1 asterism-arch.localdomain asterism-arch"
systemctl enable dhcpcd.service

# Users
echo "password" | passwd --stdin root

# Select a mirror
cp /etc/pacman.d/mirrorlist /tmp/mirrorlist
grep "\.jp" /tmp/mirrorlist > /etc/pacman.d/mirrorlist

# packages
pacman -S git zsh grml-zsh-config 

# Settings


# Bootloader
bootctl --path=/boot install
echo "default arch" >> /boot/loader/loader.conf
echo "timeout 4" >> /boot/loader/loader.conf
echo "editor no" >> /boot/loader/loader.conf

_EOF_


# Run setup script
arch-chroot /mnt /mnt/setup.sh

# Finish
umount -R /mnt
reboot
