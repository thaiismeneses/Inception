#!/bin/bash
set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

chown -R mysql:mysql /var/lib/mysql

# Inicializa o banco caso ainda não exista
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Inicializando o diretório do banco..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

echo "Iniciando MariaDB temporário..."
/usr/sbin/mysqld --user=mysql --datadir=/var/lib/mysql --skip-networking &
pid="$!"

echo "Aguardando MariaDB Iniciar..."
until mysqladmin --protocol=socket ping --silent; do
    sleep 1
done


echo "Configurando banco e usuários..."

mysql --protocol=socket -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF


echo "Parando instância temporária..."
kill "$pid"
sleep 2

echo "Iniciando MariaDB definitivo..."
exec /usr/sbin/mysqld --user=mysql --datadir=/var/lib/mysql
