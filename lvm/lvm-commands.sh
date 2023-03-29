#!/bin/bash

#Создадим LV test и small, файловую систему на test и смонтируем:
pvcreate /dev/sdb
vgcreate otus /dev/sdb
lvcreate -l+80%FREE -n test otus
lvcreate -L100M -n small otus
mkdir /data; mount /dev/otus/test /data/

#Увиличим размер LV и файловой смстымы на нем:
#lvresize /dev/VolGroup00/LogVol00 -L +2G -r

#Расширим файловую систему на LV /dev/otus/test, добавим /dev/sdc в VG otus:
pvcreate /dev/sdc
vgextend otus /dev/sdc
dd if=/dev/zero of=/data/test.log bs=1M count=8000 status=progress
lvextend -l+80%FREE /dev/otus/test
resize2fs /dev/otus/test

#Уменьшим существующий LV:
umount /data/
e2fsck -fy /dev/otus/test
resize2fs /dev/otus/test 10G
lvreduce /dev/otus/test -L 10G
mount /dev/otus/test /data/

#Изъять PV /dev/sde из VG для замены при смонтированных LV (в VG должно быть свободное пространство не меньше изымаемого PV):
pvmove /dev/sde #перенос данных для последующего изъятия
vgreduce pool /dev/sde #изъять /dev/sde из VG
pvremove /dev/sde #изъять /dev/sde из состава LVM
vgextend pool /dev/sdg #вводим в VG новый диск /dev/sde

#Создадим снапшот на LV test, удалим тестовый файл, откатимся на снапшот:
lvcreate -L 500M -s -n test-snap /dev/otus/test
mkdir /data-snap; mount /dev/otus/test-snap /data-snap
rm /data/test.log
umount /data
umount /data-snap/
lvconvert --merge /dev/otus/test-snap
mount /dev/otus/test /data

#Mirroring
pvcreate /dev/sd{d,e}
vgcreate vg0 /dev/sd{d,e}
lvcreate -l+80%FREE -m1 -n mirror vg0
...

#Кэширование на lvm
vgextend pool /dev/sde #добавим в vg pool диск для кэша
lvcreate --type cache-pool -n cache -L 900M pool /dev/sde # создадим кэш pool на диске sde 
lvconvert --type cache pool/01 --cache-pool pool/cache # включим кэширование для диска lv 01 в vg pool
lvs
lvconvert --uncache pool/01 #отключить кэширование




