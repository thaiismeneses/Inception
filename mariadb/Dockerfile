FROM debian:12.11


# Update system and install mariaDB
RUN apt update && apt install -y mariadb-server

COPY tools/mariadb.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/mariadb.sh

# MariaDB Port
EXPOSE 3306

CMD ["mysqld"]