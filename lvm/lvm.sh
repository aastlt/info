#!/bin/bash

#Подготовим временный том для / раздела:
vgcreate vg_root /dev/sdb
lvcreate -n lv_root -l +100%FREE /dev/vg_root
mkfs.xfs /dev/vg_root/lv_root
mount /dev/vg_root/lv_root /mnt

#Скопируем все данные с / раздела в /mnt:
xfsdump -J - /dev/VolGroup00/LogVol00 | xfsrestore -J - /mnt

#Изменим GRUB:
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg

#Обновим образ initrd:
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done

#Изменим /boot/grub2/grub.cfg чтобы при загрузке монтировался нужный root:
nano /boot/grub2/grub.cfg #заменить rd.lvm.lv=VolGroup00/LogVol00 на rd.lvm.lv=vg_root/lv_root
exit


#Уменьшим том под / до 8G:
lvremove /dev/VolGroup00/LogVol00
lvcreate -n VolGroup00/LogVol00 -L 8G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol00
mount /dev/VolGroup00/LogVol00 /mnt
xfsdump -J - /dev/vg_root/lv_root | xfsrestore -J - /mnt 
for i in /proc/ /sys/ /dev/ /run/ /boot/; do mount --bind $i /mnt/$i; done
chroot /mnt/
grub2-mkconfig -o /boot/grub2/grub.cfg
cd /boot ; for i in `ls initramfs-*img`; do dracut -v $i `echo $i|sed "s/initramfs-//g; s/.img//g"` --force; done
exit


#Выделим том под /var в зеркало:
vgcreate vg_var /dev/sdc /dev/sdd
lvcreate -L 950M -m1 -n lv_var vg_var
mkfs.ext4 /dev/vg_var/lv_var
mount /dev/vg_var/lv_var /mnt
cp -aR /var/* /mnt/
mkdir /tmp/oldvar && cp -r /var/* /tmp/oldvar #на всякий случай скопируем старый var
umount /mnt
mount /dev/vg_var/lv_var /var

#Правим fstab для автоматического монтирования /var:
echo "`blkid | grep var: | awk '{print $2}'` /var ext4 defaults 0 0" >> /etc/fstab
exit

#Удаляем временную vg_root:
lvremove /dev/vg_root/lv_root
vgremove /dev/vg_root

#Выделим том под /home по тому же принципу что делали для /var:
lvcreate -n LogVol_Home -L 2G /dev/VolGroup00
mkfs.xfs /dev/VolGroup00/LogVol_Home
mount /dev/VolGroup00/LogVol_Home /mnt/
cp -aR /home/* /mnt/
rm -rf /home/*
umount /mnt
mount /dev/VolGroup00/LogVol_Home /home/
echo "`blkid | grep Home | awk '{print $2}'` /home xfs defaults 0 0" >> /etc/fstab
exit

#Для /home сделаем том для снапшотов:
touch /home/file{1..20} #сгенерируем файлы в /home/
ll /home
lvcreate -L 100MB -s -n home_snap /dev/VolGroup00/LogVol_Home
rm -f /home/file{11..20} #удалим часть файлов 
ll /home
umount -l /home
lvconvert --merge /dev/VolGroup00/home_snap
exit
ll /home


















































