opencms-docker
==============
## Dockerfiles for OpenCms 10 ##
The official Dockerfile installs OpenCms with the demo.
The fully automated install downloads the OpenCms distribution and demo modules from `artifacts.alkacon.com`.
Dockerfiles for older OpenCms versions are also provided, see below.

### Latest supported OpenCms version: 10.0.1 ###

This is a basic OpenCms install with mySQL and Tomcat. 
OpenCms has been installed like that for ages, and it just works. 
Best suited for evaluation and test purposes.

You can just run the image (without checking out the repository at all) via

```Shell
docker run -d -p 8080:8080 alkacon/opencms-docker:10.0.1
```


When you check out the repository, you can create the image yourself and run it as container with the following commands:

```Shell
cd ~/opencms-docker/10.0.1
docker build -t alkacon/opencms-docker:10.0.1 .
docker run -d -p 8080:8080 alkacon/opencms-docker:10.0.1
```


To run or build images of older OpenCms version (>= 10.0.0) just replace the version number in all the above shell commands.

#### Additional options ####
The image features several options that can be set when calling `docker run`. Just add environment variables via the `-e` option.

Available options are (with default values handed over):

 * `-e "OCCO_SERVER_NAME=http://localhost:8080"`
 * `-e "OCCO_SERVER_ALIAS="` (none configured by default)
 * `-e "OCCO_ADMIN_PASSWD=admin"`
 * `-e "OCCO_USEPROXY=false"` (if set to `true` the "opencms" prefix is cut for internal links)
 * `-e "OCCO_ENABLE_JLAN=false"` (if set to `true` the network share is enabled, use option `-p 1445:1445` to make it available at your host)
 * `-e "OCCO_DEBUG=false"` (if set to `true` Tomcat starts in debug mode, use option `-p 8000:8000` to make the debug port available at your host)

## Dockerfiles for older OpenCms versions ##

### Latest supported OpenCms version: 9.5.3 ###

Installs an **OpenCms 9.5.3** system with demo content. 
This is a basic OpenCms install with mySQL and Tomcat. 
The fully automated install downloads the OpenCms distribution files from `opencms.org`.
Dockerfiles for older OpenCms versions are also provided, see below for a complete list.

Create the image and run the container with the following commands:

```Shell
cd ~/opencms-docker/9.5.3-simple
docker build -t alkacon/opencms-docker:9.5.3-simple .
docker run -d -p 8080:8080 -p 22000:22 alkacon/opencms-docker:9.5.3-simple
```

### Usage notes ###

* When the container is running, point your web browser to `http://your-host-ip:8080/opencms/opencms/` to see OpenCms in action. 
* You can also SSH to the container console (on port 22000) as user `root`.
  The root password for the SSH login is set in the Dockerfile, the default being `mypassword`. 
* As always, **make sure that you change all default passwords** when you load the image for the first time.

## Supported OpenCms versions ##

The following versions are currently supported with Docker images:

* OpenCms 10.0.1
* OpenCms 10.0.0
* OpenCms 9.5.3
* OpenCms 9.5.2
* OpenCms 9.5.1
* OpenCms 9.5.0
* OpenCms 9.0.1

