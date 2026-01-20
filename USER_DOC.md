# User Documentation

## Overview
This document explains how to use and administer the Inception project as an end user or system administrator. It describes the provided services, how to manage the stack lifecycle, how to access the application, and how to verify that everything is running correctly.

## What the stack provides
- **Nginx** serving WordPress over HTTPS on port 443.
- **WordPress (PHP-FPM)** to render the site and admin dashboard.
- **MariaDB** to store WordPress content and user data.
- **Persistent data** stored on the host: `/home/thfranco/data/wordpress` (site files/uploads) and `/home/thfranco/data/mariadb` (database files).

## Start and stop the project
- **Start Containers** <br>
    - To build images (if not already build) and start the stack 
        ```sh
        make build
        ```
    - To start all services
        ```sh
        make up
        ```
- **Stop Containers**: 
    - To stop conainers without removing them
        ```sh
        make stop
        ```
    - To stop and remove containers:
        ```sh
        make down
        ```

## Accessing the site and admin panel
- **Website Access**:<br>
    Once the container is running, access the WordPress site via:
    https://thfranco.42.fr
     
    A self-signed TLS certificate is used. Your browser may display a security warning; this is expected and can be safely bypassed in a local environment.
- **WordPress Admin Panel**:<br>
    The Wordpress admin panel is available at:
    https://thfranco.42.fr/wp-admin

  Log in using the Admin  credentials defined in the `.env` file:
    - `WP_ADMIN_USER`
    - `WP_ADMIN_PASS`
  

## Credentials Management
All credentials are stored in a `.env` file located at the root of the repository. This file is read by Docker Compose when starting the services.
- Database credentials( `MYSQL_ROOT_PASSWORD`, `MYSQL_DATABASE`, `MYSQL_USER`, `MYSQL_PASSWORD`)
- WordPress configuration and admin credentials.
- To rotate credentials, update `.env`, then `make re` to recreate containers with new values.

## Verifying Services Status

**Checking Running Containers**

- To list all containers and their status: 
    ```sh
    make ps 
    ```
    All services should be in a running or healthy state.

**View Logs**

- To inspect logs for troubleshooting:
    ```sh
    make logs
    ```
    Can be used to verify:
    - Nginx successfully started and is listening on port `443`.
    - WordPress connected to the database.
    - MariaDB initialized correctly.

**Health Checks**

The WordPress (PHP-FPM) container includes a health check. Nginx will only start once PHP-FPM is reported as healthy, ensuring correct startup order.
 `docker compose -f srcs/docker-compose.yml ps --format json | jq '.[].Health'` (expect `healthy`).
- Nginx reachability: open https://thfranco.42.fr in a browser.

## Data Persistence

Project data is stored on the host machine to ensure it persists across container restarts and rebuilds:

- **WordPress files**: `/home/thfranco/data/wordpress`

- **MariaDB data**: `/home/thfranco/data/mariadb`

Deleting containers will not remove this data. To fully reset the project, volumes and host data must be removed explicitly.

## Troubleshooting
- Nothing on https://thfranco.42.fr: ensure `nginx` container is up and `wordpress` is healthy.
- Permission errors on data: confirm `/home/thaismeneses/data/` exists and is writable by Docker.
- Changed credentials not applied: `make re` after updating `.env`.
