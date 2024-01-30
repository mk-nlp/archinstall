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

mkfs.vfat -F32 -n "EFISYSTEM" "${EFI}"
mkswap "${SWAP}"
swapon "${SWAP}"
mkfs.ext4 -L "ROOT" "${ROOT}"

# Mount the filesystems

echo "Mounting the filesystems"

mkdir /mnt

mount "${ROOT}" /mnt
mkdir /mnt/boot
mount "${EFI}" /mnt/boot/

# Install Arch Linux base on the system

echo "Installing Arch Linux base"

pacstrap /mnt base base-devel --noconfirm --needed

# Install kernel and firmware

echo "Installing kernel and firmware"

pacstrap /mnt linux linux-firmware networkmanager network-manager-applet amd-ucode nano git efibootmgr --noconfirm --needed

# Generate fstab

echo "Generating fstab"

genfstab -U /mnt >> /mnt/etc/fstab


# Bootloader installation

echo "Installing bootloader"

pacstrap /mnt grub --noconfirm --needed

# Bootloader configuration

echo "Configuring bootloader"

arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB

arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg


# Chroot installation script

cat <<REALEND > /mnt/afterinstall.sh

#!/usr/bin/env bash
useradd -m $USERNAME
usermod -aG wheel,storage,power,audio $USERNAME
echo $USERNAME:$PASSWORD | chpasswd
sed -i 's/# %wheel ALL=(ALL) ALL/%wheel ALL=(ALL) ALL/g' /etc/sudoers

# Set the time zone
echo "------------------------"
echo "Setting the time zone"
echo "------------------------"

ln -sf /usr/share/zoneinfo/Turkey /etc/localtime

# Setting NTP time synchronization
echo "------------------------"
echo "Setting NTP time synchronization"
echo "------------------------"


systemctl enable systemd-timesyncd.service

# Setting the hardware clock
echo "------------------------"
echo "Setting the hardware clock"
echo "------------------------"

hwclock --systohc

# Setting the locale
echo "------------------------"
echo "Setting the locale"
echo "------------------------"

sed -i 's/#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/g' /etc/locale.gen

locale-gen

echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Setting the keymap

echo "------------------------"
echo "Setting the keymap"
echo "------------------------"

echo "KEYMAP=trq" >> /etc/vconsole.conf

# Setting the hostname

echo "------------------------"
echo "Setting the hostname"
echo "------------------------"

echo "archlinux" >> /etc/hostname

cat <<EOF > /etc/hosts
127.0.0.1   localhost
::1         localhost
127.0.1.1   archlinux.localdomain   archlinux
EOF

# Enable NetworkManager
echo "------------------------"
echo "Enabling NetworkManager"
echo "------------------------"

systemctl enable NetworkManager

# Install xorg and pipewire
echo "------------------------"
echo "Installing xorg and pipewire"
echo "------------------------"

pacman -S xorg pipewire pipewire-pulse pipewire-jack pipewire-alsa --noconfirm --needed

#Install KDE Plasma
echo "------------------------"
echo "Installing KDE Plasma"
echo "------------------------"

pacman -S plasma sddm --noconfirm --needed
systemctl enable sddm


# Enable multilib repository

echo "------------------------"
echo "Enabling multilib repository"
echo "------------------------"

sed -i '/#\[multilib\]/,/#Include = \/etc\/pacman.d\/mirrorlist/ s/#//' /etc/pacman.conf

pacman -Syu --noconfirm --needed

# Install AMD drivers
echo "------------------------"
echo "Installing AMD drivers"
echo "------------------------"

pacman -S xf86-video-amdgpu mesa vulkan-radeon libva-mesa-driver lib32-vulkan-radeon lib32-mesa --noconfirm --needed

# Install Steam
echo "------------------------"
echo "Installing Steam"
echo "------------------------"

pacman -S steam --noconfirm --needed

# Install Spotify
echo "------------------------"
echo "Installing Spotify"
echo "------------------------"

pacman -S spotify-launcher --noconfirm --needed

# Install VSCode
echo "------------------------"
echo "Installing VSCode"
echo "------------------------"

pacman -S visual-studio-code-bin --noconfirm --needed

# Install QbitTorrent
echo "------------------------"
echo "Installing QbitTorrent"
echo "------------------------"

pacman -S qbittorrent --noconfirm --needed

echo "----------------------------------------------"
echo "Installation complete, you can reboot now"
echo "----------------------------------------------"

exit

REALEND

chmod +x /mnt/afterinstall.sh

# Chroot into the system

echo "Chrooting into the system"

arch-chroot /mnt sh afterinstall.sh

