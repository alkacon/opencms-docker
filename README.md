<p>
  <a href="http://opencms.org/" alt="OpenCms">
    <img src="https://www.alkacon.com/export/shared/web/logos/opencms-logo.svg" alt="OpenCms logo" width="340" height="84">
  </a>
</p>

# Official OpenCms Docker Image

Welcome to the official OpenCms Docker image maintained by [Alkacon](https://github.com/alkacon/).

Here you find a Docker Compose setup with a ready to use OpenCms installation including Tomcat and MariaDB.

OpenCms can be used with other databases and Servlet containers as described in the [OpenCms documentation](https://documentation.opencms.org).

## Available tags

* [latest, 16.0](https://github.com/alkacon/opencms-docker/blob/16.0/image/Dockerfile)
* [15.0](https://github.com/alkacon/opencms-docker/blob/15.0/image/Dockerfile)
* [14.0](https://github.com/alkacon/opencms-docker/blob/14.0/image/Dockerfile)
* [13.0](https://github.com/alkacon/opencms-docker/blob/13.0/image/Dockerfile)
* [12.0](https://github.com/alkacon/opencms-docker/blob/12.0/image/Dockerfile)
* [11.0.2](https://github.com/alkacon/opencms-docker/blob/11.0.2/image/Dockerfile)
* [11.0.1](https://github.com/alkacon/opencms-docker/blob/11.0.1/image/Dockerfile)
* [11.0.0](https://github.com/alkacon/opencms-docker/blob/11.0.0/image/Dockerfile)

Images for older OpenCms versions are also available, see [here](https://github.com/alkacon/opencms-docker/blob/pre_11_images/README.md).

## How to use this image

### Step 1: docker-compose.yml

Save the following docker-compose.yml file to your host machine.

```yaml
services:
    mariadb:
        image: mariadb:latest
        container_name: mariadb
        restart: always
        volumes:
            - ~/dockermount/opencms-docker-mysql:/var/lib/mysql
        environment:
            - MYSQL_ROOT_PASSWORD=secretDBpassword
            - TZ=Europe/Berlin

    opencms:
        image: alkacon/opencms-docker:16.0
        container_name: opencms
        build: ./image
        restart: always
        depends_on:
            - mariadb
        links:
            - mariadb:mysql
        ports:
            - 80:8080
        volumes:
            - ~/dockermount/opencms-docker-webapps:/usr/local/tomcat/webapps
        command: /root/wait-for.sh -t 30 -- /root/opencms-run.sh
        environment:
            - DB_PASSWD=secretDBpassword
            - TZ=Europe/Berlin
```

Change the MariaDB root password `secretDBpassword`.

Other example with PostgreSQL: [docker-compose-pgsql.yml](https://github.com/alkacon/opencms-docker/blob/master/docker-compose-pgsql.yml)

### Step 2: Persist data

Adjust the following directories for your host system:

* `~/dockermount/opencms-docker-mysql` the directory where all MariaDB data are persisted
* `~/dockermount/opencms-docker-webapps` the Tomcat webapps directory that contains important configurations, caches and indices of OpenCms

Configured in this way, it is possible to upgrade the `opencms` and `mariadb` containers while keeping all your OpenCms and MariaDB data. See the upgrade guide below.

On the other hand, if you like to start with a completely fresh OpenCms installation, do not forget to delete both mounted directories before.

### Step 3: Start OpenCms and MariaDB

Navigate to the folder with the docker-compose.yml file and execute `docker-compose up -d`.

Startup will take a while since numerous modules are installed.

You can follow the installation process with `docker-compose logs -f opencms`.

### Step 4: Login to OpenCms

When the containers are set up, you can access OpenCms via `http://localhost/system/login`.

The default account is user name `Admin` with password `admin`.

## Environment variables

In addition to `DB_PASSWD`, the following Docker Compose environment variables are honored:

* `DB_PRODUCT`, type of the database, `mysql` or `postgresql`, defaults to `mysql`
* `DB_HOST`, the database host name, defaults to `mysql`
* `DB_PORT`, the database port number, defaults to `3306`
* `DB_USER`, the database user, default is `root`
* `DB_PASSWD`, the database password, is not set by default
* `DB_NAME`, the database name, default is `opencms`
* `ADMIN_PASSWD`, the admin password, defaults to `admin`
* `OPENCMS_COMPONENTS`, the OpenCms components to install, default is `workplace,demo`; to not install the demo template use `workplace`
* `TOMCAT_OPTS`, the Tomcat startup options, default is `-Xmx1g -Xms512m -server -XX:+UseConcMarkSweepGC`
* `WEBRESOURCES_CACHE_SIZE`, the size of tomcat's resources cache, default is `200000` (200MB)
* `DEBUG`, flag indicating whether to enable verbose debug logging and allowing connections via {docker ip address}:8000, defaults to `false`
* `JSONAPI`, flag indicating whether to enable the JSON API, default is `false`
* `SERVER_URL`, the server URL, default is `http://localhost`
* `TZ`, time zone identifier, defaults to `UTC`

## Upgrade the image

If you have installed OpenCms 15.0 and want to upgrade to OpenCms 16.0, proceed as follows:

Enter the target version of the OpenCms image in your docker-compose.yml file.

```
    opencms:
        image: alkacon/opencms-docker:16.0
```

Make sure that you have persisted your OpenCms data and MariaDB data with a Docker mount as described above. Otherwise you will loose your data.

Navigate to the folder with the docker-compose.yml file and execute `docker-compose up -d`.

During startup, the Docker setup will update several modules as well as JAR files and configurations in the `{CATALINA_HOME}/webapps` directory.

You can follow the installation process with `docker-compose logs -f opencms`.

## Building the image

Since the image is available on Docker Hub, you do not need to build it yourself. If you want to build it anyway, here's how to do it:

Download the [opencms-docker](https://github.com/alkacon/opencms-docker) repository.

Go to the repository's main folder and type `docker-compose build opencms`.

## License

View the [licence information on GitHub](https://github.com/alkacon/opencms-docker/blob/master/LICENSE).
