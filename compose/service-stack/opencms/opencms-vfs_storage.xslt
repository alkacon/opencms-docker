<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"
        doctype-system="http://www.opencms.org/dtd/6.0/opencms-vfs.dtd" />

    <xsl:param name="storage_threshold" select="'0'" />

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/opencms/vfs/resources/storage-policy">
        <storage-policy class="org.opencms.db.storage.policy.CmsDefaultStoragePolicy">
            <param name="threshold"><xsl:value-of select="$storage_threshold" /></param>
            <param name="resourceTypeIds">2,3</param>
        </storage-policy>
    </xsl:template>

</xsl:stylesheet>
