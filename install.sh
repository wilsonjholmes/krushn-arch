#! /bin/bash

# This is my Arch Linux Installation Script.
# Forked from krushndayshmookh.github.io/krushn-arch.

echo "Wilson's Auto-Arch Installation Script!"

echo "Set up network connection, This script will fail otherwise."

# Filesystem mount warning
echo "This script will create and format the partitions as follows:"
echo "/dev/sda1 - 512Mb will be mounted as /boot/efi"
echo "/dev/sda2 - rest of space will be mounted as /"
read -p 'Continue? [y/N]: ' fsok
if ! [ $fsok = 'y' ] && ! [ $fsok = 'Y' ]
then 
    echo "Edit the script to continue..."
    exit
fi

# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TGTDEV}
  g # clear the in memory partition table, and make a new gpt one
  n # new partition
  1 # partition number 1
    # default - start at beginning of disk 
  +512M # 512MB boot parttion
  t # type of partition
  1 # partition type 1 'efi'
  n # new partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  t # type of partition
  2 # partition number 2
  24 # partition type 24 'Linux root (x86-64)'
  p # print the in-memory partition table
  w # write the partition table
EOF

# Format the partitions
mkfs.ext4 /dev/sda2
mkfs.fat -F32 /dev/sda1

# Set up time
timedatectl set-ntp true

# Initate pacman keyring
pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys

# Mount the partitions
mount /dev/sda2 /mnt
mkdir -pv /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi

# Get the fastest in-sync (up-to-date) mirrors and store them in mirrorlist

# Install Arch Linux
echo "Starting install.."
echo "Installing Arch Linux, OpenBox with Gnome Terminal and Thunar and GRUB2 as bootloader" 
pacstrap /mnt base base-devel zsh grml-zsh-config grub os-prober intel-ucode efibootmgr dosfstools freetype2 fuse2 mtools iw wpa_supplicant dialog xorg xorg-server xorg-xinit mesa xf86-video-intel openbox gnome-terminal firefox thunar

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Copy post-install system cinfiguration script to new /root
cp -rfv post-install.sh /mnt/root
chmod a+x /mnt/root/post-install.sh

# Chroot into new system
echo "After chrooting into newly installed OS, please run the post-install.sh by executing ./post-install.sh"
echo "Press any key to chroot..."
read tmpvar
arch-chroot /mnt /bin/bash

# Finish
echo "If post-install.sh was run succesfully, you will now have a fully working bootable Arch Linux system installed."
echo "The only thing left is to reboot into the new system."
echo "Press any key to reboot or Ctrl+C to cancel..."
read tmpvar
reboot
