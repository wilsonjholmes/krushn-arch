#! /bin/bash

# Set date time
ln -sf /usr/share/zoneinfo/America/Detroit /etc/localtime

# Set hardware clock
hwclock --systohc

# Set locale to en_US.UTF-8 UTF-8
sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
sed -i '/en_US ISO-8859-1/s/^#//g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Set hostname
read -p "Enter a hostname for the computer: " HOSTNAME
echo $HOSTNAME > /etc/hostname

# Set-up hosts file
echo "127.0.0.1 localhost" >> /etc/hosts
echo "::1 localhost" >> /etc/hosts
echo "127.0.1.1 ${HOSTNAME}.localdomain  ${HOSTNAME}" >> /etc/hosts

# Set root password
echo "Username: root"
passwd

# Setup bootloader
# read -p "Would you like to install grub[1] or systemd-boot[1]: " BOOTLOADER

# Install grub as bootloader
mkdir /boot/grub/
grub-mkconfig -o /boot/grub/grub.cfg
grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck

# Create new sudo user
read -p "Enter username: " USERNAME
useradd -m -G wheel -s ${USERNAME}
passwd ${USERNAME}
sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers

# add 'Defaults !tty_tickets' to not have to retype in your sudo password all of the times
# also add Luke Smith thing so I can reboot without sudo

# enable essential services
systemctl enable NetworkManager
systemctl enable sshd.service

# Run the next script
bash ./gui-and-config.sh HOSTNAME
