FROM ubuntu:trusty
MAINTAINER Alkacon Software GmbH

#
# This Dockerfile installs a simple OpenCms demo system.
# It downloads the OpenCms distro and installs it with all the standard demo modules.
#
# Use the following command to run:
#  
# docker run -d -p 8080:8080 -p 22000:22 alkacon/opencms-docker:7.5.2-simple
# 

# Variables used in the shell scripts loaded from the file system
ENV ROOT_PWD=mypassword \
	WEBAPPS_HOME=/var/lib/tomcat7/webapps \
	OPENCMS_HOME=/var/lib/tomcat7/webapps/opencms \
	CONFIG_FILE=/setup.properties

RUN \
# Update the apt packet repos
    apt-get update && \ 

# Install mysql, tomcat7 and other stuff we need
    apt-get install -yq --no-install-recommends wget unzip openssh-server mysql-server tomcat7 && \

# Clean up
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove && \
    apt-get clean && \

# SSH Setup, straight from the example on the Docker website
    mkdir /var/run/sshd && \
    echo "root:${ROOT_PWD}" | chpasswd && \
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Create the mysqldump and preinstalled opencms tar gz
COPY resources /

RUN \
# Fetch the OpenCms installation file and create the setup properties
    wget -nv https://dl.dropboxusercontent.com/u/16438268/opencms-app.zip -O /opencms-app.zip && \
    wget -nv https://dl.dropboxusercontent.com/u/16438268/opencms.sql.zip -O /opencms-sql.zip && \
    chmod +x /opencms-*.sh && \
    bash /opencms-create-properties.sh && \
# Deploy the pre-installed app
	unzip -d $WEBAPPS_HOME /opencms-app.zip && \
    unzip /opencms-sql.zip && \
# Start up mysql and set the password of the root user to "opencms"
    service mysql start && \
    mysqladmin -u root --password="" password "${ROOT_PWD}" && \
# Create the Database and Extract and import the mysql dump
	mysql -uroot -p$ROOT_PWD -e "create database opencms" && \
	mysql -uroot -p$ROOT_PWD opencms < /opencms.sql && \

# Clean up
    chown -R tomcat7:tomcat7 ${OPENCMS_HOME} && \
    rm /opencms-create-properties.sh ${CONFIG_FILE}

# Run SSH, which allows us to connect to the dockerized OpenCms instance
EXPOSE 8080 
EXPOSE 22
CMD ["/opencms-run.sh"]
