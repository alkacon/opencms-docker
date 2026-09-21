<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"
        doctype-system="http://www.opencms.org/dtd/6.0/opencms-system.dtd" />

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/opencms/system/flexcache[not(../imagecache)]">
        <xsl:copy-of select="." />
        <imagecache>
            <retention mode="fixed" max-age="P60D" />
        </imagecache>
    </xsl:template>

</xsl:stylesheet>
