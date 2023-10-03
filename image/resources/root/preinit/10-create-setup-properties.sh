#!/bin/bash

OCSERVER=${SERVER_URL:-http://localhost}
HWADDR=$(cat /sys/class/net/eth0/address)

DB_USER=$DB_USER
DB_PWD=$DB_PASSWD
DB_DB=$DB_NAME
DB_PRODUCT=$DB_PRODUCT
DB_URL="jdbc:${DB_PRODUCT}://${DB_HOST}:${DB_PORT}/"

if [[ ${DB_PRODUCT} == "mysql" ]]; then
    DB_DRIVER=org.mariadb.jdbc.Driver
elif [[ ${DB_PRODUCT} == "postgresql" ]]; then
    DB_DRIVER=org.postgresql.Driver
    TEMPLATE_DB=template1
    DB_WORKER_USER=opencms
else
    echo "Unknown DB: ${DB_PRODUCT}"
    exit 1
fi


# Create setup.properties
echo "OpenCms Setup: Writing configuration to '$CONFIG_FILE'"
echo "-- Components: $OPENCMS_COMPONENTS"
PROPERTIES="

setup.webapp.path=$OPENCMS_HOME
setup.default.webapp=
setup.install.components=$OPENCMS_COMPONENTS
setup.show.progress=true

db.product=$DB_PRODUCT
db.provider=$DB_PRODUCT
db.create.user=$DB_USER
db.create.pwd=$DB_PWD
db.worker.user=${DB_WORKER_USER:-$DB_USER}
db.worker.pwd=$DB_PWD
db.connection.url=$DB_URL
db.name=$DB_DB
db.create.db=true
db.create.tables=true
db.dropDb=true
db.default.tablespace=
db.index.tablespace=
db.jdbc.driver=$DB_DRIVER
db.template.db=$TEMPLATE_DB
db.temporary.tablespace=

server.url=$OCSERVER
server.name=OpenCmsServer
server.ethernet.address=$HWADDR
server.servlet.mapping=

"
echo "$PROPERTIES" > $CONFIG_FILE || { echo "Error: Couldn't write to '$CONFIG_FILE'!" ; exit 1 ; }
