<p>
  <a href="http://opencms.org/" alt="OpenCms">
    <img src="https://www.alkacon.com/export/shared/web/logos/opencms-logo.svg" alt="OpenCms logo" width="340" height="84">
  </a>
</p>

# Official OpenCms Docker Image

Welcome to the official OpenCms Docker image maintained by [Alkacon](https://github.com/alkacon/).

Here you find a Docker Compose setup with a ready to use OpenCms installation including Jetty and MariaDB.

OpenCms can be used with other databases as described below.

## Available tags

* [latest, 20.0](https://github.com/alkacon/opencms-docker/blob/20.0/image/Dockerfile)
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

Images for older OpenCms versions are also available, see [here](https://github.com/alkacon/opencms-docker/blob/pre_11_images/README.md).

## How to use this image

### Step 1: docker-compose.yml

Save the following *docker-compose.yml* file to your host machine.

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
        image: alkacon/opencms-docker:20.0
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

Change the MariaDB root password `secretDBpassword`.

### Step 2: Persist data

Adjust the following directories for your host system:

* `~/dockermount/opencms-docker-mysql` the directory where all MariaDB data are persisted
* `~/dockermount/opencms-docker-webapps` the Tomcat webapps directory that contains important configurations, caches and indices of OpenCms

Configured in this way, it is possible to upgrade the `opencms` and `mariadb` containers while keeping all your OpenCms and MariaDB data. See the upgrade guide below.

On the other hand, if you like to start with a completely fresh OpenCms installation, do not forget to delete both mounted directories before.

### Step 3: Start OpenCms and MariaDB

Navigate to the folder with the *docker-compose.yml* file and execute `docker-compose up -d`.

Startup will take a while since numerous modules are installed.

You can follow the installation process with `docker-compose logs -f opencms`.

### Step 4: Login to OpenCms

When the containers are set up, you can access OpenCms workplace via `http://localhost/system/login`.

The default account is user name `Admin` with password `admin`.

## Environment variables

In addition to `DB_PASSWD`, the following environment variables are supported:

* `DB_HOST`, the database host name, defaults to `mysql`
* `DB_USER`, the database user, default is `root`
* `DB_PASSWD`, the database password, is not set by default
* `DB_NAME`, the database name, default is `opencms`
* `ADMIN_PASSWD`, the admin password, defaults to `admin`
* `OPENCMS_COMPONENTS`, the OpenCms components to install, default is `workplace,demo`; to not install the demo template use `workplace`
* `JETTY_OPTS`, the Jetty startup options (in addition to predefined options), default is `-Xmx2g`
* `DEBUG`, flag indicating whether to enable verbose debug logging and allowing connections via {docker ip address}:8000, defaults to `false`
* `JSONAPI`, flag indicating whether to enable the JSON API, default is `false`
* `SERVER_URL`, the server URL, default is `http://localhost`

## Upgrade the image

*Before upgrading the image, make sure that you have persisted your OpenCms data and MariaDB data with Docker volumes as described above. Otherwise you will lose your data.*

*When upgrading from an older version of this image, read the image history below at first.*

Enter the target version of the OpenCms image in your docker-compose.yml file.

```
    opencms:
        image: alkacon/opencms-docker:20.0
```

Navigate to the folder with the docker-compose.yml file and execute `docker-compose up -d`.

During startup, the Docker setup will update several modules as well as JAR files and configurations in the `/container/webapps` directory.

You can follow the installation process with `docker compose logs -f opencms`.

*It is recommended to remove the* `/container/webapps/ROOT/WEB-INF/index` *folder after upgrade and do a full Solr reindex.*

## Support for other databases

OpenCms uses a special configuration file called [setup.properties](https://github.com/alkacon/opencms-core/blob/master/src-setup/org/opencms/setup/setup.properties.example) to establish a database connection.

In order to connect to a database other than MariaDB, this image supports connection via a custom *setup.properties* file.

The file must be named `custom-setup.properties` and must be available in the root folder of the docker container.

An example setup for PostgreSQL can be found [here](https://github.com/alkacon/opencms-docker/tree/master/compose/postgres).

For more information on the DB configuration options, see the [OpenCms documentation](https://documentation.opencms.org/opencms-documentation/server-administration/headless-installation/).

Note: when using a custom configuration file, the environment variables `DB_HOST, DB_USER, DB_PASSWD, DB_NAME, OPENCMS_COMPONENTS, SERVER_URL` are ignored.

## Building the image

Since the image is available on Docker Hub, you do not need to build it yourself. If you want to build it anyway, here's how to do it:

Download the [opencms-docker](https://github.com/alkacon/opencms-docker) repository.

Go to the repository's main folder and type `docker compose build opencms`.

## Image History

### OpenCms 17.0

* Switch from **Tomcat** to **Jetty**!
* CHANGE THE MOUNT POINT: `{your mount point}:/usr/local/tomcat/webapps -> {your mount point}:/container/webapps`
* `webapps` folder is now located under `/container/`, before it was `/usr/local/tomcat/`
* Environment variable `GZIP` removed (enabled by default)
* Environment variable `ENABLE_JLAN` removed (JLAN is disabled, use WebDAV instead)
* Support for custom `setup.properties` configuration files

## License

View the [licence information on GitHub](https://github.com/alkacon/opencms-docker/blob/master/LICENSE).
