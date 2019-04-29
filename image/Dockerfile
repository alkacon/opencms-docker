FROM tomcat:9.0-jre11
MAINTAINER Alkacon Software GmbH

#
# This Dockerfile installs a simple OpenCms demo system.
# It downloads the OpenCms distro and installs it with all the standard demo modules.
#
# Use the following command to run:
#
# docker run -d -p 80:8080 -p 22000:22 alkacon/opencms-docker:9.5.3-simple
#

# Variables used in the shell scripts loaded from the file system
ENV TOMCAT_HOME=/usr/local/tomcat
ENV TOMCAT_LIB=${TOMCAT_HOME}/lib \
	WEBAPPS_HOME=${TOMCAT_HOME}/webapps \
    OPENCMS_HOME=${TOMCAT_HOME}/webapps/ROOT \
    ARTIFACTS_FOLDER=/artifacts/ \
    CONFIG_FILE=/config/setup.properties \
    OPENCMS_URL=http://www.opencms.org/downloads/opencms/opencms-11.0.0.zip \
    OPENCMS_COMPONENTS=workplace,demo \
    UPDATE_CONFIG_FILES="WEB-INF/web.xml WEB-INF/opencms.tld WEB-INF/config/opencms-search.xml WEB-INF/config/opencms-system.xml WEB-INF/config/opencms-vfs.xml WEB-INF/config/opencms-workplace.xml"\
    TIME_ZONE=Europe/Berlin \
    TOMCAT_OPTS="-Xmx1g -Xms512m -server -XX:+UseConcMarkSweepGC" \
    GZIP=true \
	ADMIN_PASSWD=admin \
	DB_HOST=mysql \
	DB_NAME=opencms \
	DB_USER=root \
	DB_PASSWD=\
	WEBRESOURCES_CACHE_SIZE=200000\
	DEBUG=false

RUN \
	echo "Update the apt packet repos" && \
    apt-get update && \
	echo "Install utils" && \
    apt-get install -yq --no-install-recommends procps wget unzip xsltproc netcat && \
	echo "Clean up apt" && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove && \
    apt-get clean

# Create the setup configuration file
COPY resources /

RUN \
    chmod +x /root/*.sh && \
    bash /root/opencms-fetch.sh && \
    rm -rf ${WEBAPPS_HOME}/*

# Expose port 8080 for Tomcat and define the startup script
EXPOSE 8080

CMD ["/root/opencms-run.sh"]
