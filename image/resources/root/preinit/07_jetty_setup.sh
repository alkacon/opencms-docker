#!/bin/bash

if [ "$SERVLET_CONTAINER" != "jetty" ]; then
    echo "Skipping $0 because we are not using Jetty"
    exit
fi

cd $CONTAINER_BASE
java -jar $JETTY_HOME/start.jar --add-modules=ee8-deploy,ee8-jsp,ee8-jstl,server,http,gzip
echo "$JETTY_OPTS" > jetty-opts.txt