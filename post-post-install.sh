#! /bin/bash
set -e # Stop script on error

cd /tmp
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si


echo "Configuration done! Press any key to exit chroot."
read tmpvar
exit
exit

# unmount partitions tp prep for reboot
umount -R /mnt

# Finish
echo "This post-install script is now finished! Arch Linux is installed!"
echo "The only thing left is to reboot into the new system."
echo "Press any key to reboot or Ctrl+C to cancel..."
read tmpvar
reboot
