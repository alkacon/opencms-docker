#!/bin/bash

OCSERVER="http://127.0.0.1:8080"
HWADDR=$(cat /sys/class/net/eth0/address)

MYSQL_ROOTPWD=$ROOT_PWD
MYSQL_DB=opencms

# Create setup.properties
echo "OpenCms Setup: Writing configuration to '$CONFIG_FILE'"
PROPERTIES="

setup.webapp.path=$OPENCMS_HOME
setup.default.webapp=
setup.install.components=workplace,releasenotes,template3,devdemo,bootstrap
setup.show.progress=true

db.product=mysql
db.provider=mysql
db.create.user=root
db.create.pwd=$MYSQL_ROOTPWD
db.worker.user=root
db.worker.pwd=$MYSQL_ROOTPWD
db.connection.url=jdbc:mysql://localhost:3306/
db.name=$MYSQL_DB
db.create.db=true
db.create.tables=true
db.dropDb=true
db.default.tablespace=
db.index.tablespace=
db.jdbc.driver=org.gjt.mm.mysql.Driver
db.template.db=
db.temporary.tablespace=

server.url=$OCSERVER
server.name=OpenCmsServer
server.ethernet.address=$HWADDR
server.servlet.mapping=

"
echo "$PROPERTIES" > $CONFIG_FILE || { echo "Error: Couldn't write to '$CONFIG_FILE'!" ; exit 1 ; }
