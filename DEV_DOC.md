# Developer Documentation


## Overview
This document is intended for developers who want to understand, build, and maintain the Inception project. It explains how to set up the environment from scratch, build and run the infrastructure using Docker and Make, manage containers and volumes, and understand where and how data persists.
## Environment Setup

**System Requirements**

- Linux-based operating system (native or virtual machine)

- Docker (Docker Engine)

- Docker Compose (v2+)

- GNU Make

This project is designed to run inside a Linux VM, as required by the 42 subject.

## Project Structure

```
.
├── Makefile
├── .gitignore
├── .env # Not versioned
├── srcs/
│ ├── docker-compose.yml
│ ├── nginx/
│ │ ├── Dockerfile
│ │ └── conf/
│ ├── wordpress/
│ │ ├── Dockerfile
│ │ └── tools/
│ └── mariadb/
|   ├── Dockerfile
│   ├── conf/
│   └── tools/
├── USER_DOC.md
├── DEV_DOC.md
└── README.md

```

## Configuration and Secrets

**Environment Variables**

Configuration is handled via a .env file at the repository root. Docker Compose automatically loads this file when starting the stack.

Required variables include:
  - `MYSQL_ROOT_PASSWORD`
  - `MYSQL_DATABASE`
  - `MYSQL_USER`
  - `MYSQL_PASSWORD`
  - `MYSQL_HOST`
  - `MYSQL_PORT`
  - `DOMAIN_NAME`
  - `WP_ADMIN_USER`
  - `WP_ADMIN_PASSWORD`
  - `WP_ADMIN_EMAIL`

The .env file must never be committed to version control.

Ensure host directories exist or can be created: `/home/thfranco/data/mariadb` and `/home/thfranco/data/wordpress`.

## Setting up from scratch
1. Clone the repository.
2. Create and fill `.env` with the variables above.
3. (Optional) Inspect configuration under `srcs/*` for custom behavior (Nginx config, MariaDB init script, WordPress setup script).

## Build and Launch Process

**Build Images and Start Containers**
```sh
make build
```
This command:

- Builds all custom images defined in srcs/

- Starts containers in detached mode

- Creates networks and volumes if needed

**Start Containers (Already built)**
```sh
make up
```

**Stop Without Removing containers**

```sh
make stop
```

**Stop and Remove Containers**
```sh
make down
```
**Remove Containers and Orphaned Resources**
```sh
make clean
```

**Full Reset (containers + volumes + prune)**
```sh
make fclean
```
Permanently deletes persisted data

**Full Reset and Build**
```sh
make re
```


## Container and Volume Management
**Inspect Running Containers**
```sh
make ps
```
**View Logs**
```sh
make logs
```
Logs are essential for debugging startup order, database initialization, and TLS configuration issues.


**Exec into a container**
```sh
docker exec -it <container> /bin/sh
```

**List Docker volumes**
```sh
docker volume ls
```

## Data storage and persistence
WordPress code/uploads: `/home/thfranco/data/wordpress`

MariaDB data files: `/home/thfranco/data/mariadb`

These are bind mounts, so rebuilding containers preserves site data and the database. To start fresh, delete these host directories (or use `make fclean` then manually remove them).

## Service Initialization Flow
1. Docker Compose creates the inception bridge network.

2. MariaDB container starts and initializes the database if data is absent.

3. WordPress (PHP-FPM) starts and waits for the database to be available.

4. PHP-FPM health check reports healthy status.

5. Nginx starts and begins serving HTTPS traffic.

This flow ensures reliable startup order and prevents race conditions.

## Relevant Compose details
- Network: `inception` bridge isolates services; only Nginx publishes port 443.
- Health check: WordPress container is probed on port 9000 before Nginx proxies traffic.
- Nginx config bind-mounted from `srcs/nginx/conf/nginx.conf`.
- WordPress and Nginx share the WordPress bind mount to serve the same files.

## Debugging Tips

- Use `docker compose logs <service>` to inspect a specific container.

- Verify environment variables inside containers with docker inspect if needed.

- Ensure port `443` is not already in use on the host.

- Check file permissions on `/home/thfranco/data` if persistence issues occur.
