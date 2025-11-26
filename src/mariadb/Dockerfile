FROM debian:12.11


# Update system and install mariaDB
RUN apt update && apt install -y mariadb-server

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

COPY tools/mariadb.sh /usr/local/bin/mariadb.sh
RUN chmod +x /usr/local/bin/mariadb.sh

# MariaDB Port
EXPOSE 3306

ENTRYPOINT ["/usr/local/bin/mariadb.sh"]