<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  version="1.0">


<!-- Parameter containing the current file name. This is set by OpenCms before calling the XSLT transformation.  -->
<xsl:param name="file" />
<!-- Mandatory. The @dtd@ string is a special macro used by OpenCms to insert the correct DTD reference. -->
<xsl:output doctype-system="@dtd@" indent="yes"  />

<!-- 'Copy' rule used to copy everything that isn't matched by the other rules. -->
<xsl:template match="@* | node()">
  <xsl:copy>
    <xsl:apply-templates select="@* | node()"/>
  </xsl:copy>
</xsl:template>

<!--
==================================================
Set reduced search index configuration
==================================================
-->

<xsl:template match="/opencms/search/indexes">
    <indexes>
        <index class="org.opencms.search.solr.CmsSolrIndex">
            <name>Solr Online</name>
            <rebuild>auto</rebuild>
            <project>Online</project>
            <locale>all</locale>
            <configuration>solr_fields</configuration>
            <sources>
                <source>solr_source</source>
            </sources>
            <param name="search.solr.postProcessor">org.opencms.search.solr.CmsSolrLinkProcessor</param>
        </index>
        <index class="org.opencms.search.solr.CmsSolrIndex">
            <name>Solr Offline</name>
            <rebuild>offline</rebuild>
            <project>Offline</project>
            <locale>all</locale>
            <configuration>solr_fields</configuration>
            <sources>
                <source>solr_source</source>
            </sources>
            <param name="search.solr.postProcessor">org.opencms.search.solr.CmsSolrLinkProcessor</param>
        </index>
    </indexes>    
</xsl:template>

<!-- Insert point -->

</xsl:stylesheet>
