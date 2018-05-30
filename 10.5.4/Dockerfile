FROM java:8-jre
MAINTAINER Alkacon Software GmbH

#
# This Dockerfile create a dependency image for OpenCms based on Java 8.
# The dependencies are a set of common installation scripts and files.
#

# Variables used in the shell scripts loaded from the file system
ENV DEBIAN_FRONTEND=noninteractive \
    TOMCAT=tomcat8

ENV WEBAPPS_HOME=/var/lib/${TOMCAT}/webapps \
    WEBAPPS_HOME_INSTALL=/var/lib/${TOMCAT}/webapps-install \
    OPENCMS_HOME=/var/lib/${TOMCAT}/webapps/ROOT \
    OPENCMS_HOME_INSTALL=/var/lib/${TOMCAT}/webapps-install/ROOT \
    CONFIG_FILE=/setup.properties \
    OPENCMS_COMPONENTS=workplace,demo

RUN \
# Update the apt packet repos
    apt-get update && \
# Install mysql and tomcat
    apt-get install -yq --no-install-recommends \
        ${TOMCAT} \
        mysql-server \
        gettext && \
# Clean up and set timezone
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove && \
    apt-get clean

# Copy resource dependencies to the docker images
COPY resources /

RUN \
# Download core artifacts if not already present
    bash /root/download-artifacts.sh /config/artifacts.csv && \
# Unzip the war from the core and delete the unnecessary files
    cd /artifacts/core/ && \
    unzip opencms.zip && \
    cd / && \
    mv /artifacts/core/opencms.war /artifacts/opencms.war && \
    rm -fr /artifacts/core && \
# Create the setup properties
    chmod -v +x /root/opencms-*.sh && \
    bash /root/opencms-create-properties.sh && \
# Create webapp in ROOT folder of the webapps-install folder
    rm -v -rf ${WEBAPPS_HOME} && \
    mkdir -v -p ${OPENCMS_HOME_INSTALL} && \
# Unzip the .war
    unzip -q -d ${OPENCMS_HOME_INSTALL} /artifacts/opencms.war && \
# Start up mysql and set the password of the root user to "admin"
    service mysql start && \
    mysqladmin -u root --password="" password "admin" && \
# Run pre-install scripts
    bash /root/process-script-dir.sh /root/preinstall && \
# Install OpenCms using org.opencms.setup.CmsAutoSetup
    java -classpath "${OPENCMS_HOME_INSTALL}/WEB-INF/lib/*:${OPENCMS_HOME_INSTALL}/WEB-INF/classes:/usr/share/${TOMCAT}/lib/*" \
        org.opencms.setup.CmsAutoSetup -path ${CONFIG_FILE} && \
# Run post-install scripts
    bash /root/process-script-dir.sh /root/postinstall

# Expose port 8080 for Tomcat and define the startup script
EXPOSE 8080

CMD ["/root/opencms-run.sh"]
