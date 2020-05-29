#! /bin/bash

# This is configuration script of my Arch Linux installation package.
# Origiinally forked from krushndayshmookh.github.io/krushn-arch.


echo "

                _                            _      
     /\        | |            /\            | |     
    /  \  _   _| |_ ___      /  \   _ __ ___| |__   
   / /\ \| | | | __/ _ \    / /\ \ | '__/ __| '_ \  
  / ____ \ |_| | || (_) |  / ____ \| | | (__| | | | 
 /_/    \_\__,_|\__\___/  /_/    \_\_|  \___|_| |_| 
                                                    
                                                    
  _____          _     _____           _        _ _ 
 |  __ \        | |   |_   _|         | |      | | |
 | |__) |__  ___| |_    | |  _ __  ___| |_ __ _| | |
 |  ___/ _ \/ __| __|   | | | '_ \/ __| __/ _` | | |
 | |  | (_) \__ \ |_   _| |_| | | \__ \ || (_| | | |
 |_|   \___/|___/\__| |_____|_| |_|___/\__\__,_|_|_|
                                                    
                                                    

"

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

# Generate initramfs
mkinitcpio -P

# Set root password
passwd

# Install bootloader
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch
grub-mkconfig -o /boot/grub/grub.cfg

# Create new user
useradd -m -G wheel,power,iput,storage,uucp,network -s /usr/bin/zsh wilson
sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers
echo "Set password for new user wilson"
passwd wilson

# Setup display manager
systemctl enable lightdm.service

# Enable services
systemctl enable NetworkManager.service

echo "Configuration done. You can now exit chroot."
