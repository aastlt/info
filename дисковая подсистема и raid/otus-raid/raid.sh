#!/bin/bash

# Creating RAID10 with 6 disks
yes|mdadm --create --verbose /dev/md/raid10 --level=10 --raid-devices=6 /dev/sd[b-g]
echo -e "CREATE owner=root group=disk mode=0660 auto=yes\nHOMEHOST <system>\nMAILADDR root" > /etc/mdadm.conf
mdadm --detail --scan >> /etc/mdadm.conf

# Creating partition table
parted /dev/md127 -s mklabel gpt
parted /dev/md127 -s print

# Creating file system
mkfs.ext4 /dev/md127

# Mount raid array
mount /dev/md127 /mnt

# Mounting array after restart
UUID=`mdadm --detail /dev/md127 | grep UUID | awk '{print $3}'`
echo "/dev/md127 /mnt ext4 auto 0 0" >> /etc/fstab
