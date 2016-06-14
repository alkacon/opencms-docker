opencms-docker
==============
## Official docker support for OpenCms ##

These official docker images contain OpenCms with the demo application. This is a basic OpenCms installation that includes mySQL and Tomcat. OpenCms has been installed like that for ages, and it just works. The images are well suited for quick evaluation and test purposes of the latest OpenCms release.

### Latest supported OpenCms version: 10.0.1 ###

Dockerfiles for older OpenCms versions are also provided, see below.

### Running the image ###

To run the lastest pre-build OpenCms docker image directly from docker hub use:

```Shell
docker run -d -p 8080:8080 alkacon/opencms-docker:10.0.1
```

* You may replace the version number with any supported OpenCms version (see below).
* When the container is running, point your web browser to `http://localhost:8080/opencms/` to see OpenCms in action. 
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

* OpenCms 10.0.1
* OpenCms 10.0.0
* OpenCms 9.5.3
* OpenCms 9.5.2
* OpenCms 9.5.1
* OpenCms 9.5.0
* OpenCms 9.0.1

