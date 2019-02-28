#!/bin/bash

# OpenCms server restart script

# We must work around an isse here that exists with Docker and the default Tomcat startup scripts.
# In short, the official "restart" script does not work in a Docker container. This is a known issue.
# Full information on the issue: https://github.com/docker/docker/issues/6800

WIDTH=$(stty size | cut -d" " -f2)

# Stopping the container is simply kill all processes of the tomcat user
echo "."
echo "Restarting OpenCms!"
echo "."

kill `ps -ef | grep tomcat | grep java | awk ' { print $2 } '`

echo "Killed Tomcat."
echo "."
echo "Waiting 10 seconds so that OpenCms can do a clean shut down..."
echo "."

sleep 10
tail -20 ${OPENCMS_HOME}/WEB-INF/logs/opencms.log

echo "."
echo "Shut down completed - see opencms.log tail above."
echo "."
echo "Starting Tomcat again..."
echo "."

${TOMCAT_HOME}/bin/catalina.sh run &> ${TOMCAT_HOME}/logs/catalina.out &
echo "."
sleep 1
ps -ef | grep tomcat | grep java

echo "."
echo "The ps output above should contain a ${TOMCAT} process."
echo "This means Tomcat runs, even though a [fail] message may have been displayed earlier!"
echo "."
