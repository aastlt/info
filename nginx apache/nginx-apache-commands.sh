# Установка репозитория EPEL
yum install epel-release

# Установка Nginx
yum install nginx

# Установка Apache
yum install httpd

# Запуск Nginx
systemctl start nginx

# Автозапуск Nginx
systemctl enable nginx

# Проверка статуса
systemctl status nginx

# Запуск Apache
systemctl start httpd

# Автозапуск Apache
systemctl enable httpd


# Проверка статуса
systemctl status httpd

# Отключаем SELinux
setenforce 0

# Отключаем firewalld
systemctl stop firewalld
systemctl disable firewalld

# Проверка портов
ss -ntlp

# проверка загрузки url
curl localhost:80

# Apache config 
nano /etc/httpd/conf/httpd.conf

Listen 80 # установить порт

# Apache default page
/etc/httpd/conf.d/welcome.conf

# Aapche default DocumentRoot

/var/www/html

#  Проверка синтаксиса
apachectl -t
nginx -t

# Nginx conf
Убираем блок server { } из
/etc/nginx/nginx.conf # основной конфиг

/etc/nginx/conf.d/default.conf # свои настройки

# Apache conf для баланса (виртуальные хосты)
/etc/httpd/conf.d/vh.conf








