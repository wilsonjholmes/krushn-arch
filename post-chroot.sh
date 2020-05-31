#! /bin/bash
set -e # Stop script on error

# # chroot into installation
# arch-chroot /mnt bash ./post-chroot.sh
# # arch-chroot /mnt /bin/bash <<EOF
# #   bash ./post-chroot.sh
# # EOF

# Set date time
arch-chroot /mnt ln -sf /usr/share/zoneinfo/America/Detroit /etc/localtime

# Set hardware clock
arch-chroot /mnt hwclock --systohc

# Set locale to en_US.UTF-8 UTF-8
arch-chroot /mnt sed -i '/en_US.UTF-8 UTF-8/s/^#//g' /etc/locale.gen
# sed -i '/en_US ISO-8859-1/s/^#//g' /etc/locale.gen
arch-chroot /mnt locale-gen
arch-chroot /mnt echo "LANG=en_US.UTF-8" >> /etc/locale.conf

# Set hostname
read -p "Enter a hostname for the computer: " HOSTNAME
arch-chroot /mnt echo $HOSTNAME > /etc/hostname

# Set-up hosts file
arch-chroot /mnt echo "127.0.0.1 localhost" >> /etc/hosts
arch-chroot /mnt echo "::1 localhost" >> /etc/hosts
arch-chroot /mnt echo "127.0.1.1 ${HOSTNAME}.localdomain  ${HOSTNAME}" >> /etc/hosts

# Set root password
arch-chroot /mnt echo "Username: root"
arch-chroot /mnt passwd

# Setup bootloader
# read -p "Would you like to install grub[1] or systemd-boot[1]: " BOOTLOADER

# Install grub as bootloader
arch-chroot /mnt mkdir /boot/grub/
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=arch_grub --recheck

# # Create new sudo user
# read -p "Enter username: " USERNAME
# useradd -m -G wheel -s /bin/bash ${USERNAME}
# passwd ${USERNAME}
# sed --in-place 's/^#\s*\(%wheel\s\+ALL=(ALL)\s\+NOPASSWD:\s\+ALL\)/\1/' /etc/sudoers

# # add 'Defaults !tty_tickets' to not have to retype in your sudo password all of the times
# # also add Luke Smith thing so I can reboot without sudo

# # enable essential services
# systemctl enable NetworkManager
# systemctl enable sshd.service

# # Run the next script
# bash ./gui-and-config.sh ${HOSTNAME}
