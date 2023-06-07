![tran](/assets/otus_first_pages.png)<!-- .element: width="100%" -->

---

![tran](/assets/otus_sound_check.png)<!-- .element: width="100%" -->

---

# НЕ ЗАБЫТЬ ВКЛЮЧИТЬ ЗАПИСЬ!!!

---

# Zabbix

---

## План

- Уставновка Zabbix через ansible (server, agent, database, web)
- Архитектура Zabbix
- обзор конфигурационных файлоы сервера и агентов
- Настройка Discovery и Actions
- Обнаружение и подключение хоста с порталом
- переменные и макросы
- Обзор шаблонов
- Обзор конфигурации хоста: items, triggers
- Обзор секции мониторинг
- Обзор LLD на примере дисковой подсистемы и сетевых карт
- Настройка скрина и триггеров для сервера с порталом


---

## Развертывание стенда

- забираем стенд
    - https://github.com/erlong15/zabbix-lab
- стартуем vagrant
    - vagrant up
    - vagrant ssh ansible
- запускаем ansible сценарии согласно инструкции в репозитории
    - при развороте веб стенда указываем в переменных имя для вордпресса
        - wp.otus.example
- пока разворачивается, рассмотрим архитектуру Zabbix

---

## Обратим внимание на переменные для установки

- внесем правки
- ~/ansible-playbooks/wordpress-lamp_ubuntu1804/vars

```bash
    cat default.yml
    ---
    #System Settings
    php_modules: [ 'php-curl', 'php-gd', 'php-mbstring', 'php-xml', 'php-xmlrpc', 'php-soap', 'php-intl', 'php-zip' ]

    #MySQL Settings
    mysql_root_password: "mysql_root_password"
    mysql_db: "wordpress"
    mysql_user: "sammy"
    mysql_password: "password"

    #HTTP Settings
    http_host: "wp.otus.example"
    http_conf: "wp.otus.example.conf"
```

---

## История

- Zabbix — свободная система мониторинга и отслеживания статусов написанная Алексеем Владышевым.
Zabbix начался в 1998 году как внутренний проект в латвийском банке.
- 7 апреля 2001 года система была выпущена публично под лицензией GPL.
- Первая стабильная версия — 1.0 от 23 марта 2004.
- В апреле 2005 года была создана латвийская компания SIA Zabbix для управления проектом.

---


## Архитектура Zabbix 

<p align="center">
  <img width="75%" height="75%" src="/assets/OTUS_Platform/Linux-monitoring/zbx1.png">
</p>

---

## Компоненты  Zabix

- zabbix server 
    - осуществляет сбор данных, проверяет условия, рассылает уведомления
- zabbix agent
    - собирает метрики на конечных хостах
- zabbix proxy
    - позволяет распределить нагрузку при сборе метрик
- web interface 
    - реализован на php, предоставляет панель управления и мониторинга
- база данных
    - реляционная БД - mysql или postgres, предназначенная для хранения параметров конфигурации и метрик


---


## Push/Pull модели сбора метрик 

<p align="center">
  <img width="75%" height="75%" src="/assets/OTUS_Platform/Linux-monitoring/zbx2.png">
</p>


---

## Zabbix Active/Passive checks

<p align="center">
  <img width="75%" height="75%" src="/assets/OTUS_Platform/Linux-monitoring/zbx3.png">
</p>

---

## Обзор стенда

- ansible node
    - git 
    - ansible
- zabbix node
    - zabbix-server
    - web (apache, php-fpm)
    - zabbix-agent
    - mysql
- web node
    - mysql
    - apache
    - wordpress

---

## Обзор сценариев установки стенда

- Установка php-fpm, mysql, zabbix-server, zabbix-agent, apache, zabbix-web
    - [zabbix.yml](https://github.com/erlong15/zabbix-lab/blob/main/zabbix_vm/zabbix.yml)
- Базовая настройка этих компонентов

---

## Обзор стэнда

- vagrant ssh zabbix
- vagrant ssh web
- http://192.168.50.11
- пропишем в /etc/hosts
    - `192.168.50.11 zabbix.otus.example`
    - `192.168.50.12 wp.otus.example`

- http://zabbix.otus.example
    - Admin/zabbix
- http://192.168.50.12 - создадим свой блог на вордпресс

---

## Обзор конфигов

    - zabbix
    ```bash
    more /etc/zabbix/zabbix_server.conf 
    more /etc/zabbix/zabbix_agentd.conf 
    ```

---

## Обнаружение хостов

- устанавливаем на хосты zabbix-agent
  - открываем порт 10050
  - прописываем параметр Server
- рекомендуется завести ansible плейбук для раскатки агента на новые хосты
- добавляем правило обнаружения в Configuration -> Discovery
- включаем или добавляем действие с типом Discovery Actions в Configuration -> Actions

---

## Практика: обнаружение хоста

- установим zabbix-agent на web
    - `ansible-playbook -l web -i /otus/otus.inv zabbix-agent.yml`
- настроим Action, активируем его
- настроим Discovery, активируем, выставим диапазон 192.168.50.12-15
- проверим Monitoring -> Discovery
- проверим Configuration -> Hosts

---

## Actions

![tran](/assets/Pochta_Linux/actions.png)<!-- .element: width="100%" -->

---

## Discovery

![tran](/assets/Pochta_Linux/discovery.png)<!-- .element: width="60%" -->

---

## Zabbix хосты и группы

* Старайтесь группировать хосты по типам и задачам (хост может быть
включен в любое кол-во групп)
* Давать понятные имена для хостов
* Впоследствии разделение прав на просмотр и управление
* Host -  это логическое понятие
  * один физический хост может содержаться в разных Zabbix Hosts
* Имя хоста регистрозависимое (для zabbix_sender)

---

## Макросы

* По сути являются переменными 
* синтаксис `{$MACRO}`
* Задаются на уровнях: 
    - [глобальном](http://zabbix.otus.example/zabbix.php?action=macros.edit)
    - [шаблона](http://zabbix.otus.example/templates.php?form=update&templateid=10001)
    - [хоста](http://zabbix.otus.example/hosts.php?form=update&hostid=10398) 
* Позволяют сделать шаблоны более гибкими и сделать настройку более прозрачной 
* [Макросы](https://www.zabbix.com/documentation/current/ru/manual/config/macros)

---

## Шаблоны

- набор преднастроенных сущностей, который можно применить к нескольким хостам
    - Application: группы элементов данных (items)
    - Items: метрики
    - Графики 
    - Экраны (screens)
    - Триггеры: события возникающие при наступлении определенных условий на конкретных метриках
    - Правила обнаружения элементов (LLD)

---

## Items

- Элементы данных, собираемых с хостов
    - отображаемое имя
    - ключ метрики
    - тип сбора данных: agent, snmp, jmx ...
    - единица измерения
    - интервал сбора данных
    - период хранения истории

---

## Примеры метрик

Основные метрики системы:
* LoadAvg, CPU, Net (bps/pps), DISK Load
* потребление Mem/DISK
* “чистота” системных логов: dmesg, messages
* Актуальность состояния резервных копий

---

## Примеры метрик

Метрики процесса
* Наличие процесса и правильное количество этих процессов
* Открытый сокет/порт процесса
* возможность получить статус процесса (где применимо)
* некоторые параметры статуса

---

## Примеры метрик
Метрики сервиса
* “диагностический запрос”, который задействует все или большинство
компонентов системы.
* время отклика/обработки запроса
* количество обращений в единицу времени
* количество одновременных обращений

---

## Zabbix Триггеры

* Понятное имя триггера
* Устанавливайте важность триггера
* Синтаксис:
** {host:key.function(param)}=0
** vm.memory.size[available].last(0)}<20M
* Тестируйте триггеры (встроенная функция в Zabbix)

---

## Zabbix оповещения

* Mail
* SMS
* SIP
* Jabber
* Slack
* Telegram
* Discord

---

## Рассмотрим элементы данных обнаруженного хоста

- Configuration -> Hosts -> 192.168.50.12
    - проанализируем items
    - проанализируем triggers
- Проверим собранные данные
    - Monitoring -> Latest data
    - Посмотрим графики по нескольким метрикам

---

## Построим screen по системным метрикам

![tran](/assets/Pochta_Linux/screen.png)<!-- .element: width="100%" -->

---
## Практическая работа: подключение шаблонов

- найдем шаблоны для вебсервера Apache
    - Apache by HTTP
    - Apache by Zabbix agent
- подключим эти шаблоны по очереди к нашему хосту
- проверим получение данных

---

## Подключим мониторинг базы данных

- https://git.zabbix.com/projects/ZBX/repos/zabbix/browse/templates/db/mysql_agent
- mysql -p

```sql
mysql> CREATE USER 'zbx_monitor'@'%' IDENTIFIED BY 'myNew20Otus21';
Query OK, 0 rows affected (0.00 sec)

mysql> GRANT REPLICATION CLIENT,PROCESS,SHOW DATABASES,SHOW VIEW ON *.* TO 'zbx_monitor'@'%';
Query OK, 0 rows affected (0.01 sec)

```
---

## Настроим агента

```bash
cd /etc/zabbix/zabbix_agentd.d
wget https://git.zabbix.com/projects/ZBX/repos/zabbix/raw/templates/db/mysql_agent/template_db_mysql.conf?at=refs%2Fheads%2Fmaster -O template_db_mysql.conf

mkdir /var/lib/zabbix/
chown zabbix:zabbix /var/lib/zabbix/

cat <<EOF >> /var/lib/zabbix/.my.cnf
[client]
user='zbx_monitor'
password='myNew20Otus21'
EOF

systemctl restart zabbix-agent
```

---

# Добавим темплейт и проверим результат

---

## Проверим работу триггеров 

- остановка веб сервера
- остановка mysql

---

## LLD - низкоуровневое обнаружение

- возможность создания пользовательских правил и шаблонов для обнаружения различных компонентов для мониторинга на конечной системе:
  - дисков, файловых систем, сетевых интерфейсов
  - таблиц  SQL
  - бизнес метрик на основе выборки из SQL
  - любых других шаблонных метрик, получение которых можно реализовать через скрипт

---

## LLD компоненты

- Правило низкоуровневого обнаружения 
- Прототипы элементов данных 
- Прототипы триггеров
- Прототипы графиков
- Прототипы узлов сети

---

## Создание прототипов

- Правила LLD возвращают данные в макросах:
  - Файловые системы: {#FSNAME}, {#FSTYPE}
  - Интерфейсы: {#IFNAME}
  - SNMP: {#SNMPINDEX}, {#SNMPVALUE}, ...

- Пример ключа:
  - vfs.fs.size[{#FSNAME},free]
- Макросы LLD могут быть использованы в выражениях триггеров 
  - ```{vfs.fs.size[{#FSNAME},pused].last(0)} > {#MY_CUSTOM_MACRO}```

---
## Пользовательский LLD
- [пример сбора метрик с дисковой полки](https://otus.ru/nest/post/13/)
- пример JSON для отправки пользователем
  - {"data": [{"{#NODE}": "m11266"}]}
- отправляется через zabbix_sender

---

## zabbix-sender

- консольная утилита для отправки значений метрик
- отправляет в элементы с типом Zabbix Trapper

```bash
-c, --config config-file  
-s, --host host
# имя хоста в Zabbix (регистрозависимое)
-k, --key key
# ключ, название метрик
-o, --value value
# значение метрики или JSON для LLD
-i, --input-file input-file
# входной файл с данными для отправки пакета метрик
```

---

![tran](/assets/otus_your_questions.png)<!-- .element: width="100%" --> 

---

![tran](/assets/otus_feedback.png)<!-- .element: width="100%" -->
