#!/bin/bash

# OpenCms startup script executed when Docker loads the image

# Set the timezone
echo "Adjusting the timezone"
bash /root/set-timezone.sh ${TIME_ZONE}

ls /root/preinit/

chmod -v +x /root/preinit/*.sh

ls /root/postinit/

chmod -v +x /root/postinit/*.sh


# Execute pre-init configuration scripts
bash /root/process-script-dir.sh /root/preinit runonce

echo "Starting OpenCms / Tomcat in background"
${TOMCAT_HOME}/bin/catalina.sh run &> ${TOMCAT_HOME}/logs/catalina.out &

# Write startup time to file
date > ${OPENCMS_HOME}/WEB-INF/opencms-starttime

# Execute post-init configuration scripts
bash /root/process-script-dir.sh /root/postinit runonce

# We need a running process for docker
sleep 10000d
