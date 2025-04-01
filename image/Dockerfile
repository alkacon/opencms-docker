ARG BASE_IMAGE=jetty:12-jdk21
FROM $BASE_IMAGE
LABEL org.opencontainers.image.authors="Alkacon Software GmbH & Co. KG"
USER root
ARG SERVLET_CONTAINER=jetty
ENV SERVLET_CONTAINER=${SERVLET_CONTAINER}

#
# This Dockerfile installs a simple OpenCms demo system.
# It downloads the OpenCms distro and installs it with all the standard demo modules.
#
# You should run it in combination with a mysql container, as specified in the docker-compose.yaml
# coming with this repository.
#

# Variables used in the shell scripts loaded from the file system
ENV DEBIAN_FRONTEND=noninteractive \
    TMPDIR=/tmp

ENV CONTAINER_BASE=/container \
    TOMCAT_HOME=/usr/local/tomcat \
    JETTY_HOME=/usr/local/jetty \
    BASH_ENV=/root/common.sh

ENV TOMCAT_LIB=${TOMCAT_HOME}/lib \
    JETTY_LIB=${JETTY_HOME}/lib \
    WEBAPPS_HOME=${CONTAINER_BASE}/webapps \
    OPENCMS_HOME=${CONTAINER_BASE}/webapps/ROOT \
    ARTIFACTS_FOLDER=/artifacts/ \
    CONFIG_FILE=/config/setup.properties \
    OPENCMS_URL=https://github.com/alkacon/opencms-core/releases/download/build_19_0_0/opencms-19.0-distribution.zip \
    OPENCMS_COMPONENTS=workplace,demo \
    UPDATE_CONFIG_FILES="WEB-INF/web.xml WEB-INF/opencms.tld WEB-INF/config/opencms-search.xml WEB-INF/config/opencms-system.xml WEB-INF/config/opencms-vfs.xml WEB-INF/config/opencms-workplace.xml WEB-INF/solr/configsets/default/conf/solrconfig.xml WEB-INF/solr/spellcheck/conf/solrconfig.xml"\
    TIME_ZONE=Europe/Berlin \
    JETTY_OPTS="-Xmx2g" \
    TOMCAT_OPTS=\
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
    apt-get install -yq --no-install-recommends procps wget unzip xsltproc netcat-openbsd && \
    echo "Clean up apt" && \
    rm -rf /var/lib/apt/lists/* && \
    apt-get autoremove && \
    apt-get clean

# Create the setup configuration file
COPY resources /

RUN \
    echo "Make scripts under /root/ executable" && \
    chmod +x /root/*.sh && \
    echo "Update .bashrc" && \
    echo "source /root/common.sh" >> /root/.bashrc && \
    bash /root/opencms-fetch.sh && \
    rm -rf ${WEBAPPS_HOME}/*

# Expose port 8080 for Tomcat and define the startup script
EXPOSE 8080
WORKDIR $CONTAINER_BASE
CMD ["/root/opencms-run.sh"]
