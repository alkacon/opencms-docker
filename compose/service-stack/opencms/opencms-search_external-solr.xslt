<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"
        doctype-system="http://www.opencms.org/dtd/6.0/opencms-search.dtd" />

    <xsl:param name="solr_url" select="'http://solr:8983/solr'" />

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/opencms/search/solr">
        <xsl:copy>
            <xsl:copy-of select="@*[name() != 'serverUrl']" />
            <xsl:attribute name="serverUrl"><xsl:value-of select="$solr_url" /></xsl:attribute>
            <xsl:apply-templates select="node()" />
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
