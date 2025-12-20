#!/bin/bash
set -e

SOCKET="/run/mysqld/mysqld.sock"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

chown -R mysql:mysql /var/lib/mysql

# Avoid client picking up MYSQL_HOST/MYSQL_PORT from environment
unset MYSQL_HOST MYSQL_PORT

# Inicializa o banco caso ainda não exista
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Inicializando base de dados..."
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

echo "Iniciando MariaDB temporário..."
mariadbd --user=mysql --datadir=/var/lib/mysql --skip-networking --socket=$SOCKET &
pid="$!"

echo "Aguardando MariaDB iniciar..."
until mysqladmin --protocol=socket --socket=$SOCKET ping --silent; do
    sleep 1
done

echo "Configurando banco e usuários..."
mysql --protocol=socket --socket=$SOCKET -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

echo "Parando instância temporária..."
kill "$pid"
wait "$pid"

echo "Iniciando MariaDB definitivo..."
exec mariadbd --user=mysql --datadir=/var/lib/mysql --socket=$SOCKET