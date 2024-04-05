<xsl:stylesheet
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:ee="http://xmlns.jcp.org/xml/ns/javaee"
	xmlns="http://xmlns.jcp.org/xml/ns/javaee" exclude-result-prefixes="ee"
	version="1.0">
	<!-- web.xml changes for Jetty -->

	<xsl:param name="cookie_name" />

	<!-- Insert cookie-config after session-timeout if it doesn't already exist. -->
	<xsl:template
		match="ee:session-config[not(ee:cookie-config)]/ee:session-timeout">
		<xsl:copy-of select="." />
		<xsl:text>&#xa;    </xsl:text>
		<cookie-config>
			<name>
				<xsl:value-of select="$cookie_name" />
			</name>
		</cookie-config>
		<xsl:apply-templates />
	</xsl:template>

    <!--  Insert ExpiresFilter after display-name, so it comes first (if it's not already defined) -->
	<xsl:template
		match="ee:web-app[not(ee:filter[ee:filter-name = 'ExpiresFilter'])]/ee:display-name">
		<xsl:copy-of select="." />
		<filter>
			<filter-name>ExpiresFilter</filter-name>
			<filter-class>org.opencms.main.CmsExportExpiresFilter</filter-class>
		</filter>

		<filter-mapping>
			<filter-name>ExpiresFilter</filter-name>
			<url-pattern>/export/*</url-pattern>
			<dispatcher>REQUEST</dispatcher>
		</filter-mapping>
	</xsl:template>


	<xsl:template match="@* | node()">
		<xsl:copy>
			<xsl:apply-templates select="@* | node()" />
		</xsl:copy>
	</xsl:template>


</xsl:stylesheet>
