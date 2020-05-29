#! /bin/bash
set -e # Stop script on error

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
