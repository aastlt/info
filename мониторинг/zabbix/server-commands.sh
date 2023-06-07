#Установить MySQL:
apt install mysql-server 

#Установите репозиторий Zabbix:
wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
apt update

#Установите Zabbix сервер, веб-интерфейс: 
apt install -y zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts

#Настроить базу данных Zabbix:
mysql
mysql> create database zabbix character set utf8mb4 collate utf8mb4_bin;
mysql> create user zabbix@localhost identified by 'password';
mysql> grant all privileges on zabbix.* to zabbix@localhost;
mysql> set global log_bin_trust_function_creators = 1;
mysql> quit;

#На хосте Zabbix сервера импортируйте начальную схему и данные. Вам будет предложено ввести недавно созданный пароль:
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | mysql --default-character-set=utf8mb4 -uzabbix -p zabbix

#Выключите опцию log_bin_trust_function_creators после импорта схемы базы данных:
mysql
mysql> set global log_bin_trust_function_creators = 0;
mysql> quit;

#Настройте базу данных для Zabbix сервера. Отредактируйте файл /etc/zabbix/zabbix_server.conf 
nano /etc/zabbix/zabbix_server.conf
> DBPassword=password

#Запустите процессы Zabbix сервера и агента:
systemctl restart zabbix-server apache2
systemctl enable zabbix-server apache2

#Проверка:
ip-adress(или домен)/zabbix
user Admin
pass zabbix
