# common shell functions for use in other scripts
# (Included via BASH_ENV for noninteractive bash shells and is sourced in .bashrc for interactive ones)

function shell_classpath() {
    if [ "${SERVLET_CONTAINER}" == "tomcat" ]; then
        echo "${OPENCMS_HOME}/WEB-INF/lib/*:${OPENCMS_HOME}/WEB-INF/classes:${TOMCAT_LIB}/*"
    elif [ "${SERVLET_CONTAINER}" == "jetty" ]; then
        # Jetty libraries in OpenCms which are needed for Solr would cause a version conflict with the libraries included in Jetty,
        # so we have to specifically only include the servlet/JSP API libs in the CmsShell classpath.
        local SERVLET_API=$(find ${JETTY_LIB} -maxdepth 1 -name 'jetty-servlet-api*.jar' | head -1)
        echo "${OPENCMS_HOME}/WEB-INF/lib/*:${OPENCMS_HOME}/WEB-INF/classes:$SERVLET_API:${JETTY_HOME}/lib/ee8-apache-jsp/*"
    fi
}

function start_container() {
    if [ "${SERVLET_CONTAINER}" == "tomcat" ] ; then
        start_tomcat
    elif [ "${SERVLET_CONTAINER}" == "jetty" ] ; then
        start_jetty
    fi
}

function start_tomcat() {
    ${TOMCAT_HOME}/bin/catalina.sh run >> ${TOMCAT_HOME}/logs/catalina.out 2>&1 &
}

function start_jetty() {
    cd $CONTAINER_BASE
    java $(jetty_opts) -jar $JETTY_HOME/start.jar >> ${CONTAINER_BASE}/jetty.out 2>&1 &
}

function kill_container() {
    local pid=""
    if [ -d $TOMCAT_HOME ] ; then
        pid=$(pgrep -f org.apache.catalina.startup.Bootstrap)
    else
        pid=$(pgrep -f $JETTY_HOME/start.jar)
    fi
    if [[ ! -z "$pid" ]] ; then
        kill -TERM "$pid"
        wait "$pid" >/dev/null
    fi
}

function jetty_opts() {
    local OPTS="-server -Djava.awt.headless=true -XX:-OmitStackTraceInFastThrow -DDISPLAY=:0.0"
    if [ "$DEBUG" == "true" ]; then
        OPTS="$OPTS -Xdebug -Xnoagent -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=*:8000 -Djava.compiler=NONE"
    fi
    OPTS="$OPTS $(cat $CONTAINER_BASE/jetty-opts.txt)"
    echo "$OPTS"
}



