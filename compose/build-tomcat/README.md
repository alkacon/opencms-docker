# OpenCms with Tomcat

This Docker Compose project demonstrates how to build and run the OpenCms legacy variant with Tomcat
instead of the default Jetty servlet container.

[`docker-compose.yml`](docker-compose.yml) builds the image from [`../../image`](../../image) with
`SERVLET_CONTAINER=tomcat` and `BASE_IMAGE=tomcat:9.0-jdk21`, then starts OpenCms together with
MariaDB.

From this directory, run:

```bash
docker compose up -d --build
```
