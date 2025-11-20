#!/bin/bash

service mariadb start

sleep 5

mysql -e "CREATE DATA IF NOT EXISTS ${MYSQL_DATABASE};"

mysql -e "CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

mysql -e "GRANT ALL PRIVILAGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';"

mysql -e "FLUSH PRIVILEGES;"

mysqladmin shutdown 

exec mysqld_safe