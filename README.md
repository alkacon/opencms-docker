opencms-docker
==============

This official Docker image installs a standard OpenCms 9.0.1 system with demo content to be used for evaluation and testing purposes. This is an automated install that includes Tomcat and mySQL.

Run the image in a container with the following docker command:

    docker run -d -p 8080:8080 -p 22000:22 alkacon/opencms-docker:9.0.1-simple

When the container is running, point your web browser to the container IP, port 8080 to see OpenCms in action. You can also SSH to the container console (on port 22000). The root password for the SSH login is set in the Dockerfile, the default being *"mypassword"*. Make sure that changing this default password is the first thing you do after the image has been fired up.

  [1]: http://opencms.org/ "the OpenCms website"
