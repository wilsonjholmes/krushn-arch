#! /bin/bash

# This is configuration script of my Arch Linux installation package.
# Origiinally forked from krushndayshmookh.github.io/krushn-arch.


echo "Auto-Arch Post Install"

# Set date time
ln -sf /usr/share/zoneinfo/US/Michigan /etc/localtime
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
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch
grub-mkconfig -o /boot/grub/grub.cfg

# Create new user (Group iput did not exist)
useradd -m -G wheel,power,storage,uucp,network -s /usr/bin/zsh wilson
sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
echo "Set password for new user wilson"
passwd wilson

# Setup display manager
systemctl enable lightdm.service

# Enable services
systemctl enable NetworkManager.service

echo "Configuration done! Press any key to exit chroot."
read tmpvar
exit

# Finish
echo "This post-install script is now finished! Arch Linux is installed!"
echo "The only thing left is to reboot into the new system."
echo "Press any key to reboot or Ctrl+C to cancel..."
read tmpvar
reboot
