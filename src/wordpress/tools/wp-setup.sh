#!/bin/bash

set -e

WP_PATH="/var/www/wordpress"

mkdir -p "$WP_PATH"
chown -R www-data:www-data "$WP_PATH"

# Download WordPress (se não existir)
if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Baixando WordPress..."
    wget -q https://wordpress.org/latest.tar.gz -O /tmp/wp.tar.gz
    tar -xzf /tmp/wp.tar.gz -C /tmp
    cp -r /tmp/wordpress/* "$WP_PATH/"
    chown -R www-data:www-data "$WP_PATH"
fi

# Configurando o wp-config.php 
if [ ! -f "$WP_PATH/wp-config.php" ]; then  
    echo "Configurando o wp-config.php..."
    cp "$WP_PATH/wp-config-sample.php" "$WP_PATH/wp-config.php"

    sed -i "s/database_name_here/${MYSQL_DATABASE}/" "$WP_PATH/wp-config.php"
    sed -i "s/username_here/${MYSQL_USER}/" "$WP_PATH/wp-config.php"
    sed -i "s/password_here/${MYSQL_PASSWORD}/" "$WP_PATH/wp-config.php"
    echo "Conenctando no banco em host: $MYSQL_HOST"
    sed -i "s/localhost/${MYSQL_HOST}/" "$WP_PATH/wp-config.php"
fi

# Espera o banco aceitar conexões TCP (evita race condition entre containers)
max_wait=60
count=0
until mysqladmin ping -u"${MYSQL_USER}" -p"${MYSQL_PASSWORD}" -h"${MYSQL_HOST}" -P"${MYSQL_PORT}" --silent; do
    count=$((count+1))
    if [ "$count" -ge "$max_wait" ]; then
        echo "Erro: banco não respondeu em ${MYSQL_HOST}:${MYSQL_PORT} após ${max_wait}s" >&2
        exit 1
    fi
    sleep 1
done

# Instalndo o WordPress (se não instalado)
if ! wp --path="$WP_PATH" core is-installed --allow-root >/dev/null 2>&1; then
    echo "Instalando WordPress..."

    wp core install \
        --path="$WP_PATH" \
        --url="${DOMAIN_NAME}" \
        --title="Inception" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASS}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --allow-root
fi

echo "Iniciando PHP-FPM..."
# Exec php-fpm by absolute path to avoid PATH differences between environments
if [ -x "/usr/sbin/php-fpm" ]; then
    exec /usr/sbin/php-fpm -F
else
    exec php-fpm -F
fi
