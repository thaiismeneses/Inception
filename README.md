*This project has been created as part of the 42 curriculum by thfranco.*

# INCEPTION

## Description
Inception provisions a secure WordPress infrastructure composed of Nginx, PHP-FPM, and MariaDB, orchestrated with Docker Compose. The objective is to practice infrastructure-as-code principles by isolating services, persisting data through volumes, and exposing the application over HTTPS in a reproducible and self-contained environment.

## Project Description
- **Docker usage:** The project is composed of three custom Docker images, all built from sources located in the srcs/ directory:

    - **Nginx**

    - **WordPress / PHP-FPM**

    - **MariaDB**

    Docker Compose orchestrates these services using:

    - An isolated bridge network

    - Explicit health checks

    - Bind-mounted configuration files for Nginx

    Persistent data is stored on the host under `/home/thfranco/data/`, ensuring durability across container rebuilds.
- **Sources included:**
  - `srcs/nginx`: TLS-terminating reverse proxy serving WordPress over HTTPS.

  - `srcs/wordpress`: PHP-FPM + WordPress setup and initialization tooling.

  - `srcs/mariadb`: MariaDB server with custom config and bootstrap script.

- **Main design choices:**
    - One container per responsibility to reflect production-grade separation of concerns.

    - Host-path bind mounts to ensure data persistence between container rebuilds.

    - Reduced attack surface: only **Nginx** exposes port 443; PHP-FPM remains internal.

    - FPHP-FPM health checks used to control service startup order.
- **Comparisons:**
  - <u>Virtual Machines vs Docker</u>: Virtual Machines emulate full hardware stacks with dedicated guest operating systems, resulting in higher resource usage and slower startup times. Docker containers virtualize at the operating system level, sharing the host kernel while maintaining isolation through namespaces and cgroups, offering faster startup, lower overhead, and easier scalability.

  - <u>Secrets vs Environment Variables</u>: Secrets (e.g., Docker Swarm or Kubernetes secrets) are mounted securely from memory-backed filesystems and limit exposure of sensitive data. Environment variables are simpler to use but can be exposed through process inspection. Credentials should be handled as secrets whenever supported.

  - <u>Docker Network vs Host Network</u>: Docker bridge networks provide container isolation, private IP addressing, and built-in DNS-based service discovery. Host networking shares the host’s network stack, increasing exposure and the risk of port conflicts. This project uses a bridge network to isolate services and expose only Nginx.

  - <u>Docker Volumes vs Bind Mounts</u>: Docker volumes are managed by Docker and offer portability across hosts. Bind mounts map explicit host paths, offering transparency and easy inspection. This project uses bind mounts (`/home/thfranco/data/...`) to simplify debugging and ensure persistent storage.

## Architecture
- **nginx**: Terminates TLS on 443, serves static assets, and proxies PHP requests to `wordpress:9000`.
- **wordpress (php-fpm)**: Runs WordPress under PHP-FPM; uses a shared volume for code and uploads.
- **mariadb**: Provides the WordPress database with data persisted to `/home/thfranco/data/mariadb`.
- **Network**: `inception` bridge isolates services; only Nginx publishes to the host.
- **Volumes**:
    - `/home/thfranco/data/wordpress`  - Wordpress files
    - `/home/thfranco/data/mariadb` - Database data 

## Instructions
### Prerequisites
- Docker and Docker Compose (v2+) installed.
- Make available in the shell.
- `.env` file at the repository root containing WordPress and MariaDB credentials, such as:
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

    Host directories for data: `/home/thfranco/data/mariadb` and `/home/thfranco/data/wordpress` (created automatically by Docker if missing).

### Build and run
```sh
make build   # build images and start containers in detached mode
```
Access the site at https://localhost (accept the self-signed certificate if prompted).

### Common operations
```sh
make up      # start in the foreground
make down    # stop and remove containers
make stop    # stop containers without removing them
make logs    # follow container logs
make ps      # list container status
make clean   # remove containers and orphans
make fclean  # remove containers, volumes, and prune Docker
```

## Resources
- Docker docs: https://docs.docker.com/
- Docker Compose file reference: https://docs.docker.com/compose/compose-file/
- MariaDB docs: https://mariadb.com/kb/en/documentation/
- Nginx docs: https://nginx.org/en/docs/
- WordPress docs: https://wordpress.org/support/
- AI usage: AI was used to assist in creating a study structure for developing this project. It was also used as a source of learning material and research, as well as to support debugging at certain moments. Its main purpose was to organize study topics and outline the general steps required for development.