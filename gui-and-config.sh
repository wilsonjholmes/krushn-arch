#! /bin/bash
set -e # Stop script on error

HOSTNAME=$1

echo ${HOSTNAME}

# # Install other tools
# pacman -S zsh exa dosfstools neofetch sl figlet cowsay ranger htop pulseaudio tigervnc wpa_supplicant dialog os-prober xorg xorg-xinit xorg-xrandr openbox gnome-terminal firefox thunar nitrogen tint2 lxappearance

# # change user to 
# su ${HOSTNAME}

# cd /tmp
# git clone https://aur.archlinux.org/yay.git
# cd yay
# makepkg -si

# yay -S timeshift

# exit
# exit

# # unmount partitions tp prep for reboot
# umount -R /mnt

# # Finish
# echo "This post-install script is now finished! Arch Linux is installed!"
# echo "The only thing left is to reboot into the new system."
# echo "Press any key to reboot or Ctrl+C to cancel..."
# read tmpvar
# reboot
