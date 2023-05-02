# SELinux commands

# Установка инструментов для SELinux
yum install policycoreutils-python policycoreutils-newrole
yum install setools-console
yum install selinux-policy-mls
yum install setroubleshoot-server


# Смотрим текущие настройки
sestatus

# Отключаем временно
setenforce 0

# Включаем временно (если в конфиге не disabled)
setenforce 1

semanage login -l

# Пример с passwd
sesearch -s passwd_t -A | grep shadow
sesearch -A -s shadow_t
sesearch -s passwd_t -t passwd_exec_t -c file -p execute -Ad

# Режим работы SELinux
nano /etc/selinux/config

# Просмотр событий 
tail -n 100 /var/log/audit/audit.log 

# Ставм нестандартный порт для SSHD
nano /etc/ssh/sshd_config

# Анализ событий в логе
audit2why < /var/log/audit/audit.log

# Добавляем нестандартный порт для SSHD
semanage port -a -t ssh_port_t -p tcp 10022

# Проверяем
semanage port -l | grep ssh

# Тестируем проблему на mysql
ls -Z /var/lib/mysql

# Создаём проблему (временно)
chcon -v -R -t samba_share_t /var/lib/mysql

# Анализ событий в логе
audit2why < /var/log/audit/audit.log

# Восстанавливаем контекст
restorecon -v -R /var/lib/mysql

# Сохраняем контекст навсегда в политике
mkdir /root/test
ls -Z /root/test
chcon -R -t samba_share_t /root/test
semanage fcontext -a -t samba_share_t "/root/test(/.*)?"
restorecon -v -R /root/test
ls -Z /root/test

# Меняем порт для Nginx

# Поиск решений проблем
sealert -a /var/log/audit/audit.log
# Разрешение через создание модуля
ausearch -c 'nginx' --raw | audit2allow -M my-nginx
semodule -i my-nginx.pp
semodule -l | grep nginx
seinfo --portcon=80

# Формирование модуля из ошибок в логе
audit2allow -M httpd_add --debug < /var/log/audit/audit.log

# Параметризованные политики
getsebool -a | grep samba
setsebool -P samba_share_fusefs on



