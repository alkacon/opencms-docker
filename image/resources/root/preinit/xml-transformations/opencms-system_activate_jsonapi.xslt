<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0">
    <xsl:param name="jsonapi" select="'false'"/>
    <xsl:output method="xml"
        doctype-system="http://www.opencms.org/dtd/6.0/opencms-system.dtd"
        indent="yes" />

    <!-- 'Copy' rule used to copy everything that isn't matched by the other rules. -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <!--
    =========================================================================
    Add or remove JSON resource init handler
    =========================================================================
    -->
    <xsl:template match="/opencms/system/resourceinit">
        <xsl:copy>
            <xsl:copy-of select="@*" />
	        <xsl:copy-of select="*[@class!='org.opencms.xml.xml2json.CmsJsonResourceHandler']" />
	        <xsl:if test="$jsonapi='true'">
	            <xsl:text>    </xsl:text>
	            <resourceinithandler class="org.opencms.xml.xml2json.CmsJsonResourceHandler" /><xsl:text>&#xa;</xsl:text>
	            <xsl:text>        </xsl:text>
	        </xsl:if>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>