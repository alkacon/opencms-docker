FROM ubuntu:trusty
MAINTAINER Alkacon Software GmbH

#
# This Dockerfile installs a simple OpenCms demo system.
# It downloads the OpenCms distro and installs it with all the standard demo modules.
#
# Use the following command to run:
#  
# docker run -d -p 8080:8080 -p 22000:22 alkacon/opencms-docker:9.5.0-simple
# 

ENV ROOT_PWD mypassword

# Variables used in the shell scripts loaded from the file system
ENV WEBAPPS_HOME /var/lib/tomcat7/webapps
ENV OPENCMS_HOME /var/lib/tomcat7/webapps/opencms
ENV CONFIG_FILE /setup.properties

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

# Create the setup configuration file
ADD resources /

# The OpenCms version to download and install
ENV OPENCMS_URL http://www.opencms.org/downloads/opencms/opencms-9.5.0.zip

RUN \
# Fetch the OpenCms installation file and create the setup properties
    chmod +x /opencms-*.sh && \
    bash /opencms-fetch.sh && \
    bash /opencms-create-properties.sh && \
# Create webapp folder
    mkdir ${OPENCMS_HOME} && \
# Unzip the .war and remove the file 
    unzip -q -d ${OPENCMS_HOME} /opencms.war && \
# Start up mysql and set the password of the root user to "opencms"
    service mysql start && \
    mysqladmin -u root --password="" password "${ROOT_PWD}" && \
# Install OpenCms using the class org.opencms.setup.CmsAutoSetup
    java -classpath "${OPENCMS_HOME}/WEB-INF/lib/*:${OPENCMS_HOME}/WEB-INF/classes:/usr/share/tomcat7/lib/*" \
        org.opencms.setup.CmsAutoSetup -path ${CONFIG_FILE} && \
# Clean up
    chown -R tomcat7:tomcat7 ${OPENCMS_HOME} && \
    rm /opencms.war /opencms-create-properties.sh /opencms-fetch.sh ${CONFIG_FILE}

# Run SSH, which allows us to conntect to the dockerized OpenCms instance
EXPOSE 8080 
EXPOSE 22
CMD ["/opencms-run.sh"]
