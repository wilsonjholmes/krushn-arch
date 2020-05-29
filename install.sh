#! /bin/bash

# This is my Arch Linux Installation Script.
# Forked from krushndayshmookh.github.io/krushn-arch.

echo "

    __          ___ _                 _            
    \ \        / (_) |               ( )           
     \ \  /\  / / _| |___  ___  _ __ |/ ___        
      \ \/  \/ / | | / __|/ _ \| '_ \  / __|       
       \  /\  /  | | \__ \ (_) | | | | \__ \       
        \/  \/   |_|_|___/\___/|_| |_| |___/       
                                                   
                                                   
                _                            _     
     /\        | |            /\            | |    
    /  \  _   _| |_ ___      /  \   _ __ ___| |__  
   / /\ \| | | | __/ _ \    / /\ \ | '__/ __| '_ \ 
  / ____ \ |_| | || (_) |  / ____ \| | | (__| | | |
 /_/    \_\__,_|\__\___/  /_/    \_\_|  \___|_| |_|
 
 
"

# Set up network connection
read -p 'Are you connected to internet? [y/N]: ' neton
if ! [ $neton = 'y' ] && ! [ $neton = 'Y' ]
then 
    echo "Connect to internet to continue..."
    exit
fi

# Filesystem mount warning
echo "This script will create and format the partitions as follows:"
echo "/dev/sda1 - 512Mib will be mounted as /boot/efi"
echo "/dev/sda2 - rest of space will be mounted as /"
read -p 'Continue? [y/N]: ' fsok
if ! [ $fsok = 'y' ] && ! [ $fsok = 'Y' ]
then 
    echo "Edit the script to continue..."
    exit
fi

# to create the partitions programatically (rather than manually)
# https://superuser.com/a/984637
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${TGTDEV}
  o # clear the in memory partition table
  n # new partition
  p # primary partition
  1 # partition number 1
    # default - start at beginning of disk 
  +512M # 512 MB boot parttion
  t # type of partition
    # default - start at beginning of disk
  1 # efi flag
  n # new partition
  p # primary partition
  2 # partion number 2
    # default, start immediately after preceding partition
    # default, extend partition to end of disk
  a # make a partition bootable
  1 # bootable partition is partition 1 -- /dev/sda1
  t # type of partition
  2 # do this to the main partition
  24 # Linux filesystem flag
  p # print the in-memory partition table
  w # write the partition table
  q # and we're done
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
