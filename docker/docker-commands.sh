# Установка Docker

yum install -y yum-utils
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
    
yum install docker-ce docker-ce-cli containerd.io

systemctl start docker

# Проверим статус
systemctl status docker

systemctl stop firewalld

# Список доступных команд
docker

# Информацию о Docker
sudo docker info

# Запустим тестовый контейнер
sudo docker run hello-world

# Поищем nginx
sudo docker search nginx

# Скачаем образ
sudo docker pull nginx

# Запустим контейнер
sudo docker run -d --name nginx -p 80:80 -v /var/www/html:/usr/share/nginx/html nginx

# Список активных контейнеров
sudo docker ps

# Чтобы увидеть и активные, и неактивные контейнеры
sudo docker ps -a

# Зайдём в оболочку контейнера
sudo docker exec -ti nginx bash

# Остановка и запуск контейнеров
sudo docker stop sharp_volhard
sudo docker start d9b100f2f636

# Перезагрузка
sudo docker restart nginx

# Отправка сигнала
sudo docker kill -s HUP nginx

# Логи контейнера
sudo docker logs nginx

# Информация о контейнере
sudo docker inspect nginx

# Публичные порты
sudo docker port nginx

# Выполняющиеся процессы
sudo docker top nginx

# Использование ресурсов
sudo docker stats nginx

# Список образов
sudo docker images

# Просмотр истории образа
sudo docker history nginx

# Удаление контейнера
sudo docker rm nginx

# Удаление образа
sudo docker rmi nginx

# Сети
docker network create mynet
docker network ls # просмотр сетей
docker run -d --name nginx2 --network=mynet -p 80:80 nginx # внутри созданной сети
docker run -d --name nginx2 --network=host nginx # внутри хостовой сети 


# Установка нескольких контейнеров, соединённых сетью
docker network create some-network

docker run --rm --network some-network --name some-mariadb -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mariadb:10.5
docker run -it --network some-network --rm mariadb:10.5 mysql -hsome-mariadb -uroot -p

docker run --name myadmin -d --network some-network --link some-mariadb:db -p 8080:80 phpmyadmin

# Установка контейнеров для работы WordPress с помощью docker-compose

https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-with-docker-compose-ru

# Дополнительные команды по обслуживанию
docker system df
docker system prune
docker system info


# Dockerfile
FROM nginx:latest
COPY ./index.html /usr/share/nginx/html/index.html

docker build -t webserver .



