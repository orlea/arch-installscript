#!/bin/sh
set -eu

# Create partition
sgdisk -o /dev/sda
sgdisk --new "0::+512M" /dev/sda
sgdisk --new "0::0" /dev/sda
sgdisk -t 1:ef00 /dev/sda
e2label /dev/sda2 arch_os

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
pacstrap /mnt base base-devel linux

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Create setup script
cat << EOF > /mnt/setup.sh
#!/bin/bash

# timezone
ln -sf /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
hwclock --systohc

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

# Select a mirror
cp /etc/pacman.d/mirrorlist /tmp/mirrorlist
grep "\.jp" /tmp/mirrorlist > /etc/pacman.d/mirrorlist

# packages
pacman -Syu
pacman -S zsh git noto-fonts noto-fonts-cjk noto-fonts-emoji --noconfirm

# Users
echo "root:rootPass" | chpasswd
useradd -m -g wheel -s /bin/zsh aries
echo "aries:generalPass" | chpasswd
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers
echo 'Defaults env_keep += "HOME"' >> /etc/sudoers


# Bootloader
bootctl --path=/boot install
echo "default  arch" >> /boot/loader/loader.conf
echo "timeout  4" >> /boot/loader/loader.conf
echo "editor   no" >> /boot/loader/loader.conf

echo "title   Arch Linux" >> /boot/loader/entries/arch.conf
echo "linux   /vmlinuz-linux" >> /boot/loader/entries/arch.conf
echo "initrd  /intel-ucode.img" >> /boot/loader/entries/arch.conf
echo "initrd  /initramfs-linux.img" >> /boot/loader/entries/arch.conf
echo "options root=LABEL=arch_os rw" >> /boot/loader/entries/arch.conf

EOF


# Run setup script
chmod +x /mnt/setup.sh
arch-chroot /mnt "/setup.sh"

# Finish
umount -R /mnt
reboot
