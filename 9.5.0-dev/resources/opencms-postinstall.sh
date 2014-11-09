#!/bin/bash
#
# Post-installation script for OpenCms on Docker
#
# Version for: 9.5.0 hsqldb dev

# Clean up opencms installation files not required for a running system
rm -f ${OPENCMS_HOME}/WEB-INF/packages/modules/*
rm -f ${OPENCMS_HOME}/WEB-INF/setup.*
rm -rf ${OPENCMS_HOME}/setup
rm -rf ${OPENCMS_HOME}/WEB-INF/setupdata
rm -f ${OPENCMS_HOME}/WEB-INF/logs/*
rm -f ${OPENCMS_HOME}/WEB-INF/*.bat

# By default Tomcat will overwrite session cookies from multiple webapps on the same IP even different ports are used
# With this little 'sed' magic, each running docker instance will attach the ID of the running container to the session cookie name 
sed -i "s/<Context>/<Context sessionCookieName=\"JSESSIONID_$HOSTNAME\">/" /etc/tomcat7/context.xml

# Make sure Tomcat has enough memory
sed -i "s/JAVA_OPTS=\"-Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC\"/JAVA_OPTS=\"-Djava.awt.headless=true -Xms256m -Xmx1024m -XX:MaxPermSize=128m -server -XX:+UseConcMarkSweepGC\"/" /etc/default/tomcat7 

# Enable SMB access to the container
# The default port in the container is 1445, we map this to 445 on container start with -p 455:1455  
mv ${OPENCMS_HOME}/WEB-INF/config/jlanConfig.xml.linux ${OPENCMS_HOME}/WEB-INF/config/jlanConfig.xml 

# Create a symlink to opencms in the root users home diretory as a shortcut.
ln -s /var/lib/tomcat7/webapps/ROOT/ /root/opencms
