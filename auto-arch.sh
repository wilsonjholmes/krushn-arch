#! /bin/bash

# Set up time
timedatectl set-ntp true

# show drives available
lsblk

# Set drive for installation
echo "Which drive you wish to install to? "
echo "Your argument should have a format like this -> '/dev/sda'"
read -p "Enter the path to that drive that you wish to install to: " TGTDEV

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
  2 # partition number 2
    # default, start immediately after preceding partition
  +32G # 32Gib root partition
  t # type of partition
  2 # partition number 2
  24 # partition type 24 'Linux root (x86-64)'
  n # new partition
  3 # partition number 3
    # default, start immediately after preceding partition
    # default, Go to the end of the disk
  t # type of partition
  3 # partition number 3
  28 # partition type 28 'Linux Home'
  p # print the in-memory partition table
  w # write the partition table
EOF

# Format the partitions
mkfs.fat -F32 ${TGTDEV}1
mkfs.ext4 ${TGTDEV}2
mkfs.ext4 ${TGTDEV}3

# Initate pacman keyring
pacman-key --init
pacman-key --populate archlinux
pacman-key --refresh-keys

# Mount the partitions
mkdir /mnt/boot
mkdir /mnt/boot/efi
mount ${TGTDEV}1 /mnt/boot/efi
mount ${TGTDEV}2 /mnt
mkdir /mnt/home
mount ${TGTDEV}3 /mnt/home

# Install reflector for sorting mirrors
pacman -Sy reflector --noconfirm

# Store a backup of the mirrors that came with the installation
mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup

# Get the fastest in-sync (up-to-date) mirrors and store 10 of them (sorted) in mirrorlist
reflector -l 200 -f 10 --sort score > /etc/pacman.d/mirrorlist

# Setup the cpu microcode package
read -p "Are you installing on a computer with an AMD[1] or Intel[2] cpu: " CPU

# Minimal install with pacstrap (graphical setup will be done in another script)
pacstrap /mnt base base-devel linux linux-firmware intel-ucode efibootmgr grub nano neovim git openssh networkmanager

# Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# Copy post-install system configuration scripts to new / (or currently /mnt for us before chroot)
cp -rfv *.sh /mnt/
chmod a+x *.sh

# chroot into installation
# arch-chroot /mnt bash ./post-chroot.sh
arch-chroot /mnt /bin/bash <<EOF
  bash ./post-chroot.sh
EOF
