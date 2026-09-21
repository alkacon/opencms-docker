<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml" encoding="UTF-8" indent="yes"
        doctype-system="http://www.opencms.org/dtd/6.0/opencms-importexport.dtd" />

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()" />
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/opencms/storedcontentdelivery">
        <storedcontentdelivery enabled="false">
            <xsl:copy-of select="enabledsuffixes" />
        </storedcontentdelivery>
        <xsl:if test="not(../sharedcache)">
            <xsl:call-template name="shared-cache-config" />
        </xsl:if>
    </xsl:template>

    <xsl:template match="/opencms/sharedcache">
        <xsl:call-template name="shared-cache-config" />
    </xsl:template>

    <xsl:template name="shared-cache-config">
        <sharedcache enabled="true">
            <cachepolicy>
                <clientmaxage>0</clientmaxage>
                <sharedmaxage>3600</sharedmaxage>
            </cachepolicy>
            <cachepolicy contenttype="image/*">
                <clientmaxage>0</clientmaxage>
                <sharedmaxage>86400</sharedmaxage>
                <staleiferror>604800</staleiferror>
            </cachepolicy>
            <cachepolicy contenttype="audio/*">
                <clientmaxage>0</clientmaxage>
                <sharedmaxage>86400</sharedmaxage>
                <staleiferror>604800</staleiferror>
            </cachepolicy>
            <cachepolicy contenttype="video/*">
                <clientmaxage>0</clientmaxage>
                <sharedmaxage>86400</sharedmaxage>
                <staleiferror>604800</staleiferror>
            </cachepolicy>
        </sharedcache>
    </xsl:template>

</xsl:stylesheet>
