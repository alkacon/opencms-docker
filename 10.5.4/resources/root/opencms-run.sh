#!/bin/bash

# OpenCms startup script executed when Docker loads the image

echo "Starting mySQL server"

# Fix mysql problem with overlay2
find /var/lib/mysql/mysql -type f -exec touch {} \;

service mysql start

# Execute pre-init configuration scripts
bash /root/process-script-dir.sh /root/preinit runonce

echo "Starting OpenCms / Tomcat in background"
/etc/init.d/${TOMCAT} start &> /dev/null &

# Execute post-init configuration scripts
bash /root/process-script-dir.sh /root/postinit runonce

# We need a running process for docker
sleep 10000d
