#! /bin/bash
set -e # Stop script on error

# This is configuration script of my Arch Linux installation package.
# Origiinally forked from krushndayshmookh.github.io/krushn-arch.

echo "Auto-Arch Post Install"

# Set date time
ln -sf /usr/share/zoneinfo/America/Detroit /etc/localtime
hwclock --systohc

# Set locale to en_US.UTF-8 UTF-8
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Set hostname
echo "MCRN-Donnager" >> /etc/hostname
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1 MCRN-Donnager.localdomain  MCRN-Donnager" >> /etc/hosts

## Generate initramfs (Not working currently, not sure why)
#mkinitcpio -P

# Set root password
passwd

# Install bootloader
mkdir /boot/grub/
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck

# Create new user (Group iput did not exist)
useradd -aG wheel,power,storage,audio,video,optical,uucp,network -s /bin/zsh wilson
sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
# add 'Defaults !tty_tickets' to not have to retype in your sudo password all of the times
echo "Set password for new user wilson"
passwd wilson

# enable display manager and other various services
# systemctl enable lightdm.service
systemctl enable NetworkManager
systemctl enable sshd.service
systemctl enable dhcpcd

# Install yay for AUR packages
su wilson

echo "From here you will have to go and run the final script"
