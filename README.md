opencms-docker
==============
## Official OpenCms docker image ##

The official docker image contains OpenCms with the demo application.
This is a basic OpenCms installation with Tomcat that can connect to a MySql/mariaDB database (e.g., running in another container).

The image is well suited for evaluation and test purposes of the latest OpenCms release.
We provide a docker-compose file to get OpenCms and the database running with just one command.

### Running the alkacon/opencms-docker:11.0.1 image ###

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
        image: alkacon/opencms-docker:11.0.1
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
 #           - "DEBUG=false"
```
You can save this file as 'docker-compose.yaml' and adjust the directories '/my-mysql-data-dir' and '/my-tomcat-webapps-dir' to suitable folders on your host system.
Navigate to the folder containing the file 'docker-compose.yaml' and execute `docker-compose up -d`. You can view the log of the OpenCms container with `docker logs -f opencms`.

This will start one mariadb/mysql container, using the data directory '/my-mysql-data-dir' on the host system. The second container is the OpenCms container, using the directory '/my-tomcat-webapps-dir' on the host system as the tomcat webapps directory.
Both directories should to be created before starting the running the containers.

Using these directories, it is possible to stop and remove the created containers and create new containers with an updated image keeping the OpenCms data.
What in turn means that *you should delete the content of this folders for a fresh installation*.

### Environment variables ###

* DB_HOST the database host name, default is 'mysql'
* DB_USER the database user, default is 'root'
* DB_PASSWD the database password
* DB_NAME the database name, default is 'opencms'
* OPENCMS_COMPONENTS the OpenCms components to install, default is 'workplace,demo' to not install the demo template use 'workplace'
* TOMCAT_OPTS sets the tomcat startup options, default is '-Xmx1g -Xms512m -server -XX:+UseConcMarkSweepGC'
* WEBRESOURCES_CACHE_SIZE sets the size of tomcat's webresources cache, default is 200000 (200MB)
* DEBUG flag, indicating if debug connections via {docker ip address}:8000 are allowed.

### Building the image ###

Since the image is available on Docker Hub, you do not need to build it yourself. If you want to build it anyway, here's how to do it:

  * via docker-compose: Go to the repository's main folder and typ `docker-compose build opencms`.
  * via plain docker: Navigate to the directory `image`, where the Dockerfile is located, and execute `docker build -t alkacon/opencms-docker:11.0.1 .`.

## Support for older OpenCms versions ##

Images for older OpenCms versions are also provided.

For details see [https://github.com/alkacon/opencms-docker/blob/master/README.md](https://github.com/alkacon/opencms-docker/blob/master/README.md)