opencms-docker
==============

##Dockerfiles for OpenCms##

These official Dockerfiles install various types of **OpenCms 9.5.0** systems with demo content. 
The fully automated install downloads the OpenCms distribution files from `opencms.org`.
Dockerfiles for older OpenCms versions are also provided, see below for a complete list.

###Basic image `simple`:###

*Latest supported OpenCms version: 9.5.0*

This is a basic OpenCms install with mySQL and Tomcat. 
OpenCms has been installed like that for ages, and it just works. 
Best suited for evaluation and test purposes.

Create the simple image and run the container with the following commands:

```Shell
cd ~/opencms-docker/9.5.0-simple
docker build -t alkacon/opencms-docker:9.5.0-simple .
docker run -d -p 8080:8080 -p 22000:22 alkacon/opencms-docker:9.5.0-simple
```

*`simple` image usage notes:*

* When the container is running, point your web browser to `http://your-host-ip:8080/opencms/opencms/` to see OpenCms in action. 
* You can also SSH to the container console (on port 22000) as user `root`.
  The root password for the SSH login is set in the Dockerfile, the default being `mypassword`. 
* As always, **make sure that you change all default passwords** when you load the image for the first time.

###Development image `dev`:###

*Latest supported OpenCms version: 9.5.0*

This is a development OpenCms install with HSQLDB and Tomcat. Recommended for development use.
 
The resulting image will be about 200MB smaller in size compared to the simple image.
The spell check feature is disabled in this image to save size.
OpenCms is installed in the `ROOT` webapp here, so the URL is shorter. 
Moreover, the OpenCms repository SMB / network share feature is enabled, so you can directly connect your desktop to the repo.

Create the development image and run the container with the following commands:

```Shell
cd ~/opencms-docker/9.5.0-dev
docker build -t alkacon/opencms-docker:9.5.0-dev .
docker run -d -p 80:8080 -p 22000:22 -p 445:1445 alkacon/opencms-docker:9.5.0-dev
```

*`dev` image usage notes:*

* When the container is running with the parameters above, point your web browser to `http://your-host-ip/opencms/` to see OpenCms in action. 
* You can SSH to the container console (on port 22000) as user `root`.
  The root password for the SSH login is set in the Dockerfile, the default being `mypassword`. 
* Connect the OpenCms repository to a network share on your desktop using the address `//your-host-ip/OPENCMS`.
  Use the default OpenCms user `Admin` and password `admin` to log in.
* As always, **make sure that you change all default passwords** when you load the image for the first time.


##Supported OpenCms versions##

The following versions are currently supported with Docker images:

* OpenCms 9.5.0: `simple`, `dev`
* OpenCms 9.0.1: `simple`

