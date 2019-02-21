#!/bin/sh
set -eu

# Create partition
sgdisk -o /dev/sda
sgdisk --new "0::+512M" /dev/sda
sgdisk --new "0::0" /dev/sda
sgdisk -t 1:ef00 /dev/sda

# Format and mount filesystem
mkfs.fat -F32 /dev/sda1
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
cat << EOF > /mnt/setup.sh
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
echo "127.0.1.1 asterism-arch.localdomain asterism-arch" > /etc/hosts
systemctl enable dhcpcd.service

# Users
echo "password" | passwd --stdin root

# Select a mirror
cp /etc/pacman.d/mirrorlist /tmp/mirrorlist
grep "\.jp" /tmp/mirrorlist > /etc/pacman.d/mirrorlist

# packages
pacman -Syu
pacman -S grub efibootmgr

# Settings


# Bootloader
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=grub
grub-mkconfig -o /boot/grub/grub.cfg

EOF


# Run setup script
chmod +x /mnt/setup.sh
arch-chroot /mnt /mnt/setup.sh

# Finish
umount -R /mnt
reboot
