#!/bin/bash

# OpenCms server restart script

# We must work around an isse here that exists with Docker and the default Tomcat startup scripts.
# In short, the official "restart" script does not work in a Docker container. This is a known issue.
# Full information on the issue: https://github.com/docker/docker/issues/6800

WIDTH=$(stty size | cut -d" " -f2)

echo "."
echo "Restarting OpenCms!"
echo "."

source /root/common.sh

CONTAINER_PID=$(ps -ef | egrep 'tomcat|jetty' | grep java | awk ' { print $2 } ')

if [ -z "$CONTAINER_PID" ]; then
    echo "Servlet container was not running."
else
    kill $(ps -ef | egrep 'tomcat|jetty' | grep java | awk ' { print $2 } ' )
    echo "Killed servlet container."
    echo "."
    echo "Waiting for a clean shut down..."
    echo "."
    while  kill -0 $CONTAINER_PID > /dev/null 2>&1; do
        echo "Servlet container still running ... Here are the last lines of the opencms.log"
        tail -20 ${OPENCMS_HOME}/WEB-INF/logs/opencms.log
        sleep 5
    done
    echo "."
    echo "Servlet container is shut down ... Here are the last lines of the opencms.log"
    tail -20 ${OPENCMS_HOME}/WEB-INF/logs/opencms.log
    echo "."
    echo "Shut down completed."
fi
echo "."
echo "Starting servlet container again..."
echo "."

start_container
echo "."
sleep 1
echo "Showing servlet container process via 'ps -ef | grep tomcat | grep java':"
ps -ef | egrep 'tomcat|jetty' | grep java

echo "."
echo "The ps output above should contain a ${SERVLET_CONTAINER} process."
echo "This means the servlet container is running, even though a [fail] message may have been displayed earlier!"
echo "."
