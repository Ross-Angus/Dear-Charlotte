<!DOCTYPE xsl:stylesheet [
	<!ENTITY global-path '/Dear-Charlotte/data/global.xml'>
]>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:import href="global-templates.xslt"/>
	<xsl:output method="html" version="5.1" encoding="utf-8" indent="yes" doctype-system="about:legacy-compat"/>

	<xsl:template match="/">
		<html itemscope="" itemtype="http://schema.org/WebPage" class="no-js">
			<xsl:apply-templates select="/Dear-Charlotte/page/meta" mode="lang"/>
			<head>
				<xsl:apply-templates select="/Dear-Charlotte/page/meta" mode="meta">
					<xsl:with-param name="url"><xsl:value-of select="/page/meta/path"/></xsl:with-param>
				</xsl:apply-templates>
				<link rel="stylesheet" href="/Dear-Charlotte/css/main.css"/>
				<link rel="apple-touch-icon" sizes="180x180" href="/Dear-Charlotte/apple-touch-icon.png"/>
				<link rel="icon" type="image/png" href="/Dear-Charlotte/favicon-32x32.png" sizes="32x32"/>
				<link rel="icon" type="image/png" href="/Dear-Charlotte/favicon-16x16.png" sizes="16x16"/>
				<link rel="manifest" href="/Dear-Charlotte/manifest.json"/>
				<link rel="mask-icon" href="/Dear-Charlotte/safari-pinned-tab.svg" color="#5bbad5"/>
				<meta name="theme-color" content="#000000"/>
				<!--[if lt IE 9]>
				<script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
				<script src="https://oss.maxcdn.com/libs/respond.js/1.3.0/respond.min.js"></script>
				<![endif]-->
			</head>

			<body id="top">

				<aside>

					<!-- Logo -->
					<xsl:apply-templates select="document('&global-path;')/global/nav[@type = 'main']" mode="logo">
						<xsl:with-param name="url"><xsl:value-of select="/page/meta/path"/></xsl:with-param>
					</xsl:apply-templates>
					<h2 class="h6">Dear Charlotte: A Blake's 7 episode guide</h2>

					<!-- Top navigation -->
					<xsl:apply-templates select="document('&global-path;')/global/nav[@type = 'main']" mode="main-nav">
						<xsl:with-param name="url"><xsl:value-of select="/page/meta/path"/></xsl:with-param>
					</xsl:apply-templates>

					<!-- Tagging -->
					<xsl:apply-templates select="document('&global-path;')/global/nav[@type = 'main']//link" mode="tagging">
						<xsl:with-param name="url"><xsl:value-of select="/page/meta/path"/></xsl:with-param>
					</xsl:apply-templates>

				</aside>

				<main>
					<xsl:apply-templates select="/page/meta/type" mode="page-type"/>

					<xsl:apply-templates select="/page/content[@type = 'main']/node()" mode="content"/>

					<!-- Disqusting -->
					<xsl:apply-templates select="document('&global-path;')/global/nav[@type = 'main']" mode="disqus">
						<xsl:with-param name="base-url"><xsl:value-of select="document('&global-path;')/global/meta/base-url"/></xsl:with-param>
						<xsl:with-param name="url"><xsl:value-of select="/page/meta/path"/></xsl:with-param>
					</xsl:apply-templates>

					<footer>
						<!-- Page footer navigation -->
						<xsl:apply-templates select="document('&global-path;')/global/nav[@type = 'main']" mode="footer-nav">
							<xsl:with-param name="url"><xsl:value-of select="/page/meta/path"/></xsl:with-param>
						</xsl:apply-templates>
						<!-- Legal chum -->
						<xsl:apply-templates select="document('&global-path;')/global/nav[@type = 'footer']" mode="legal-nav">
							<xsl:with-param name="url"><xsl:value-of select="/page/meta/path"/></xsl:with-param>
						</xsl:apply-templates>
					</footer>

				</main>

				<script src="https://code.jquery.com/jquery-2.2.4.min.js" integrity="sha256-BbhdlvQf/xTY9gja0Dq3HiwQF8LaCRTXxZKRutelT44=" crossorigin="anonymous"></script>
				<script src="/js/main.js"></script>
			</body>
		</html>
	</xsl:template>

</xsl:stylesheet>
