FROM debian:12.11

RUN apt update && apt install -y \
    php \
    php-fpm \
    php-mysql \
    php-cli \
    php-curl \
    php-mbstring \
    php-xml \
    php-zip \
    wget \
    curl \
    tar \
    mariadb-client \
        && rm -rf /var/lib/apt/lists/*

# Ensure a generic `php-fpm` binary exists (some Debian packages install versioned binary)
RUN target=$(ls /usr/sbin/php-fpm* 2>/dev/null | head -n1) && \
        if [ -n "$target" ] && [ -x "$target" ]; then \
            ln -sf "$target" /usr/sbin/php-fpm; \
        fi

# Configurar PHP-FPM para escutar em TCP 0.0.0.0:9000 (acessível pelo nginx)
RUN sed -i 's|^listen = .*|listen = 9000|' /etc/php/8.2/fpm/pool.d/www.conf && \
    mkdir -p /run/php


# Instala WP-CLI
RUN curl -o /usr/local/bin/wp https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp

RUN mkdir -p /var/www/wordpress \
    && chown -R www-data:www-data /var/www/wordpress

WORKDIR /var/www/wordpress

COPY tools/wp-setup.sh /usr/local/bin/wp-setup.sh
RUN chmod +x /usr/local/bin/wp-setup.sh

ENTRYPOINT ["/usr/local/bin/wp-setup.sh"]