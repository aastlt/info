# Локальный мониторинг
htop - улучшенная top
iotop - нагрузка на диски - чтение/запись
jnettop - статистика траффика - имена хостов и данные
nmon - утилита с большим набором инструментов

#ВАЖНО!!!!!!!!!!!!!  Права на файлы и директории сервисов должны принадлежать пользователю и группе этого сервиса (либо рут для вложенных директорий и файлов - но куда вложены - владелец сервис и его группа)

# Установка Prometheus на основной сервер для мониторинга
wget https://github.com/prometheus/prometheus/releases/download/v2.39.1/prometheus-2.39.1linux-amd64.tar.gz
tar -xvf prometheus-2.39.1.linux-amd64.tar.gz; rm prometheus-2.39.1.linux-amd64.tar.gz
useradd --no-create-home --shell /usr/sbin/nologin prometheus # создать пользователя без прав для ПО из исходных кодов (напр. исп. nologin)
mkdir -v {/etc,/var/lib}/prometheus # создать директории ПО
chown -v prometheus: {/etc,/var/lib}/prometheus # сменить владельца директорий на созданного пользователя без прав
cd prometheus-2.39.1.linux-amd64
rsync -P prometheus promtool /usr/local/bin # скопировать ПО в директорию переменной $PATH
cd /usr/local/bin
chown -v prometheus: /usr/local/bin/prometheus; chown -v prometheus: /usr/local/bin/promtool # сменить владельца ПО на созданного пользователя без прав

# Перенос отредактированного .yml-файла и конфигов для Prometheus
cp -v prometheus-2.39.1.linux-amd64/console{_libraries,s} prometheus.yml /etc/prometheus/
chown -v prometheus: /etc/prometheus/ # сменить владельца директорий и файлов на созданного пользователя без прав


# Установка Node-exporter для сбора метрик (данных)
wget https://github.com/prometheus/node_exporter/releases/download/v1.4.0/node_exporter-1.4.0.linux-amd64.tar.gz
tar -xvf node_exporter-1.4.0.linux-amd64.tar.gz; rm node_exporter-1.4.0.linux-amd64.tar.gz
useradd --no-create-home --shell /bin/false node_exporter # оздать пользователя без прав для ПО из исходных кодов (напр. исп. false)
rsync -P node_exporter /usr/local/bin # скопировать ПО в директорию переменной $PATH
cd /usr/local/bin
chown node_exporter: /usr/local/bin/node_exporter # сменить владельца ПО на созданного пользователя без прав


# Установка Grafana на основной сервер для мониторинга
wget https://dl.grafana.com/oss/release/grafana-9.2.1-1.x86_64.rpm
yum install grafana-9.2.1-1.x86_64.rpm; rm grafana-9.2.1-1.x86_64.rpm


# Перенос созданных юнитов SystemD для сервисов Prometheus и Node-exporter
cp -v node_exporter.service prometheus.service /etc/systemd/system

# Запуск сервисов 
systemctl daemon-reload
systemctl enable --now prometheus.service
systemctl enable --now node_exporter.service
systemctl enable grafana-server.service 
systemctl start grafana-server.service
systemctl restart grafana-server.service

# Работа с сервисами через браузер
192.168.0.110:9090 # на основном сервере с прометеусом заходим по адресу хоста и порта прометеуса 
192.168.0.110:9090/metrics # обзор собранных метрик 
192.168.0.110:9100 # заходим по адресу хоста и порта нод-экспортера

192.168.0.110:3000 # на основном сервере с графаной заходим по адресу хоста и порта графаны
user - admin
password - admin

Настройки - Data sources - Add data source - Prometheus:
Default
URL - http://192.168.0.110:9090 # адрес хоста и порта прометеус
Save & test

https://grafana.com/grafana/dashboards/ # поиск дашбордов, ищем для node-exporter (или любого нужного агента)
Выбрали нужный - Copy ID
Заходим в Grafana - Dashboards - Import

# При создании скрипта по установке, можно закончить удалением временных файлов и папок, оставив лишь файлы конфигурации

# Установка AlertManager
wget https://github.com/prometheus/alertmanager/releases/download/v0.25.0/alertmanager-0.25.0.linux-amd64.tar.gz
tar zxf alertmanager-0.25.0.linux-amd64.tar.gz
useradd --no-create-home --shell /bin/false alertmanager
usermod --home /var/lib/alertmanager alertmanager
mkdir /etc/alertmanager
mkdir /var/lib/alertmanager
mkdir /var/lib/prometheus/alertmanager

cp alertmanager-0.25.0.linux-amd64/amtool /usr/local/bin/
cp alertmanager-0.25.0.linux-amd64/alertmanager /usr/local/bin/
cp alertmanager-0.25.0.linux-amd64/alertmanager.yml /etc/alertmanager/
chown -R alertmanager:alertmanager /etc/alertmanager /var/lib/alertmanager
chown alertmanager:alertmanager /usr/local/bin/{alertmanager,amtool}
echo "ALERTMANAGER_OPTS=\"\"" > /etc/default/alertmanager
chown alertmanager:alertmanager /etc/default/alertmanager
chown -R alertmanager:alertmanager /var/lib/prometheus/alertmanager

nano /etc/systemd/system/alertmanager.service

systemctl daemon-reload
systemctl start alertmanager

nano /etc/prometheus/rules.yml
/usr/local/bin/promtool check rules /etc/prometheus/rules.yml

nano /etc/prometheus/prometheus.yml #добавим в конце
#rule_files:
#  - "rules.yml"
#alerting:
#  alertmanagers:
#    - static_configs:
#      - targets:
#        - localhost:9093

systemctl restart prometheus
systemctl restart alertmanager
























































