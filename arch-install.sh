#!/usr/bin/env bash

# Set the keyboard layout
loadkeys trq

# Partition the disks
echo "Make sure you have created the partitions using cfidsk"
echo "If you have not created the partitions, press CTRL+C to exit"

# Learn the names of the partitions

echo "Enter the name of the EFI partition"
read EFI

echo "Enter the name of the SWAP partition"
read SWAP

echo "Enter the name of the ROOT partition"
read ROOT

# Get user input for username and password

echo "Enter the username"
read USERNAME

echo "Enter the password"
read PASSWORD



# Make the filesystems

echo  "Making the filesystems"

mkfs.fat -F32 -n "EFISYSTEM" "$EFI"
mkswap -L "SWAP" "$SWAP"
swapon "$SWAP"
mkfs.ext4 -L "ROOT" "$ROOT"

# Mount the filesystems

echo "Mounting the filesystems"

mount -t ext4 "$ROOT" /mnt

mkdir /mnt/boot

mount -t vfat "$EFI" /mnt/boot

# Install Arch Linux base on the system

echo "Installing Arch Linux base"

pacstrap /mnt base base-devel --noconfirm --needed

# Install kernel and firmware

echo "Installing kernel and firmware"

pacstrap /mnt linux linux-firmware networkmanager network-manager-applet amd-ucode nano git --noconfirm --needed

# Generate fstab

echo "Generating fstab"

genfstab -U /mnt >> /mnt/etc/fstab


# Bootloader installation

echo "Installing bootloader"

bootctl install --path /mnt/boot

# Bootloader configuration

echo "Configuring bootloader"

cat <<EOF > /mnt/boot/loader/loader.conf
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=${ROOT} rw
EOF




# Chroot installation script

cat <<REALEND > /mnt/root/afterinstall.sh

#!/usr/bin/env bash
useradd -m $USERNAME
usermod -aG wheel,storage,power,audio $USERNAME
echo $USERNAME:$PASSWORD | chpasswd
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

# Set the time zone

echo "Setting the time zone"

ln -sf /usr/share/zoneinfo/Turkey /etc/localtime

# Setting NTP time synchronization

echo "Setting NTP time synchronization"

systemctl enable systemd-timesyncd.service

# Setting the hardware clock

echo "Setting the hardware clock"

hwclock --systohc

# Setting the locale

echo "Setting the locale"

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Setting the keymap

echo "Setting the keymap"

echo "KEYMAP=trq" >> /etc/vconsole.conf

# Setting the hostname

echo "Setting the hostname"

echo "archlinux" >> /etc/hostname

cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain   archlinux
EOF

# Enable NetworkManager

echo "Enabling NetworkManager"

systemctl enable NetworkManager

# Install xorg and pipewire

echo "Installing xorg and pipewire"

pacman -S xorg pipewire pipewire-pulse pipewire-jack pipewire-alsa --noconfirm --needed

#Install KDE Plasma

echo "Installing KDE Plasma"

pacman -S plasma sddm kde-applications --noconfirm --needed
systemctl enable sddm

# Install yay

echo "Installing yay"

git clone https://aur.archlinux.org/yay.git /tmp/yay

cd /tmp/yay || exit

sudo -u $USERNAME makepkg -si --noconfirm

cd ~ || exit

rm -rf /tmp/yay

echo "yay installed, checking version"
yay --version

# Enable multilib repository


echo "Enabling multilib repository"

sed -i 's/#\[multilib\]/\[multilib\]/g' /etc/pacman.conf

pacman -Syu --noconfirm --needed

# Install AMD drivers

echo "Installing AMD drivers"

pacman -S xf86-video-amdgpu mesa vulkan-radeon libva-mesa-driver lib32-vulkan-radeon lib32-mesa --noconfirm --needed

# Install Microsoft fonts

echo "Installing Microsoft fonts"

yay -S ttf-ms-fonts --noconfirm --needed

# Install Steam

echo "Installing Steam"

pacman -S steam --noconfirm --needed

# Install Spotify

echo "Installing Spotify"

pacman -S spotify-launcher --noconfirm --needed

# Install VSCode

echo "Installing VSCode"

pacman -S visual-studio-code-bin --noconfirm --needed

# Install QbitTorrent

echo "Installing QbitTorrent"

pacman -S qbittorrent --noconfirm --needed

echo "----------------------------------------------"
echo "Installation complete, rebooting in 15 seconds"
echo "----------------------------------------------"

sleep 5

reboot

REALEND

chmod +x /mnt/root/afterinstall.sh

# Chroot into the system

echo "Chrooting into the system"

arch-chroot /mnt /root/afterinstall.sh

