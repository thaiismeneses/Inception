#!/bin/bash
set -e

SOCKET="/run/mysqld/mysqld.sock"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

unset MYSQL_HOST MYSQL_PORT

# Se o banco já existe, sobe direto
if [ -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "📂 Banco já existe, subindo MariaDB normalmente..."
    exec mariadbd --user=mysql --socket=$SOCKET
fi

echo "📦 Inicializando banco de dados MariaDB..."
mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null

echo "🚀 Iniciando MariaDB temporário..."
mariadbd --user=mysql --skip-networking --socket=$SOCKET &
pid="$!"

until mysqladmin --protocol=socket --socket=$SOCKET ping --silent; do
    sleep 1
done

echo "⚙️ Configurando banco e usuários..."
mysql --protocol=socket --socket=$SOCKET -u root << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';

CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';

GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

FLUSH PRIVILEGES;
EOF

echo "🛑 Parando MariaDB temporário..."
mysqladmin --protocol=socket --socket=$SOCKET -uroot -p"${MYSQL_ROOT_PASSWORD}" shutdown

echo "✅ Iniciando MariaDB definitivo..."
exec mariadbd --user=mysql --socket=$SOCKET
