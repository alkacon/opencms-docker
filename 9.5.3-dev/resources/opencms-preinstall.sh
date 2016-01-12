#!/bin/bash
#
# Pre-Installation script for OpenCms on Docker
# Assumes that the opencms.war has been unpacked already
#
# Version for: 9.5.3 hsqldb dev

# Copy the optimized configuration files over distribution ones
cp /config/*.xml ${OPENCMS_HOME}/WEB-INF/config/

# Remove the spell checker from OpenCms.
# The spell check feature requires about 150 MB of disk space.
# Since this is a development machine, this feature should not be required.
sed -i "s/<core name=\"spellcheck\" instanceDir=\"..\/spellcheck\"\/>/ /" ${OPENCMS_HOME}/WEB-INF/solr/solr.xml
sed -i "s/<requesthandler class=\"org.opencms.main.OpenCmsSpellcheckHandler\"\/>/ /" ${OPENCMS_HOME}/WEB-INF/config/opencms-system.xml 
rm -f  ${OPENCMS_HOME}/WEB-INF/packages/modules/org.opencms.workplace.spellcheck*
rm -rf ${OPENCMS_HOME}/WEB-INF/spellcheck

# Change the default password encoding to be MD5.
# Since 9.5 OpenCms uses the scrypt algorithm to store passwords in the DB by default.
# The drawback is that it takes - on purpose - quite long (about 1 sec) to authenticate a user.
# For stateless protocolls like CMIS where the auth is done for every request this is a problem.
# Since this is a development setup we use MD5 which is much faster.
sed -i "s/<digest-type>scrypt/<digest-type>MD5/" ${OPENCMS_HOME}/WEB-INF/config/opencms-system.xml
sed -i "s/<param name=\"scrypt.settings\">16384,8,1<\/param>/ /" ${OPENCMS_HOME}/WEB-INF/config/opencms-system.xml
