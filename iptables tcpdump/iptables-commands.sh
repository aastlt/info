#yum install setuptool
#setup #утилита настройки


# С флагом --uid-owner можно настроить правила, которые привязываются к пакетам определенного пользователя 

# Таблица по умолчанию - filter

# Просмотр цепочек и правил таблицы
iptables -t <таблица> -L
iptables -L # таблица filter
iptables -nvL --line-numbers # подробное инфо
iptables-save # инфо о всех правилах во всех таблицах

# Очистить правила во всех цепочках
iptables -F

# Удалить пользовательские цепочки 
iptables -X

# Создать пользовательские цепочки (напр. TCP UDP)
iptables -N TCP
iptables -N UDP

# Общий синтаксис использования iptables
iptables -t <таблица> <команда> <цепочка> [номер] <условие> <действие>

# Добавить правило в цепочку INPUT таблицы по умолчанию (filter):
  # разрешить все пакеты с маркировкой соединения RELATED и ESTABLISHED
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
  # разрешить обращение к lo-интерфейсу для внутренних запросов системы
iptables -A INPUT -i lo -j ACCEPT
  # запретить все пакеты с маркировкой соединения INVALID
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP
  # разрешить icmp траффик для запросов echo-request (ping и иные сообщения о действиях и ошибках в сети)
iptables -A INPUT --protocol icmp --icmp-type echo-request -j ACCEPT
  # разрешить все пакеты с определенного порта (например ssh tcp 22)
iptables -A INPUT --protocol tcp --dport 22 -j ACCEPT

# Удалить правило - заменить -А на -D, например
iptables -D INPUT --protocol icmp --icmp-type echo-request -j ACCEPT
    # либо по номеру правила:
iptables -D INPUT 4   

# Копировать правило в определенное место (например сделать номером 3)
iptables -I INPUT 3 --protocol icmp --icmp-type echo-request -j ACCEPT

# Перезаписать правило (например под номером 3)
iptables -R INPUT 3 --protocol icmp --icmp-type echo-request -j ACCEPT

# Сменить политику цепочки INPUT с ACCEPT на DROP 
iptables --policy INPUT DROP

# Сохранить настройки в файл
iptables-save | tee iptables.bak

# Загрузить настройки из файла (счётчики пакетов будут на момент сохранения файла)
iptables-restore < iptables.bak
iptables-save

# Установка сервиса iptables (добавление правил в автозагрузку)
yum install iptables-services.x86_64
service iptables save
systemctl enable --now iptables.service



# Пример доп. настройки (тогда правило выше для ssh порт 22 не добавляем)
  # прикрепим TCP- и UDP-цепочки к цепочке INPUT, новые TCP соединения должны начинаться с SYN-сегмента
iptables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP
iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP 
  # отклоняем TCP-соединения пакетами TCP RESET, а UDP-потоки — сообщениями ICMP "port unreachable"
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-reset 
  # отклонить остальной входящий трафик с ICMP-сообщением "protocol unreachable"
iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachable 
  # разрешить удаленные SSH-соединения (на порт 22)
iptables -A TCP -p tcp --dport 22 -j ACCEPT 
  # разрешить входящие TCP-соединения на порт 80 для веб-сервера (HTTP)
iptables -A TCP -p tcp --dport 80 -j ACCEPT
  # разрешить входящие TCP-соединения на порт 443 для веб-сервера (HTTPS)
iptables -A TCP -p tcp --dport 443 -j ACCEPT
  # разрешить входящие TCP/UDP запросы для DNS-сервера (порт 53)
iptables -A TCP -p tcp --dport 53 -j ACCEPT
iptables -A UDP -p udp --dport 53 -j ACCEPT 
























 




