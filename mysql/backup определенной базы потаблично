#!/bin/bush

#echo "Enter mysql root password for mysqldump:"
#read -s pass 
USER='root'
PASS='Testpass1$'
date=$( date +"-%u" )
db=wpdb

echo "STOP SLAVE;" | mysql -u$USER -p$PASS

MYSQL=$"mysql -u$USER -p$PASS  --skip-column-names"

for s in $db `$MYSQL -e "SHOW DATABASES LIKE '%\_db'"`;
        do
	mkdir /root/mysql-s/backup/$db$date;
        for t in `$MYSQL -e "SHOW TABLES FROM $s"`;
        	do
        	echo "--> $t dumping... ";		
        	/usr/bin/mysqldump -u$USER -p$PASS --source-data=2 --add-drop-table --add-locks --create-options --disable-keys --extended-insert --single-transaction --quick --set-charset --events --routines --triggers $s $t | gzip -1 > /root/mysql-s/backup/$db$date/$t.gz;

	done

done

echo "START SLAVE;" | mysql -u$USER -p$PASS

#echo "MySQL dump-files will be sent to mysql-master!"
#scp -r /root/mysql-s/wpdb root@192.168.0.111:/root/mysql-m/
