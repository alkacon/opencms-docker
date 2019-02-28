opencms-docker
==============
## Official docker support for OpenCms ##

These official docker images contain OpenCms with the demo application.
This is a basic OpenCms installation that includes mySQL and Tomcat.
OpenCms has been installed like that for ages, and it just works.
The images are well suited for quick evaluation and test purposes of the latest OpenCms release.

From OpenCms 11 onwards an improved version of images will be provided, separating database and OpenCms installation and allowing for updates. See below for details.

## Preview to improved image running OpenCms 11.x ##

For the upcoming version of OpenCms 11 Alkacon Software provides a new style of docker image. Using an external (mysql/mariadb) database it will allow easy OpenCms core updates, whenever a new OpenCms version is released.

The image alkacon/opencms-docker:11.0.0-beta-2 provides a preview to this new image style.

### Running the alkacon/opencms-docker:11.0.0-beta-2 image ###

The easiest way to run this image is to use docker-compose. See the docker-compose.yaml below.

```
version: '2.2'
services:
    mariadb:
        image: mariadb:latest
        container_name: mariadb
        init: true
        restart: always
        volumes:
            - /my-mysql-data-dir:/var/lib/mysql
        environment:
            - "MYSQL_ROOT_PASSWORD=secretDBpassword"

    opencms:
        image: alkacon/opencms-docker:11.0.0-beta-2
        container_name: opencms
        init: true
        restart: always
        depends_on: [ "mariadb" ]
        links:
            - "mariadb:mysql"
        ports:
            - "80:8080"
        volumes:
            - /my-tomcat-webapps-dir:/usr/local/tomcat/webapps
        command: ["/root/wait-for.sh", "mysql:3306", "-t", "30", "--", "/root/opencms-run.sh"] # waiting for the mysql container to be ready
        environment:
             - "DB_PASSWD=secretDBpassword" # DB password, same as MYSQL_ROOT_PASSWORD of the mysql/mariadb container
 #           - "TOMCAT_OPTS=-Xmx2g -Xms512m -server -XX:+UseConcMarkSweepGC"
 #           - "ADMIN_PASSWD=admin" # individual Admin password
 #           - "DB_HOST=mysql_hostname"
 #           - "DB_USER=root"
 #           - "DB_NAME=opencms_db_name"
 #           - "OPENCMS_COMPONENTS=workplace,demo"
 #           - "WEBRESOURCES_CACHE_SIZE=200000"
```
You can save this file as 'docker-compose.yaml' and adjust the directories '/my-mysql-data-dir' and '/my-tomcat-webapps-dir' to suitable folders on your host system.
Navigate to the folder containing the file 'docker-compose.yaml' and execute `docker-compose up -d`. You can view the log of the OpenCms container with `docker logs -f opencms`.

This will start one mariadb/mysql container, using the data directory '/my-mysql-data-dir' on the host system. The second container is the OpenCms container, using the directory '/my-tomcat-webapps-dir' on the host system as the tomcat webapps directory. Both directories should to be created before starting the running the containers.
Using these directories, it is possible to stop and remove the created containers and create new containers with an updated image keeping the OpenCms data. What in turn means that you should delete the content of this folders for a fresh installation.

### Environment variables ###

* DB_HOST the database host name, default is 'mysql'
* DB_USER the database user, default is 'root'
* DB_PASSWD the database password
* DB_NAME the database name, default is 'opencms'
* OPENCMS_COMPONENTS the OpenCms components to install, default is 'workplace,demo' to not install the demo template use 'workplace'
* TOMCAT_OPTS sets the tomcat startup options, default is '-Xmx1g -Xms512m -server -XX:+UseConcMarkSweepGC'
* WEBRESOURCES_CACHE_SIZE sets the size of tomcat's webresources cache, default is 200000 (200MB)

### Building the image ###

Navigate to the directory containing the Dockerfile and execute `docker build -t alkacon/opencms-docker:11.0.0-beta-2 .`.

## Latest supported OpenCms version: 10.5.4 ##

Dockerfiles for older OpenCms versions are also provided, see below.

### Running the image ###

To run the lastest pre-build OpenCms docker image directly from docker hub use:

```Shell
docker run -d -p 8080:8080 alkacon/opencms-docker:10.5.4
```

* You may replace the version number with any supported OpenCms version (see below).
* When the container is running, point your web browser to `http://localhost:8080/` to see OpenCms in action (up to OpenCms 10.0.x use `http://localhost:8080/opencms/`).
* Make sure that you change all default OpenCms passwords when you load the image on a public server ;)

The image features several options that can be set when calling `docker run`. Just add the environment variables via the `-e` option. Available options are (with default values):

 * `-e "OCCO_SERVER_NAME=http://localhost:8080"`
 * `-e "OCCO_ADMIN_PASSWD=admin"`
 * `-e "OCCO_USEPROXY=false"` (if set to `true` the "opencms" prefix is cut for internal links)
 * `-e "OCCO_ENABLE_JLAN=false"` (if set to `true` the network share is enabled, use option `-p 1445:1445` to make it available at your host)
 * `-e "OCCO_DEBUG=false"` (if set to `true` Tomcat starts in debug mode, use option `-p 8000:8000` to make the debug port available at your host)


### Building the image ###

When you have checked out the `alkacon/opencms-docker` repository from GitHub, you can build and run OpenCms with the following commands:

```Shell
cd ~/opencms-docker/10.x.x
docker build -t alkacon/opencms-docker:10.x.x .
docker run -d -p 8080:8080 alkacon/opencms-docker:10.x.x
```

Replace the `10.x.x` version number in all the above shell commands with a docker supported OpenCms version number (see below).

### Supported OpenCms versions ###

The following versions are currently supported with Docker images:

* OpenCms 10.5.4
* OpenCms 10.5.1
* OpenCms 10.5.0
* OpenCms 10.0.1
* OpenCms 10.0.0
* OpenCms 9.5.3
* OpenCms 9.5.2
* OpenCms 9.5.1
* OpenCms 9.5.0
* OpenCms 9.0.1

