#!/bin/bash

# OpenCms startup script executed when Docker loads the image


# Start Tomcat 
service tomcat7 start

# Run SSH in "non-deamon" mode
/usr/sbin/sshd -D

