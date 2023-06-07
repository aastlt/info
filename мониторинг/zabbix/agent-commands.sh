wget https://repo.zabbix.com/zabbix/6.4/ubuntu/pool/main/z/zabbix-release/zabbix-release_6.4-1+ubuntu22.04_all.deb
dpkg -i zabbix-release_6.4-1+ubuntu22.04_all.deb
apt update

apt install zabbix-agent

systemctl restart zabbix-agent
systemctl enable zabbix-agent

#Настройка /etc/zabbix/zabbix_agentd.conf
nano /etc/zabbix/zabbix_agentd.conf
> Server=ip-zabbix-server
> Hostname=host-name-zabbix.server
 
systemctl restart zabbix-agent
