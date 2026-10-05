<p>
  <a href="http://opencms.org/" alt="OpenCms">
    <img src="https://www.alkacon.com/export/shared/web/logos/opencms-logo.svg" alt="OpenCms logo" width="340" height="84">
  </a>
</p>

# Official OpenCms Docker Image

Welcome to the official OpenCms Docker image maintained by [Alkacon](https://github.com/alkacon/).

This repository provides a Docker Compose setup for a ready-to-use OpenCms installation with Jetty and MariaDB.

## Available tags

* [latest, 22.0](https://github.com/alkacon/opencms-docker/blob/22.0/image/Dockerfile)
* [22.0-legacy](https://github.com/alkacon/opencms-docker/blob/22.0-legacy/image/Dockerfile)
* [21.1](https://github.com/alkacon/opencms-docker/blob/21.1/image/Dockerfile)
* [21.0](https://github.com/alkacon/opencms-docker/blob/21.0/image/Dockerfile)
* [20.1](https://github.com/alkacon/opencms-docker/blob/20.1/image/Dockerfile)
* [20.0](https://github.com/alkacon/opencms-docker/blob/20.0/image/Dockerfile)
* [19.0](https://github.com/alkacon/opencms-docker/blob/19.0/image/Dockerfile)
* [18.0](https://github.com/alkacon/opencms-docker/blob/18.0/image/Dockerfile)
* [17.0](https://github.com/alkacon/opencms-docker/blob/17.0/image/Dockerfile)
* [16.0](https://github.com/alkacon/opencms-docker/blob/16.0/image/Dockerfile)
* [15.0](https://github.com/alkacon/opencms-docker/blob/15.0/image/Dockerfile)
* [14.0](https://github.com/alkacon/opencms-docker/blob/14.0/image/Dockerfile)
* [13.0](https://github.com/alkacon/opencms-docker/blob/13.0/image/Dockerfile)
* [12.0](https://github.com/alkacon/opencms-docker/blob/12.0/image/Dockerfile)
* [11.0.2](https://github.com/alkacon/opencms-docker/blob/11.0.2/image/Dockerfile)
* [11.0.1](https://github.com/alkacon/opencms-docker/blob/11.0.1/image/Dockerfile)
* [11.0.0](https://github.com/alkacon/opencms-docker/blob/11.0.0/image/Dockerfile)

Images for older OpenCms versions are also available. See [older OpenCms Docker images](https://github.com/alkacon/opencms-docker/blob/pre_11_images/README.md).

## OpenCms 22 goes Jakarta

The OpenCms 22 Docker image is available in two variants: a Jakarta EE variant compatible with Jakarta EE, and a legacy variant compatible with Java EE 8.

For a new OpenCms installation, use the Jakarta variant:

`alkacon/opencms-docker:22.0`

For upgrading an existing OpenCms installation that is not yet Jakarta-compatible, use the legacy variant:

`alkacon/opencms-docker:22.0-legacy`

OpenCms 23, planned for April 2027, will support Jakarta EE only. If your OpenCms installation uses the Mercury template or custom modules, OpenCms 22 provides a transition period for migrating to Jakarta EE.

We recommend using this time to upgrade to the Jakarta version of the Mercury template and to verify that your custom modules work with the Jakarta variant. The Mercury template is not upgraded automatically; upgrading it requires manual work.

## How to use this image

### Step 1: Create docker-compose.yml

Save the following `docker-compose.yml` file on your host machine:

```
services:
    mariadb:
        image: mariadb:latest
        container_name: mariadb
        init: true
        restart: always
        volumes:
            - ~/dockermount/opencms-docker-mysql:/var/lib/mysql
        environment:
            - "MYSQL_ROOT_PASSWORD=secretDBpassword"
    opencms:
        image: alkacon/opencms-docker:22.0
        container_name: opencms
        init: true
        restart: always
        depends_on: [ "mariadb" ]
        links:
            - "mariadb:mysql"
        ports:
            - "80:8080"
        volumes:
            - ~/dockermount/opencms-docker-webapps:/container/webapps
        command: ["/root/wait-for.sh", "mysql:3306", "-t", "30", "--", "/root/opencms-run.sh"]
        environment:
            - "DB_PASSWD=secretDBpassword"
```

Replace `secretDBpassword` with your desired MariaDB root password.

### Step 2: Persist data

Adjust the following directories to match your host system:

* `~/dockermount/opencms-docker-mysql` – stores all persistent MariaDB data.
* `~/dockermount/opencms-docker-webapps` – stores the web application directory containing important OpenCms configurations, caches, and indexes.

With these directories mounted, you can upgrade the `opencms` and `mariadb` containers without losing your OpenCms or MariaDB data. See the upgrade instructions below.

If you want to start with a completely fresh OpenCms installation instead, delete both mounted directories before starting the containers.

### Step 3: Start OpenCms and MariaDB

Navigate to the directory containing the `docker-compose.yml` file and run:

`docker compose up -d`

The initial startup may take some time because a number of OpenCms modules need to be installed.

You can follow the installation process with:

`docker compose logs -f opencms`

### Step 4: Log in to OpenCms

Once the containers have been set up, you can access the OpenCms Workplace at:

`http://localhost/system/login`

The default credentials are:

* Username: `Admin`
* Password: `admin`

## Environment variables

In addition to `DB_PASSWD`, the following environment variables are supported:

* `DB_HOST` – database host name; defaults to `mysql`
* `DB_USER` – database user; defaults to `root`
* `DB_PASSWD` – database password; not set by default
* `DB_PASSWD_FILE` – file inside the container containing the database password (`/run/secrets/<secret_name>`); intended for use with Docker Compose `secrets`
* `DB_NAME` – database name; defaults to `opencms`
* `ADMIN_PASSWD` – OpenCms administrator password; defaults to `admin`
* `ADMIN_PASSWD_FILE` – file inside the container containing the administrator password (`/run/secrets/<secret_name>`); intended for use with Docker Compose `secrets`
* `OPENCMS_COMPONENTS` – OpenCms components to install; defaults to `workplace,demo`. To install the Workplace without the demo template, use `workplace`
* `JETTY_OPTS` – additional Jetty startup options; defaults to `-Xmx2g`
* `DEBUG` – enables remote Java debugging on port `8000`; defaults to `false`. Publish the port (for example, `8000:8000`) to connect through the Docker host
* `JSONAPI` – enables the JSON API; defaults to `false`
* `SERVER_URL` – server URL; defaults to `http://localhost`

`DB_PASSWD` and `DB_PASSWD_FILE` are alternative ways of specifying the database password. Likewise, `ADMIN_PASSWD` and `ADMIN_PASSWD_FILE` are alternatives for specifying the OpenCms administrator password.

For more information, see the [Docker Compose documentation on secrets](https://docs.docker.com/compose/how-tos/use-secrets/).

## Upgrading the image

**Before upgrading the image, make sure that your OpenCms and MariaDB data are persisted using Docker volumes as described above. Otherwise, your data will be lost.**

Set the desired OpenCms image version in your `docker-compose.yml` file.

If you plan to upgrade the Mercury template to the Jakarta version, or if your custom modules are already Jakarta-compatible, use:

```
    opencms:
        image: alkacon/opencms-docker:22.0
```

If you do not plan to upgrade the Mercury template yet, or if your installation contains custom modules that still depend on `javax`, use the legacy variant:

```
    opencms:
        image: alkacon/opencms-docker:22.0-legacy
```

The Docker image does not automatically upgrade the Mercury template and does not modify custom modules. Upgrading Mercury and adapting custom modules for Jakarta EE requires manual work.

Navigate to the directory containing the `docker-compose.yml` file and run:

`docker compose up -d`

During startup, the Docker setup updates several OpenCms modules as well as JAR files and configuration files in the `/container/webapps` directory.

You can follow the upgrade process with:

`docker compose logs -f opencms`

**After upgrading, we recommend deleting the `/container/webapps/ROOT/WEB-INF/index` directory and performing a full Solr reindex.**

## Demo projects

Additional examples for specific deployment scenarios are available in the [`compose`](compose) directory:

* [`compose/postgres`](compose/postgres) demonstrates how to use PostgreSQL instead of MariaDB.
* [`compose/build-tomcat`](compose/build-tomcat) demonstrates how to build the OpenCms image with Tomcat instead of Jetty.
* [`compose/service-stack`](compose/service-stack) demonstrates a service-stack deployment using RustFS, NGINX, and Solr.

## Building the image

The official image is available on Docker Hub, so normally there is no need to build it yourself.

If you want to build the image locally, clone or download the [opencms-docker](https://github.com/alkacon/opencms-docker) repository.

Navigate to the repository's root directory and run:

`docker compose build opencms`

## License

See the [license information on GitHub](https://github.com/alkacon/opencms-docker/blob/main/LICENSE).