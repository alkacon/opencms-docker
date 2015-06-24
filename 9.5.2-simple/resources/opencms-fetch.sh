#!/bin/bash

# Check if a file opencms.war is not available, if so download from the web 
if [ ! -s opencms.war ] 
then

	if [ ! -s opencms.zip ]
	then
		echo "Downloading OpenCms from '$OPENCMS_URL'"
		wget -nv $OPENCMS_URL -O opencms.zip
		echo "Download complete, unpacking war"
	fi

	if [ -s opencms.zip ]
	then
		unzip -q opencms.zip opencms.war
		rm -f opencms.zip
	else 
		exit 1
	fi
else
	echo "Using local WAR file"
fi 
 
