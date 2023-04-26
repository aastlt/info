
# Создать разряженный файл (любого размера (для теста), а фактически нулевого):
dd if=/dev/zero of=./01.raw bs=1024 count=1 seek=1048576

# Создадим pool test01 c raid6 из 5ти дисков (raidz2 - где 2 - это кол-во дисков, которое могут выйти из строя без потери данных):
zpool create test01 raidz2 $PWD/0{1,2,3,4,5}.raw
zpool list #просмотр пулов
zpool list -v #детальный просмотр пулов с составом
zpool status test01 #просмотр конкретного пула
zfs list #просмотр доступного рабочего пространства в файловой системе

# Создадим файловые системы на пуле test01 (по умолчанию будут использовать все пространство пула):
zfs create test01/z01
zfs create test01/z02
zfs create test01/z03

# Получение информации о zfs:
zfs get (опция - например mountpoint или mounted или quota итп)

# Установка квоты 100мб на размер z01:
zfs set quota=100M test01/z01
zfs set quota=none test01/z01 #удалить квоту

# Дедупликация и компрессия:
zfs get dedup #статус дедупликации
zfs set dedup=on test01/z02 #включить дедупликацию на z02
zfs get compression #статус компрессии
zfs set compression=on test01/z03 #включить компрессию на z03 (можно выбрать разные варианты - lz4, gzip, ... итп)
zfs get compressratio #просмотр эффективности сжатия




