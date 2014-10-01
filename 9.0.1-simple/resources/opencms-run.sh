#!/bin/bash
# 

# By default Tomcat will overwrite session cookies from multiple webapps on the same IP even different ports are used
# With this little 'sed' magic, each running docker instance will attach the ID of the running container to the session cookie name 
sed -i "s/<Context>/<Context sessionCookieName=\"JSESSIONID_$HOSTNAME\">/" /etc/tomcat7/context.xml

# Make sure Tomcat has enough memory
sed -i "s/JAVA_OPTS=\"-Djava.awt.headless=true -Xmx128m -XX:+UseConcMarkSweepGC\"/JAVA_OPTS=\"-Djava.awt.headless=true -Xms256m -Xmx1024m -XX:MaxPermSize=128m -server -XX:+UseConcMarkSweepGC\"/" /etc/default/tomcat7 

# Start mySQL and Tomcat 
service mysql start
service tomcat7 start

# Run SSH in "non-deamon" mode
/usr/sbin/sshd -D

