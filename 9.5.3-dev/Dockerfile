FROM java:8-jre
MAINTAINER Alkacon Software GmbH

#
# This Dockerfile installs an OpenCms dev system.
# It downloads the OpenCms distro and installs it with all the standard demo modules.
#
# Use the following command to run:
#  
# docker run -d -p 80:8080 -p 22000:22 -p 445:1445 alkacon/opencms-docker:9.5.3-dev
# 

# Variables used in the shell scripts loaded from the file system
ENV ROOT_PWD=mypassword \
    DEBIAN_FRONTEND=noninteractive \
    WEBAPPS_HOME=/var/lib/tomcat8/webapps \
    OPENCMS_HOME=/var/lib/tomcat8/webapps/opencms \
    CONFIG_FILE=/setup.properties

RUN \
# Update the apt packet repos
    apt-get update && \ 

# Install mysql, tomcat8 and other stuff we need
    apt-get install -yq --no-install-recommends wget unzip openssh-server tomcat8 && \

# Clean up
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove && \
    apt-get clean && \

# SSH Setup, straight from the example on the Docker website
    mkdir /var/run/sshd && \
    echo "root:${ROOT_PWD}" | chpasswd && \
    sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Create the setup configuration file
COPY resources /

# The OpenCms version to download and install
ENV OPENCMS_URL http://www.opencms.org/downloads/opencms/opencms-9.5.3.zip

RUN \
# Fetch the OpenCms installation file and create the setup properties
    chmod +x /opencms-*.sh && \
    bash /opencms-fetch.sh && \
    bash /opencms-create-properties.sh && \
# Create webapp in ROOT folder
    rm -rf ${WEBAPPS_HOME}/ROOT && \
    mkdir ${OPENCMS_HOME} && \
# Unzip the .war and remove the file 
    unzip -q -d ${OPENCMS_HOME} /opencms.war && \
# Run pre-install script
    bash /opencms-preinstall.sh && \ 
# Install OpenCms using the class org.opencms.setup.CmsAutoSetup
    java -classpath "${OPENCMS_HOME}/WEB-INF/lib/*:${OPENCMS_HOME}/WEB-INF/classes:/usr/share/tomcat8/lib/*" \
        org.opencms.setup.CmsAutoSetup -path ${CONFIG_FILE} && \
# Run post-install script
    bash /opencms-postinstall.sh && \ 
# Clean up
    chown -R tomcat8:tomcat8 ${OPENCMS_HOME} && \
    mv /opencms-run.sh /root/ && \
    rm -rf /opencms.war /opencms-*.sh ${CONFIG_FILE} /config

# Run SSH, which allows us to connect to the dockerized OpenCms instance
EXPOSE 8080 
EXPOSE 1445
EXPOSE 22
CMD ["/root/opencms-run.sh"]
