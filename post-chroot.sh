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

pacman -S plasma sddm kde-applications --noconfirm --needed
systemctl enable sddm


# Enable multilib repository

echo "------------------------"
echo "Enabling multilib repository"
echo "------------------------"

sed -i 's/#\[multilib\]/\[multilib\]/g' /etc/pacman.conf

pacman -Syu --noconfirm --needed

# Install AMD drivers
echo "------------------------"
echo "Installing AMD drivers"
echo "------------------------"

pacman -S xf86-video-amdgpu mesa vulkan-radeon libva-mesa-driver lib32-vulkan-radeon lib32-mesa --noconfirm --needed

# Install Microsoft fonts

echo "------------------------"
echo "Installing Microsoft fonts"
echo "------------------------"

yay -S ttf-ms-fonts --noconfirm --needed

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
echo "Installation complete, rebooting in 15 seconds"
echo "----------------------------------------------"

sleep 5

reboot