# common shell functions for use in other scripts
# (Included via BASH_ENV for noninteractive bash shells and is sourced in .bashrc for interactive ones)

function get_secret() {
    if [ -z "${1+x}" ] || [ -z "${2+x}" ]; then
        echo "Two args required."
        return 1
    fi
    if [[ "$1" != *_FILE ]]; then
        echo "Arg 1 must end with the _FILE suffix."
        return 1
    fi
    local sec_file="$1"
    local sec_env="$2"
    if [[ -n "${!sec_file}" ]]; then
        if [[ -f "${!sec_file}" ]]; then
            local password
            password=$(<"${!sec_file}")
            echo "${password}" | xargs
        else
            echo "File ${sec_file}=${!sec_file} not found."
        fi
    elif [[ -n "${!sec_env}" ]]; then
        echo "${!sec_env}"
    else
        echo "Either ${sec_file} or ${sec_env} must be set."
        return 1
    fi
}

function shell_classpath() {
    if [ "${SERVLET_CONTAINER}" == "tomcat" ]; then
        echo "${OPENCMS_HOME}/WEB-INF/lib/*:${OPENCMS_HOME}/WEB-INF/classes:${TOMCAT_LIB}/*"
    elif [ "${SERVLET_CONTAINER}" == "jetty" ]; then
        # Jetty libraries in OpenCms which are needed for Solr would cause a version conflict with the libraries included in Jetty,
        # so we have to specifically only include the servlet/JSP API libs in the CmsShell classpath.
        local servlet_api
        servlet_api=$(find "${JETTY_LIB}" -maxdepth 1 -name 'jakarta.servlet-api*.jar' | sort -V | head -1)
        echo "${OPENCMS_HOME}/WEB-INF/lib/*:${OPENCMS_HOME}/WEB-INF/classes:${servlet_api}:${JETTY_HOME}/lib/ee10-apache-jsp/*"
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
    cmd="${TOMCAT_HOME}/bin/catalina.sh run >> ${TOMCAT_HOME}/logs/catalina.out 2>&1"
    gosu ${RUN_AS_USER} sh -c "$cmd" &
}

function start_jetty() {
    cd $CONTAINER_BASE
    cmd="java $(jetty_opts) -jar ${JETTY_HOME}/start.jar >> ${CONTAINER_BASE}/jetty.out 2>&1"
    gosu ${RUN_AS_USER} sh -c "$cmd" &
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
        # The servlet container is a grandchild of this shell (gosu ... sh -c), so
        # "wait" would fail with "not a child of this shell" (exit 127). Poll the
        # pid instead and give OpenCms time to shut down cleanly (Solr, indexer).
        # Keep the timeout below the stop_grace_period of the compose service.
        local timeout=80
        local waited=0
        while kill -0 "$pid" 2>/dev/null ; do
            if [ "$waited" -ge "$timeout" ] ; then
                echo "Servlet container (pid $pid) still running after ${timeout}s, giving up."
                return 1
            fi
            sleep 1
            waited=$((waited + 1))
        done
    fi
}

function jetty_opts() {
    local OPTS="-server -Djava.awt.headless=true -XX:-OmitStackTraceInFastThrow -DDISPLAY=:0.0"
    if [ "$DEBUG" == "true" ]; then
        OPTS="$OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=*:8000"
    fi
    OPTS="$OPTS $(cat $CONTAINER_BASE/jetty-opts.txt)"
    echo "$OPTS"
}
