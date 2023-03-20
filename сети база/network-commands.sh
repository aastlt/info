# Просмотр сетевых интерфейсов
ip a
ip link

# Статистика
ip -s addr show

# Socket stat
ss -ntlp
ss -ntulp
ss -tulpan
ss -lt

yum install net-tools
netstat -tulpan

# Проверка подключения по портам (сканирование портов на доступность)
yum install nmap 
nmap otus.ru # можно запустить с нужными параметрами

# Соединиться с конкретным портом по протоколу
nc -zvw1 8.8.8.8 80 # TCP
nc -u 8.8.8.8 53 # UDP

# Просмотр маршрутов
ip route show
yum install traceroute
tracepath адрес # детальный просмотр пути пакетов (обратный маршрут)
traceroute адрес # детальный просмотр пути пакетов (маршрут до)
yum install mtr
mtr адрес # просмотр статистики хостов по адресу

# Просмотр DNS-серверов


# Статистика по интерфейсу
sudo ip -s addr show enp0s3

# Работа с маршрутами
# Удаляем
ip route delete default via 192.168.0.1

# Возвращаем
ip route add default via 192.168.0.1 dev enp0s3

# Проверка по ICMP
ping -i 0.1 -c 5 8.8.8.8

# Добавляем IP к интерфейсу
sudo ip addr add 192.168.0.9/255.255.255.0 broadcast 192.168.0.255 dev enp0s3

sudo ip route show

# Прописываем дефолтный маршрут
sudo ip route add default via 192.168.0.254 dev enp0s3

# Статический IP
cat >> /etc/sysconfig/network-scripts/ifcfg-enp0s3

BOOTPROTO="static"
IPADDR=192.168.0.88
NETMASK=255.255.255.0
GATEWAY=192.168.0.1
DNS1=8.8.8.8
DNS2=1.1.1.1


systemctl restart network

ifdown enp0s3; ifup enp0s3

# Работа с DNS
yum install bind-utils

host -t a otus.ru
host -t a otus.ru 8.8.8.8
dig otus.ru
nslookup google.com

# Системная конфигурация DNS-серверов
cat /etc/resolv.conf
# Локальный файл с именами
cat /etc/hosts




