<!DOCTYPE xsl:stylesheet [
	<!ENTITY global-path '/Dear-Charlotte/data/global.xml'>
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import href="/Dear-Charlotte/xslt/global-templates.xsl"/>
	<xsl:output method="xml" encoding="utf-8" indent="yes" media-type="text/xml"/>

	<xsl:template match="/">
		&lt;urlset
			xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd"&gt;
			<xsl:apply-templates select="document('&global-path;')//link"/>
		&lt;/urlset&gt;
	</xsl:template>

	<xsl:template match="link">
		<!-- Not Twitter -->
		<xsl:if test="not(starts-with(@url,'http'))">
			&lt;url&gt;
				&lt;loc&gt;<xsl:value-of select="document('&global-path;')//base-url"/><xsl:value-of select="@url"/>&lt;/loc&gt;
				&lt;priority&gt;
					<xsl:choose>
						<xsl:when test="count(ancestor::*) = 3">1</xsl:when>
						<xsl:when test="count(ancestor::*) = 2">0</xsl:when>
						<xsl:otherwise>0.5</xsl:otherwise>
					</xsl:choose>
				&lt;/priority&gt;
			&lt;/url&gt;
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
