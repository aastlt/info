#!/bin/bash

#RAID10 with 5 disks
yes|mdadm --create --verbose /dev/md/md127 --level=10 --raid-devices=5 /dev/sd[b-f]
mkdir -p /etc/mdadm
echo "DEVICE partitions" > /etc/mdadm/mdadm.conf
mdadm --detail --scan --verbose | awk '/ARRAY/ {print}' >> /etc/mdadm/mdadm.conf

#GPT particion
parted -s /dev/md127 mklabel gpt
parted /dev/md127 mkpart primary ext4 0% 20%
parted /dev/md127 mkpart primary ext4 20% 40%
parted /dev/md127 mkpart primary ext4 40% 60%
parted /dev/md127 mkpart primary ext4 60% 80%
parted /dev/md127 mkpart primary ext4 80% 100%

#File system
for i in $(seq 1 5); do sudo mkfs.ext4 /dev/md127p$i; done
mkdir -p /raid/part{1,2,3,4,5}
for i in $(seq 1 5); do mount /dev/md127p$i /raid/part$i; done

#Auto mount
echo "/dev/md127p1 /raid/part1 ext4 auto 0 0" >> /etc/fstab
echo "/dev/md127p2 /raid/part2 ext4 auto 0 0" >> /etc/fstab
echo "/dev/md127p3 /raid/part3 ext4 auto 0 0" >> /etc/fstab
echo "/dev/md127p4 /raid/part4 ext4 auto 0 0" >> /etc/fstab
echo "/dev/md127p5 /raid/part5 ext4 auto 0 0" >> /etc/fstab
