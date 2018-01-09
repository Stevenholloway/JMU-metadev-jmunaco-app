<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:marc="http://www.loc.gov/MARC21/slim" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    <xsl:output method="xml" indent="yes"/>
    
 <!--   crude but effective xsl for stripping "record" elements and then changing root "collection" to "record." -->
    <xsl:template match="marc:record">
        <xsl:apply-templates select="@*|node()"/>
    </xsl:template>
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="marc:collection">
        <marc:record>
            <xsl:apply-templates select="@*|node()"/>
        </marc:record>
    </xsl:template>
</xsl:stylesheet>