# Рабора с текстовыми логами

# Отправка сообщения в системный журнал логов с указанием даты (можно использовать в скриптах)
DATE=`date`
logger "$DATE: ТЕКСТ "

# Файл конфигурации логов по умолчанию (rsyslog.d)
cat /etc/rsyslog.conf

# Фильтрация лога
cat messages | grep err | grep -P '\d{2}:\d{2}:00'

# Последние 10 строк лога
tail -n 10 messages

# Первые 10 строк лога
head -n 10 messages

# Просмотр сообщений в реальном времени
tail -f messages


# Journald (в centos7 по умолчанию логи пишутся для текущей сессии)

# Конфиг и директории сервисов  для ротации логов
cat /etc/logrotate.conf
cd /etc/logrotate.d
cd /etc/cron.daily/logrotate # скрипт ротации логов

# Проверка формата времени
timedatectl status
sudo timedatectl set-timezone zone

# Логи с момента загрузки
journalctl -b

# Сохрание логов между загрузками системы
sudo mkdir -p /var/log/journal
sudo nano /etc/systemd/journald.conf

[Journal]
Storage=persistent

# Фильтрация по времени
journalctl --since "2022-01-01 17:15:00"
journalctl --since "2022-01-01 17:15:00" --until "2022-01-02 17:15:00"
journalctl --since yesterday
journalctl --since 09:00 --until "1 hour ago"

# Фильтрация по юниту
journalctl -u nginx.service

# Фильтрация по приоритету
journalctl -p err -b

# Форматирование в JSON
journalctl -b -u nginx -o json-pretty


#############################################################
ELK setup
#############################################################

sudo yum -y install java-openjdk-devel java-openjdk

# Устанавливаем ELK ПО из скачанных .rpm
yum install *.rpm

#cat <<EOF | sudo tee /etc/yum.repos.d/elasticsearch.repo
#[elasticsearch-7.x]
#name=Elasticsearch repository for 7.x packages
#baseurl=https://artifacts.elastic.co/packages/7.x/yum
#gpgcheck=1
#gpgkey=https://artifacts.elastic.co/GPG-KEY-elasticsearch
#enabled=1
#autorefresh=1
#type=rpm-md
#EOF
#
#sudo rpm --import https://artifacts.elastic.co/GPG-KEY-elasticsearch
#
#sudo yum clean all
#sudo yum makecache
#
#sudo yum -y install elasticsearch
#
#rpm -qi elasticsearch 


# Устанавливаем лимиты памяти для виртуальной машины Java
cat > /etc/elasticsearch/jvm.options.d/jvm.options

-Xms1g
-Xmx1g

####

# Запускаем сервис elasticsearch
sudo systemctl enable --now elasticsearch.service

# Проверяем
curl http://127.0.0.1:9200

# Создаём тестовый индекс
curl -X PUT "http://127.0.0.1:9200/mytest_index"

# Установка kibana
#sudo yum -y install kibana

sudo nano /etc/kibana/kibana.yml
server.port: 5601
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]

sudo systemctl enable --now kibana

sudo firewall-cmd --add-port=5601/tcp --permanent
sudo firewall-cmd --reload

systemctl stop firewalld

# Установка Logstash
#sudo yum -y install logstash filebeat auditbeat metricbeat packetbeat heartbeat-elastic

# logstash config
sudo nano /etc/logstash/logstash.yml

path.data: /var/lib/logstash
path.config: /etc/logstash/conf.d
path.logs: /var/log/logstash


cat > /etc/logstash/conf.d/logstash-nginx-es.conf

input {
    beats {
        port => 5400
    }
}

filter {
 grok {
   match => [ "message" , "%{COMBINEDAPACHELOG}+%{GREEDYDATA:extra_fields}"]
   overwrite => [ "message" ]
 }
 mutate {
   convert => ["response", "integer"]
   convert => ["bytes", "integer"]
   convert => ["responsetime", "float"]
 }
 geoip {
   source => "clientip"
   add_tag => [ "nginx-geoip" ]
 }
 date {
   match => [ "timestamp" , "dd/MMM/YYYY:HH:mm:ss Z" ]
   remove_field => [ "timestamp" ]
 }
 useragent {
   source => "agent"
 }
}

output {
 elasticsearch {
   hosts => ["localhost:9200"]
   index => "weblogs-%{+YYYY.MM.dd}"
   document_type => "nginx_logs"
 }
 stdout { codec => rubydebug }
}


sudo systemctl restart logstash.service


##############################


# Filebeat config

sudo nano /etc/filebeat/filebeat.yml

# Закомментарить output.elasticsearch

filebeat.inputs:
- type: log
  paths:
    - /var/log/nginx/*.log
  exclude_files: ['\.gz$']

output.logstash:
  hosts: ["localhost:5400"] 


systemctl enable --now filebeat
systemctl restart filebeat

systemctl start nginx

# Ходим по 80 порту, собираем логи nginx

# Заходим на панель
http://192.168.0.110:5601/app/home#/

# Kibana - Index Patterns - Create Index pattern
# Name weblogs-*, Timestamp field - @timestamp

# Analytics - Discover - weblogs-* (слева вверху) (тут можно посмотреть логи через запрос)

# Analytics - Dashboard - Create

# Bar horizontal - request.keyword host.ip.keyword
# Donut - slice by response, size by #records

# https://www.youtube.com/channel/UCH_PvxSiuETI_ecbeAmb7_w

# https://www.youtube.com/channel/UCf1P_nESQ6hPlTwkH5Vik1A

