# mysql root pass
Testpass1$

# Установка репозитория Oracle MySQL 8.0
rpm -Uvh https://repo.mysql.com/mysql80-community-release-el7-5.noarch.rpm

# Включаем репозиторий
sed -i 's/enabled=1/enabled=0/' /etc/yum.repos.d/mysql-community.repo

# Устанавливаем MySQL
yum --enablerepo=mysql80-community install mysql-community-server

# Запускаем
systemctl start mysqld

# Ставим в автозагрузку
systemctl enable mysqld

# Отключаем firewalld
systemctl stop firewalld
systemctl disable firewalld

# Проверка портов
ss -ntlp

# Ставим имя хоста
hostnamectl set-hostname mysql-master
reboot

# Выясняем временный пароль
grep "A temporary password" /var/log/mysqld.log

# Запускаем скрипт безопасности для MySQL
mysql_secure_installation

# Заходим с паролем
mysql -uroot -p

# Просмотр пользователй в MySQL
use mysql; # просмотр базы на выбор

SELECT * FROM user WHERE User='root';

SELECT * FROM user WHERE User='root'\G

# Устанавливаем пароль. Важен выбор способа аутентификации! (с wordpress работает 2-й)
ALTER USER 'root'@'localhost' IDENTIFIED WITH 'caching_sha2_password' BY 'Testpass1$';

# 5.7 версия
ALTER USER 'root'@'localhost' IDENTIFIED WITH 'mysql_native_password' BY 'Testpass1$';

# Процессы

ps ax | grep mysqld

# Потоки
ps -eLf | grep mysqld

# Файлы
ls -l /var/lib/mysql # базы и бинлоги
/etc/my.cnf, /etc/my.cnf.d/ # настройки системные
~/.my.cnf # настройки клиента

# Тип бинлога
show variables like '%binlog%';

# Найти server_id
SELECT @@server_id;

# Начинаем слушать на всех IP /etc/my.cnf (не нужно на CentOS 7)
bind-address = 0.0.0.0

#####################################################
# На Мастере
#####################################################

# Отключаем firewalld
systemctl stop firewalld
systemctl disable firewalld


# Создаём пользователя для реплики
CREATE USER repl@'%' IDENTIFIED WITH 'caching_sha2_password' BY 'oTUSlave#2020'; 
# Даём ему права на репликацию
GRANT REPLICATION SLAVE ON *.* TO repl@'%';
# Сбрасываем кэш привилегий (не обязательно)
FLUSH PRIVILEGES;

# Смотрим пользователей
SELECT User, Host FROM mysql.user;

# Закрываем и блокируем все таблицы
FLUSH TABLES WITH READ LOCK;     (UNLOCK)

# Смотрим статус Мастера
SHOW MASTER STATUS;

######################################################
# На Слейве
######################################################

# Если клонировали машину с мастера, обновляем auto.cnf
rm /var/lib/mysql/auto.cnf
systemctl restart mysqld

# Отключаем firewalld
systemctl stop firewalld
systemctl disable firewalld

# Смотрим статус Мастера
SHOW MASTER STATUS;
sudo nano /etc/my.cnf

server_id = 2

systemctl restart mysqld

SHOW GLOBAL VARIABLES LIKE 'caching_sha2_password_public_key_path';
SHOW STATUS LIKE 'Caching_sha2_password_rsa_public_key'\G

# необходимо получить публичный ключ
STOP SLAVE;
CHANGE MASTER TO MASTER_HOST='192.168.0.10', MASTER_USER='repl', MASTER_PASSWORD='oTUSlave#2020', MASTER_LOG_FILE='binlog.000005', MASTER_LOG_POS=688, GET_MASTER_PUBLIC_KEY = 1;
START SLAVE;
SHOW SLAVE STATUS\G 

# https://dev.mysql.com/doc/refman/8.0/en/replica-logs-relaylog.html
# можем настроить наш relay.log
show variables like '%relay%';

# посмотрим статусы репликации
use performance_schema;
show tables like '%replic%';
show variables like '%log_bin%';
show variables like '%binlog%';
show variables like '%read%';

# рекомендуется включать для слейва, иначе на слейве тоже можем вносить изменения
# /etc/my.cnf
#innodb_read_only = 1


# КОМАНДЫ ДЛЯ УПРАВЛЕНИЯ СОСТОЯНИЕМ
STOP SLAVE;
START SLAVE;

# Создание базы данных
create database название_базы;
drop database название_базы;
show databases;
use название_базы;

# Создание таблицы внутри этой базы
create table test_tbl (id int);
select * from название_таблицы; # просмотр таблицы

# Добавляем строчки в эту таблицу
insert into test_tbl values (2),(3),(4);

# варианты разрешения конфликтов
1. удалить на слейве блокирующую запись
2. STOP SLAVE;
RESET SLAVE;
SHOW SLAVE STATUS; # на мастере
# новый номер позиции в бинлоге

START SLAVE;

3. скипаем 1 ошибку
stop slave; 
set global sql_slave_skip_counter=1; 
start slave;

# скрипт избавления от дубликатов при репликации
while [ 1 ]; do      
if [ `mysql -uroot -ptest -e"show slave status \G;" | grep "Duplicate entry" | wc -l` -eq 2 ] ; then          
mysql -uroot -ptest -e "stop slave; set global sql_slave_skip_counter=1; start slave;";      
fi;      
mysql -uroot -ptest -e "show slave status\G";  
done

4. можно добавить в конфиг игнор ошибки при репликации
ну для duplicate entry например ошибка номер 1062
в конфиг добавляется
slave-skip-errors = 1062

################### Бекапы
mysqldump --help

# Бекап без создания таблиц
mysqldump --all-databases --no-create-info -u root -p > dump-data.sql

# C сохранением позиции бинлога
mysqldump -h 10.128.15.220 -p --all-databases --events --routines --master-data=2 > dump_file

# Скачивание бинлогов
# стандартный бэкап 1 файла
mysqlbinlog -R -h 10.128.15.201 -p --raw binlog.000001

# бэкапы без остановки начиная с 1 файла
mysqlbinlog -R -h 10.128.15.201 -p --raw --stop-never binlog.000001

# заливаем данные
mysql -u root -p < dump-data.sql

# Проигрываем изменение из бинлога
mysqlbinlog --start-position=4596 binlog.000004 | mysql




