#!/bin/bash

echo "Making sure tomcat user is the owner of the webapp dir"
chown -R ${TOMCAT}:${TOMCAT} ${WEBAPPS_HOME}

