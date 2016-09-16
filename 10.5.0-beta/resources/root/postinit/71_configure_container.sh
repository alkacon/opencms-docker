#!/bin/bash

echo "Configuring the container..."
echo "."

# Install some tools for easier debugging
apt-get update
apt-get install -yq --no-install-recommends vim-tiny less

# Create a shortcut to make navigation easier
cd /
ln -s /var/lib/${TOMCAT}/webapps/ROOT/WEB-INF/ opencms
cd /root/
ln -s /var/lib/${TOMCAT}/webapps/ROOT/WEB-INF/ opencms

echo "."
echo "Finished configuring the container!"

