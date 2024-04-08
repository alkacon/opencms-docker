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

start_container

# Write startup time to file
date > ${OPENCMS_HOME}/WEB-INF/opencms-starttime

function kill_container_and_exit() {
    kill_container
    exit
}
trap "kill_container_and_exit" SIGTERM

# Execute post-init configuration scripts
bash /root/process-script-dir.sh /root/postinit runonce

# We need a running process for docker
# We use only sleep 1 to get kill_container() executed when SIGTERM is receive
while true ; do
    sleep 1
done
