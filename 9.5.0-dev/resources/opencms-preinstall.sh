#!/bin/bash
#
# Pre-Installation script for OpenCms on Docker
# Assumes that the opencms.war has been unpacked already
#
# Version for: 9.5.0 hsqldb dev

# Remove the spell checker from OpenCms
# The spell check feature requires about 150 MB of disk space.
# Since this is a development machine, this feature should not be required.
sed -i "s/<core name=\"spellcheck\" instanceDir=\"..\/spellcheck\"\/>/ /" ${OPENCMS_HOME}/WEB-INF/solr/solr.xml
rm -f  ${OPENCMS_HOME}/WEB-INF/packages/modules/org.opencms.workplace.spellcheck*
rm -rf ${OPENCMS_HOME}/WEB-INF/spellcheck/*

