#!/bin/bash

# Tomcat server configuration
# This is ON PURPOSE done in the init / run phase NOT during image installation phase!
# In case you need a special Tomact configuration in a downsteam image, just overwrite this configuration script.
# Or, you can add the configuration as environment variable TOMCAT_OPTS.
if [ -z "${TOMCAT_OPTS}" ]; then
	TOMCAT_OPTS="-Xmx1536m -Xms256m -server -XX:+UseConcMarkSweepGC"
else
	TOMCAT_OPTS="${TOMCAT_OPTS}"
fi

if [ "${DEBUG}" == "true" ]; then
	TOMCAT_OPTS="${TOMCAT_OPTS}  -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000 -Djava.compiler=NONE"
fi

# By default Tomcat will overwrite session cookies from multiple webapps on the same IP even different ports are used
# With this little 'sed' magic, each running docker instance will attach the ID of the running container to the session cookie name
echo "Making session cookie name unique and disabling web sockets ..."
sed -i "s/<Context>/<Context sessionCookieName=\"JSESSIONID_$HOSTNAME\" containerSciFilter=\"WsSci\">/" ${TOMCAT_HOME}/conf/context.xml

# Increasing Tomcat webresources cache size
echo "Setting webresources cache size to override defaults"
sed -i "s/<\/Context>/<Resources cachingAllowed=\"true\" cacheMaxSize=\"${WEBRESOURCES_CACHE_SIZE}\" \/><\/Context>/" ${TOMCAT_HOME}/conf/context.xml

# Disabling session persistence
# Disable JAR scanning for servlets and restrict TLD scanning to the JSTL JAR to speed up Tomcat start
echo "Disabling session persistence and adding JAR scanner filter ..."
sed -i "s/<\/Context>/<Manager pathname=\"\" \/><JarScanner><JarScanFilter pluggabilitySkip=\"\*.jar\" tldSkip=\"\*.jar\" tldScan=\"javax.servlet.jsp.jstl-\*.jar\"\/><\/JarScanner><\/Context>/" ${TOMCAT_HOME}/conf/context.xml


echo "Setting java opts for Tomcat to: ${TOMCAT_OPTS}"
echo "JAVA_OPTS=\"-Djava.awt.headless=true -DDISPLAY=:0.0 ${TOMCAT_OPTS}\"" > ${TOMCAT_HOME}/bin/setenv.sh

echo "Using OpenCms optimized server.xml configuration for Tomcat"
if [ "$GZIP" == "true" ]; then
	echo "Enabling GZIP compression for tomcat."
    sed -i 's/compression="off"/compression="on"/g' /config/server.xml
fi
mv -v /config/server.xml ${TOMCAT_HOME}/conf/server.xml