#!/bin/bash

if [ "$SERVLET_CONTAINER" != "jetty" ]; then
    echo "Skipping $0 because we are not using Jetty"
    exit
fi

chown -R jetty:jetty $CONTAINER_BASE
