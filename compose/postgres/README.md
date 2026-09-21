# OpenCms with PostgreSQL

OpenCms uses a special configuration file called
[`setup.properties`](https://github.com/alkacon/opencms-core/blob/main/src-setup/org/opencms/setup/setup.properties.example)
to establish a database connection.

In order to connect to a database other than MariaDB, this image supports connection via a custom
`setup.properties` file. The file must be named `custom-setup.properties` and must be available in
the root folder of the Docker container.

This example combines PostgreSQL and OpenCms in [`docker-compose.yml`](docker-compose.yml) and
mounts the provided [`custom-setup.properties`](custom-setup.properties) into the OpenCms
container.

For more information on the database configuration options, see the
[OpenCms documentation](https://documentation.opencms.org/opencms-documentation/server-administration/headless-installation/).

Note: When using a custom configuration file, the environment variables `DB_HOST`, `DB_USER`,
`DB_PASSWD`, `DB_NAME`, `OPENCMS_COMPONENTS` and `SERVER_URL` are ignored.
