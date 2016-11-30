#!/bin/bash

# Tomcat server configuration
# This is ON PURPOSE done in the init / run phase NOT during image installation phase!
# In case you need a special Tomact configuration in a downsteam image, just overwrite this configuration script.

TOMCAT_OPTS="-Xmx1536m -Xms256m -server -XX:+UseConcMarkSweepGC"

if [ "${OCCO_DEBUG}" == "true" ]; then
	TOMCAT_OPTS="${TOMCAT_OPTS}  -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=8000 -Djava.compiler=NONE"
fi

# By default Tomcat will overwrite session cookies from multiple webapps on the same IP even different ports are used
# With this little 'sed' magic, each running docker instance will attach the ID of the running container to the session cookie name
echo "Making session cookie name unique ..." 
sed -i "s/<Context>/<Context sessionCookieName=\"JSESSIONID_$HOSTNAME\">/" /etc/${TOMCAT}/context.xml

echo "Adjusting java opts for Tomcat to: ${TOMCAT_OPTS}"
sed -i "s/JAVA_OPTS=\"-Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC\"/JAVA_OPTS=\"-Djava.awt.headless=true -DDISPLAY=:0.0 ${TOMCAT_OPTS}\"/" /etc/default/${TOMCAT} 

echo "Using OpenCms optimized server.xml configuration for Tomcat"
mv -v /config/server.xml /etc/${TOMCAT}/server.xml