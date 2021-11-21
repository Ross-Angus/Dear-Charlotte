<!DOCTYPE xsl:stylesheet [
	<!ENTITY global-path '/data/global.xml'>
]>
<!--
* * * * * * * * * * * * * * * * * * * * * * * * * * * *
* The above !ENTITYs are a bit like global variables, *
* in that you can use them wherever you like in the   *
* XSLT, to replace a string. They work like this:     *
* <!ENTITY example 'This is a string'>                *
* &example; => This is a string                       *
* This will also work for XPATHs:                     *
* <!ENTITY description '/page/meta/description'>      *
* &description; => /page/meta/description             *
* * * * * * * * * * * * * * * * * * * * * * * * * * * *
-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="html" version="5.1" encoding="utf-8" indent="yes" doctype-system="about:legacy-compat"/>
	<xsl:variable name="lower" select="'abcdefghijklmnopqrstuvwxyz'"/>
	<xsl:variable name="upper" select="'ABCDEFGHIJKLMNOPQRSTUVWXYZ'"/>
	<!-- A non-exhaustive list of characters which aren't the alphabet, or numbers. It's use for the FAQ template and for creating the ID attribute on character biogs. -->
	<xsl:variable name="nonalphanum" select="' ?#:/\'"/>

	<!--
	* * * * * * * * * * * * * * * * * * *
	* Site title - used in the <head/>  *
	* * * * * * * * * * * * * * * * * * *
	-->
	<xsl:variable name="site-title">
		<xsl:choose>
			<xsl:when test="normalize-space(document('&global-path;')/global/meta/site-title) != ''">
				<xsl:value-of select="normalize-space(document('&global-path;')/global/meta/site-title)"/>
			</xsl:when>
			<xsl:otherwise>No site name found. Please add one to global.xml.</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

    <!--
    * * * * * * * * * * * * * * * *
    * Just the logo, to ensure we *
    * don't got no recursive      *
    * links.                      *
    * * * * * * * * * * * * * * * *
    -->
    <xsl:template match="nav" mode="logo">
        <xsl:param name="url"/>
        <xsl:variable name="logo-name">Terran Federation</xsl:variable>
        <p itemscope="" itemtype="http://schema.org/Organization">
            <xsl:choose>
                <!-- When we're on the home page, don't make a recursive link. -->
                <xsl:when test="$url = '/'">
                    <strong class="logo-terran-federation shape" title="{$logo-name}"><i class="sr-only" itemprop="name"><xsl:value-of select="$logo-name"/></i></strong>
                </xsl:when>
                <xsl:otherwise>
                    <a href="/" class="logo-terran-federation shape" title="Return to home page"><i class="sr-only" itemprop="name"><xsl:value-of select="$logo-name"/></i></a>
                </xsl:otherwise>
            </xsl:choose>
        </p>
    </xsl:template>

	<!--
	* * * * * * * * * * * * * * * *
	* Top-level navigation links  *
	* * * * * * * * * * * * * * * *
	-->
	<xsl:template match="nav" mode="main-nav">
		<xsl:param name="url"/>
		<nav aria-label="{@title}" itemscope="" itemtype="https://schema.org/SiteNavigationElement">
			<xsl:if test="normalize-space(@class) != ''">
				<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
			</xsl:if>
			<ul>
				<!-- Just the top-level navigation -->
				<xsl:for-each select="link">
					<li>
						<xsl:call-template name="paternity-test">
							<xsl:with-param name="url"><xsl:value-of select="$url"/></xsl:with-param>
						</xsl:call-template>
						<!-- Child links will only display if this is the current section -->
						<xsl:if test="descendant-or-self::link[@url = $url]">
							<xsl:call-template name="next-nav">
								<xsl:with-param name="url"><xsl:value-of select="$url"/></xsl:with-param>
							</xsl:call-template>
						</xsl:if>
					</li>
				</xsl:for-each>
			</ul>
		</nav>
	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * *
	* Second-level mega-menu links and beyond *
	* * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="link" name="next-nav">
		<xsl:param name="url"/>
		<!-- Is there any child links to write out? -->
		<xsl:if test="link">
			<ul>
				<xsl:for-each select="link">
					<li>
						<xsl:call-template name="paternity-test">
							<xsl:with-param name="url"><xsl:value-of select="$url"/></xsl:with-param>
						</xsl:call-template>
						<xsl:call-template name="next-nav">
							<xsl:with-param name="url"><xsl:value-of select="$url"/></xsl:with-param>
						</xsl:call-template>
					</li>
				</xsl:for-each>
			</ul>
		</xsl:if>
	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * *
	* This handles the state of individual links  *
	* in the main navigation.                     *
	* * * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="link" name="paternity-test">
    	<xsl:param name="url"/>
    	<xsl:choose>
    		<!-- When we are on the current page, because recursive links are a bad idea. No, really. -->
    		<xsl:when test="@url = $url">
    			<em title="You are here"><xsl:value-of select="@text"/></em>
    		</xsl:when>
    		<!-- When the current page is a child of the current node -->
    		<xsl:when test="descendant::link[@url = $url]">
    			<em><xsl:apply-templates select="."/></em>
    		</xsl:when>
    		<!-- Normal link -->
    		<xsl:otherwise>
				<xsl:apply-templates select="."/>
    		</xsl:otherwise>
    	</xsl:choose>
    </xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * *
	* Just anchor tags and all their attributes *
	* * * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="link">
		<a>
			<xsl:if test="normalize-space(@url) != ''">
				<xsl:attribute name="itemprop">url</xsl:attribute>
				<xsl:attribute name="href"><xsl:value-of select="@url"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="normalize-space(@target) != ''">
				<xsl:attribute name="target"><xsl:value-of select="@target"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="normalize-space(@onclick) != ''">
				<xsl:attribute name="onclick"><xsl:value-of select="@onclick"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="normalize-space(@class) != ''">
				<xsl:attribute name="class"><xsl:value-of select="@class"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="normalize-space(@id) != ''">
				<xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
			</xsl:if>
			<xsl:if test="normalize-space(@shape) != ''">
				<i class="shape {@shape}"><xsl:value-of select="''"/></i>
				<xsl:text> </xsl:text>
			</xsl:if>
			<xsl:if test="normalize-space(@text) != ''">
				<span itemprop="name"><xsl:value-of select="@text"/></span>
			</xsl:if>
		</a>
	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * *
	* The language attribute, on the <html/> element  *
	* * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="meta" mode="lang">
		<xsl:attribute name="lang">
			<xsl:choose>
				<!-- Is there a language attribute in this page file? -->
				<xsl:when test="normalize-space(language) != ''">
					<xsl:value-of select="normalize-space(language)"/>
				</xsl:when>
				<!-- Pull the language from the global file -->
				<xsl:otherwise>
					<xsl:value-of select="normalize-space(document('&global-path;')/global/meta/language)"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* This finds the current page in the navigation, then writes out a list of tags *
	* associated with that page in global.xml.                                      *
	* Each one of those tags is a link. When the user clicks on one of these links, *
	* they will see a list of pages which also shares that tag.                     *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="link" mode="tagging">
		<xsl:param name="url"/>
		<xsl:if test="@url = $url">
			<nav aria-label="Tags" class="tags">
				<h2 class="h4">Tags</h2>
				<xsl:choose>
					<xsl:when test="count(tag) &gt; 0">
						<ul>
							<!-- Each tag on the current page -->
							<xsl:for-each select="tag">
								<!-- Take the <tag/> value. Make it lower-case. Remove all the mad white space. Replace remaining spaces with hyphens. -->
								<li class="js-tooltip">
									<input type="radio" name="tags" id="tag-{translate(normalize-space(translate(.,$upper,$lower)),' ','-')}" class="toggle"/>
									<label for="tag-{translate(normalize-space(translate(.,$upper,$lower)),' ','-')}"><xsl:value-of select="."/></label>
									<section class="details">
										<h2 class="h4">Other pages which use the <q><xsl:value-of select="normalize-space(.)"/></q> tag</h2>
										<xsl:choose>
											<xsl:when test="count(//tag[text() = current()]) &gt; 1">
												<ul>
													<!-- All links from the navigation which aren't the current page, and have at least one tag. -->
													<xsl:apply-templates mode="tag-links" select="//link[not(@url = $url) and tag]">
														<xsl:with-param name="tag"><xsl:value-of select="normalize-space(.)"/></xsl:with-param>
													</xsl:apply-templates>
												</ul>
											</xsl:when>
											<xsl:otherwise>
												<p>No other pages share this tag.</p>
											</xsl:otherwise>
										</xsl:choose>
									</section>
								</li>
							</xsl:for-each>
						</ul>
					</xsl:when>
					<xsl:otherwise>
						<p>This page does not have any tags.</p>
					</xsl:otherwise>
				</xsl:choose>
			</nav>

		</xsl:if>
	</xsl:template>

	<!-- This finds other <link/> nodes with matching tags to whatever is passed into it. -->
	<xsl:template match="link" mode="tag-links">
		<xsl:param name="tag"/>
		<xsl:param name="url"><xsl:value-of select="@url"/></xsl:param>
		<xsl:param name="text"><xsl:value-of select="@text"/></xsl:param>
		<xsl:for-each select="tag">
			<xsl:if test="normalize-space(.) = $tag">
				<li><a href="{$url}"><xsl:value-of select="$text"/></a></li>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>

	<!--
	* * * * * * * * * * * *
	* Meta and title tags *
	* * * * * * * * * * * *
	-->
	<xsl:template match="meta" mode="meta">
		<xsl:param name="url"/>

		<xsl:variable name="site-title" select="document('&global-path;')/global/meta/site-title"/>
		<xsl:variable name="page-title">
			<xsl:choose>
				<!-- Do we have a page title in the page XML file? -->
				<xsl:when test="normalize-space(title) != ''">
					<xsl:value-of select="title"/>
				</xsl:when>
				<!-- Otherwise get it from the navigation XML -->
				<xsl:otherwise>
					<xsl:value-of select="document('&global-path;')//link[@url = $url]/@text"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<title>
			<xsl:value-of select="$page-title"/>
			<!-- Does the site itself have a title? Is it different to the current page title? -->
			<xsl:if test="normalize-space($site-title) != '' and normalize-space($site-title) != normalize-space($page-title)">
				 - <xsl:value-of select="normalize-space($site-title)"/>
			</xsl:if>
		</title>

		<!-- Description - used in multiple places -->
		<xsl:variable name="description">
			<xsl:choose>
				<!-- Does the description node exist in the page level xml?
				Note that it's valid for this node to exist and be blank -
				this means that no description should be displayed. -->
				<xsl:when test="normalize-space(description) != ''"><xsl:value-of select="description"/></xsl:when>
				<!-- Does global.xml have a description? -->
				<xsl:when test="normalize-space(document('&global-path;')/global/meta/description) != ''">
					<xsl:value-of select="document('&global-path;')/global/meta/description"/>
				</xsl:when>
			</xsl:choose>
		</xsl:variable>

		<!-- You don't *have* to add a description -->
		<xsl:if test="normalize-space($description) != ''">
			<meta name="description" content="{$description}"/>
			<meta property="og:description" content="{$description}"/>
		</xsl:if>

		<xsl:if test="normalize-space($page-title) != ''">
			<meta property="og:title" content="{$page-title}"/>
		</xsl:if>

		<xsl:variable name="base-url">
			<xsl:if test="normalize-space(document('&global-path;')/global/meta/base-url) != ''">
				<xsl:value-of select="document('&global-path;')/global/meta/base-url"/>
			</xsl:if>
		</xsl:variable>

		<xsl:if test="normalize-space(document('&global-path;')/global/meta/open-graph-type) != ''">
			<meta property="og:type" content="{normalize-space(document('&global-path;')/global/meta/open-graph-type)}"/>
		</xsl:if>

		<xsl:if test="normalize-space($base-url) != ''">
			<meta property="og:url">
				<xsl:attribute name="content">
					<!-- From the global variables -->
					<xsl:value-of select="$base-url"/>
					<!-- From the local file -->
					<xsl:value-of select="path"/>
				</xsl:attribute>
			</meta>
			<link rel="canonical">
				<xsl:attribute name="href">
					<!-- From the global variables -->
					<xsl:value-of select="$base-url"/>
					<!-- From the local file -->
					<xsl:value-of select="path"/>
				</xsl:attribute>
			</link>
		</xsl:if>
		<xsl:if test="normalize-space(document('&global-path;')/global/meta/site-image) != ''">
			<meta property="og:image" content="{$base-url}{normalize-space(document('&global-path;')/global/meta/site-image)}"/>
		</xsl:if>
		<xsl:if test="normalize-space($site-title) != ''">
			<meta property="og:site_name" content="{$site-title}"/>
		</xsl:if>
		<xsl:if test="normalize-space(document('&global-path;')/global/meta/facebook-id) != ''">
			<meta property="fb:admins" content="{normalize-space(document('&global-path;')/global/meta/facebook-id)}"/>
		</xsl:if>
		<xsl:if test="normalize-space(document('&global-path;')/global/meta/charset) != ''">
			<meta charset="{normalize-space(document('&global-path;')/global/meta/charset)}"/>
		</xsl:if>
		<xsl:if test="normalize-space(document('&global-path;')/global/meta/viewport) != ''">
			<meta name="viewport" content="{normalize-space(document('&global-path;')/global/meta/viewport)}"/>
		</xsl:if>
		<xsl:if test="normalize-space(document('&global-path;')/global/meta/X-UA-Compatible) != ''">
			<meta http-equiv="X-UA-Compatible" content="{normalize-space(document('&global-path;')/global/meta/X-UA-Compatible)}"/>
		</xsl:if>
		<xsl:if test="normalize-space(document('&global-path;')/global/meta/HandheldFriendly) != ''">
			<meta name="HandheldFriendly" content="{normalize-space(document('&global-path;')/global/meta/HandheldFriendly)}"/>
		</xsl:if>

	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* This adds microformats to the <main/>. Content can take the *
	* form of an episode.                                         *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="type" mode="page-type">
		<xsl:if test="normalize-space(.) = 'episode'">
			<xsl:attribute name="itemtype">http://schema.org/TVEpisode</xsl:attribute>
			<xsl:attribute name="itemscope"><xsl:value-of select="''"/></xsl:attribute>
		</xsl:if>
	</xsl:template>

	<!--
	* * * * * * * * * * * * * * *^* * * * * * * * * * * * * * * * *
	* This adds the "< Previous Top Next >" links at the bottom   *
	* of each page, plus the legal chaff under that.              *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="nav" mode="footer-nav">
		<xsl:param name="url"/>

		<p aria-label="Page" itemscope="" itemtype="https://schema.org/SiteNavigationElement" role="navigation" class="footer-nav clearfix">

			<!-- There should be only one -->
			<xsl:for-each select="//link[@url = $url]">

				<!-- < Previous -->
				<xsl:choose>
					<xsl:when test="normalize-space(preceding-sibling::link[1]/@text) = ''">
						<del class="point-left">You are on the first page</del>
					</xsl:when>
					<xsl:otherwise>
						<a href="{normalize-space(preceding-sibling::link[1]/@url)}" class="point-left" title="Previous page"><xsl:value-of select="preceding-sibling::link[1]/@text"/></a>
					</xsl:otherwise>
				</xsl:choose>

				<!-- ^ Top -->
				<a href="#top" class="point-up" title="Return to the top of the page">Top</a>

				<!-- Next > -->
				<xsl:choose>
					<xsl:when test="normalize-space(following-sibling::link[1]/@text) = ''">
						<del class="point-right">You are on the last page</del>
					</xsl:when>
					<xsl:otherwise>
						<a href="{normalize-space(following-sibling::link[1]/@url)}" class="point-right" title="Next page"><xsl:value-of select="following-sibling::link[1]/@text"/></a>
					</xsl:otherwise>
				</xsl:choose>

			</xsl:for-each>
		</p><!-- .footer-nav -->

	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* This adds links to the boring pages which no sane person    *
	* would give two hoots about.                                 *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="nav" mode="legal-nav">
		<xsl:param name="url"/>
		<p aria-label="{@title}" role="contentinfo" itemscope="" itemtype="https://schema.org/SiteNavigationElement" class="legal-nav">
			<xsl:for-each select="link">
				<xsl:call-template name="paternity-test">
					<xsl:with-param name="url"><xsl:value-of select="$url"/></xsl:with-param>
				</xsl:call-template>
			</xsl:for-each>
		</p>
	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* This is used to copy content from the original XML. This    *
	* output is then passed to any of the templates below which   *
	* have a mode of "content", so that custom tags can be        *
	* intercepted, then replaced. For more information, see:      *
	* http://www.xmlplease.com/xsltidentity                       *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
	<xsl:template match="@*|node()" mode="content">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="content"/>
		</xsl:copy>
	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* This looks for the custom tags <ross/> and <char/> and      *
	*  replaces them with  proper markup.                           *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="ross" mode="content">
		<aside class="ross">
			<!-- Allows one to jump to a particular comment on a particular page -->
			<xsl:attribute name="id">trundles-comment-<xsl:number count="ross" level="any"/></xsl:attribute>
			<div class="clearfix">
				<xsl:apply-templates select="node()" mode="content"/>
			</div>
		</aside>
    </xsl:template>

    <xsl:template match="char" mode="content">
		<aside class="charlotte">
			<!-- Allows one to jump to a particular comment on a particular page -->
			<xsl:attribute name="id">charlotte-comment-<xsl:number count="char" level="any"/></xsl:attribute>
			<div class="clearfix">
				<xsl:apply-templates select="node()" mode="content"/>
			</div>
		</aside>
    </xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* This looks for the custom tag <youtube id="[YouTube id]"/>  *
	* and replaces it with proper markup.                         *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="youtube" mode="content">
		<p><iframe width="900" height="445" src="https://www.youtube.com/embed/{@id}" frameborder="0" allowfullscreen=""></iframe></p>
    </xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * *
	* This looks for the custom tag <note/>     *
	* and replaces it with proper markup.       *
	* The <note/> tag can include markup, but   *
	* is happier with inline tags, rather than  *
	* headings and paragraphs. The text value   *
	* of the note is replicated in the title    *
	* attribute, for older browsers.            *
	* To do: if a <jargon/> tag is used inside  *
	* <note/> content, it is omitted from the   *
	* title attribute. Perhaps a mode like      *
	* content, but which sort of flattens out   *
	* the HTML.                                 *
	* * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="note" mode="content">
    	<sup title="{.}" class="js-tooltip">
    		<xsl:variable name="note-no"><xsl:number count="note" level="any"/></xsl:variable>
			<label for="note{$note-no}">&#10054;</label>
			<input type="checkbox" id="note{$note-no}" class="toggle"/>
			<span class="details"><xsl:apply-templates select="node()" mode="content"/></span>
		</sup>
    </xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* This takes the question and answer set from the XML and builds up a series of jump-links  *
	* and some show/hide questions and answers.                                                 *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="faqs" mode="content">
    	<section class="faq">
    		<header>
    			<ul>
	    			<xsl:for-each select="faq/question">
	    				<li>
	    					<a href="#{translate(translate(normalize-space(.),$upper,$lower),$nonalphanum,'')}">
	    						<xsl:apply-templates select="node()" mode="content"/>
	    					</a>
	    				</li>
	    			</xsl:for-each>
	    		</ul>
    		</header>
    		<article>
    			<xsl:for-each select="faq">
	    			<section id="{translate(translate(normalize-space(question),$upper,$lower),$nonalphanum,'')}" itemscope="" itemtype="http://schema.org/Question">
						<h1 class="h3">
							<label for="answer{position()}" itemprop="text">
								<xsl:apply-templates select="question/node()" mode="content"/>
							</label>
						</h1>
						<input type="checkbox" id="answer{position()}" class="toggle"/>
						<!-- This assumes that there will only be inline HTML in the XML.
						You may need block elements in there too. -->
						<p class="details" itemprop="suggestedAnswer">
							<xsl:apply-templates select="answer/node()" mode="content"/>
						</p>
					</section>
				</xsl:for-each>
			</article>
		</section>
    </xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* This looks for the custom tag <jargon type="HTML"/> and *
	* supplies the correct <abbr/> markup for it.             *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="jargon" mode="content">
    	<!-- The user can type in <jargon type="HTML"/> or <jargon type="html"/>, or any mix of the two.
    	Note that the case used in the type attribute will be output unchanged into the page. -->
    	<xsl:variable name="type"><xsl:value-of select="translate(@type,$lower,$upper)"/></xsl:variable>
    	<!-- This tracks how many jargon tags of each type are on the page. -->
    	<xsl:variable name="jargon-order"><xsl:number count="jargon[translate(@type,$lower,$upper) = $type]" level="any"/></xsl:variable>
		<abbr>
			<!-- Best practice suggests that for the benefit of speech browsers, only the first
			instance of a particular <abbr/> should have the abbreviation spelt out to the user.
			After that point, having the string wrapped in an <abbr/> will stop the speech
			browser from trying to pronounce the string out loud. -->
			<xsl:if test="$jargon-order = 1">
				<xsl:attribute name="title">
					<xsl:choose>
						<xsl:when test="$type = 'AKA'    ">Also Known As</xsl:when>
						<xsl:when test="$type = 'AGRO'   ">aggressive</xsl:when>
						<xsl:when test="$type = 'AI'     ">Artifical Inteligence</xsl:when>
						<xsl:when test="$type = 'AF'     ">As fuck</xsl:when>
						<xsl:when test="$type = 'BBC'    ">British Broadcasting Corporation</xsl:when>
						<xsl:when test="$type = 'BDSM'   ">Bondage and Discipline, Sadism and Masochism</xsl:when>
						<xsl:when test="$type = 'BEM'    ">Bug Eyed Monster</xsl:when>
						<xsl:when test="$type = 'CCTV'   ">Closed-circuit television</xsl:when>
						<xsl:when test="$type = 'CDN'    ">Content Delivery Network</xsl:when>
						<xsl:when test="$type = 'CMS'    ">Content Management System</xsl:when>
						<xsl:when test="$type = 'CRT'    ">Cathode Ray Tube</xsl:when>
						<xsl:when test="$type = 'CSS'    ">Cascading Style Sheet</xsl:when>
						<xsl:when test="$type = 'CV'     ">Curriculum Vitae</xsl:when>
						<xsl:when test="$type = 'DIY'    ">Do It Yourself</xsl:when>
						<xsl:when test="$type = 'DVD'    ">Digital Versatile Disc</xsl:when>
						<xsl:when test="$type = 'EBE'    ">Electronic Brain Enhancement</xsl:when>
						<xsl:when test="$type = 'ECG'    ">electrocardiogram</xsl:when>
						<xsl:when test="$type = 'ETC'    ">et cetera</xsl:when>
						<xsl:when test="$type = 'FAQ'    ">Frequently Asked Questions</xsl:when>
						<xsl:when test="$type = 'GDPR'   ">General Data Protection Regulation</xsl:when>
						<xsl:when test="$type = 'HMS'    ">Her/His Majesty's Ship</xsl:when>
						<xsl:when test="$type = 'HTML'   ">HyperText Markup Language</xsl:when>
						<xsl:when test="$type = 'HTTP'   ">HyperText Transfer Protocol</xsl:when>
						<xsl:when test="$type = 'HQ'     ">Head Quarters</xsl:when>
						<xsl:when test="$type = 'ID'     ">Identification</xsl:when>
						<xsl:when test="$type = 'IE'     ">Internet Explorer</xsl:when>
						<xsl:when test="$type = 'IMDB'   ">Internet Movie Database</xsl:when>
						<xsl:when test="$type = 'ISO'    ">International Organization for Standardization</xsl:when>
						<xsl:when test="$type = 'ISP'    ">Internet Service Provider</xsl:when>
						<xsl:when test="$type = 'LA'     ">Los Angeles</xsl:when>
						<xsl:when test="$type = 'L33T'   ">Elite</xsl:when>
						<xsl:when test="$type = 'MIT'    ">Massachusetts Institute of Technology</xsl:when>
						<xsl:when test="$type = 'MOT'    ">Ministry of Transport</xsl:when>
						<xsl:when test="$type = 'MM'     ">Millimeter</xsl:when>
						<xsl:when test="$type = 'NASA'   ">National Aeronautics and Space Administration</xsl:when>
						<xsl:when test="$type = 'OAPEC'  ">Organization of Arab Petroleum Exporting Countries</xsl:when>
						<xsl:when test="$type = 'PNG'    ">Portable Network Graphic</xsl:when>
						<xsl:when test="$type = 'RADA'   ">The Royal Academy of Dramatic Art</xsl:when>
						<xsl:when test="$type = 'R&amp;D'">Research and Development</xsl:when>
						<xsl:when test="$type = 'RP'     ">Received Pronunciation</xsl:when>
						<xsl:when test="$type = 'PR'     ">Public Relations</xsl:when>
						<xsl:when test="$type = 'SCI-FI' ">Science Fiction</xsl:when>
						<xsl:when test="$type = 'SWAT'   ">Special Weapons and Tactics</xsl:when>
						<xsl:when test="$type = 'SLR'    ">Single Lens Reflex</xsl:when>
						<xsl:when test="$type = 'SEO'    ">Search Engine Optimisation</xsl:when>
						<xsl:when test="$type = 'SIC'    ">sic erat scriptum (thus it had been written)</xsl:when>
						<xsl:when test="$type = 'TARDIS' ">Time And Relative Dimension In Space</xsl:when>
						<xsl:when test="$type = 'TMS'    ">Trippy montage sequence</xsl:when>
						<xsl:when test="$type = 'TV'     ">Television</xsl:when>
						<xsl:when test="$type = 'UFO'    ">Unidentified Flying Object</xsl:when>
						<xsl:when test="$type = 'UNIT'   ">United Nations Intelligence Taskforce</xsl:when>
						<xsl:when test="$type = 'UK'     ">United Kingdom</xsl:when>
						<xsl:when test="$type = 'USA'    ">United States of America</xsl:when>
						<xsl:when test="$type = 'URI'    ">Uniform Resource Identifier</xsl:when>
						<xsl:when test="$type = 'URL'    ">Uniform Resource Locator</xsl:when>
						<xsl:when test="$type = 'USA'    ">United States of America</xsl:when>
						<xsl:when test="$type = 'USB'    ">Universal Serial Bus</xsl:when>
						<xsl:when test="$type = 'VR'     ">Virtual Reality</xsl:when>
						<xsl:when test="$type = 'VHS'    ">Video Home System</xsl:when>
						<xsl:when test="$type = 'WWE'    ">World Wrestling Entertainment</xsl:when>
						<xsl:when test="$type = 'XML'    ">Extensible Markup Language</xsl:when>
						<xsl:when test="$type = 'XSLT'   ">Extensible Stylesheet Language Transformations</xsl:when>
						<xsl:when test="$type = 'YTS'    ">Youth Training Scheme</xsl:when>
						<xsl:otherwise>acronym not found</xsl:otherwise>
					</xsl:choose>
				</xsl:attribute>
			</xsl:if>
			<xsl:value-of select="@type"/>
		</abbr>
    </xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * *
	* This looks for the custom tag <biog/>     *
	* and makes a sort of trump card thing for  *
	* one of the charactors.                    *
	* * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="biog" mode="content">
    	<figure class="biog" itemscope="" itemtype="https://schema.org/character" id="{translate(translate(normalize-space(info[@type='Name']),$upper,$lower),$nonalphanum,'------')}">
    		<!-- Because we don't *have* to have an image (but it would be nice) -->
			<xsl:if test="normalize-space(src) != ''">
				<img src="{normalize-space(src)}" itemprop="image">
					<xsl:attribute name="alt"><xsl:value-of select="info[@type='Name']"/></xsl:attribute>
				</img>
			</xsl:if>
			<xsl:for-each select="info">
				<dl class="clearfix">
					<dt><xsl:value-of select="@type"/></dt>
					<dd>
						<xsl:choose>
							<xsl:when test="starts-with('name',translate(@type, $upper,$lower))"><xsl:attribute name="itemprop">name</xsl:attribute></xsl:when>
							<xsl:when test="starts-with('job',translate(@type, $upper,$lower))"><xsl:attribute name="itemprop">jobTitle</xsl:attribute></xsl:when>
							<xsl:when test="starts-with('partner',translate(@type, $upper,$lower))"><xsl:attribute name="itemprop">spouse</xsl:attribute></xsl:when>
						</xsl:choose>
						<xsl:apply-templates select="node()" mode="content"/>
					</dd>
				</dl>
			</xsl:for-each>
			<p class="logo-terran-federation shape"><i class="sr-only">Terran Federation</i></p>
		</figure>
    </xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * *
	* This embeds the Disqus commenting system, *
	* with a param of the URL of the current    *
	* page passed to the JavaScript.            *
	* * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="nav" mode="disqus">
		<xsl:param name="base-url"/>
		<xsl:param name="url"/>

		<!-- We only want to add a discussion thread if the
		page in question is in the navigation. -->
		<xsl:if test="normalize-space(//link[@url = $url]/@text) != ''">
			<footer class="comments">
				<p><a href="#disqus_thread" class="toggle-link point-down js-disqus" data-open="Show comments" data-close="Hide comments">Show comments (Disqus)</a></p>
				<div id="disqus_thread" class="js-hide"></div>
				<script>
					pageUrl = '<xsl:value-of select="$base-url"/><xsl:value-of select="$url"/>';
					padeID = '<xsl:value-of select="translate(translate(normalize-space(//link[@url = $url]/@text),$upper,$lower),$nonalphanum,'')"/>';
				</script>
			</footer>
		</xsl:if>

	</xsl:template>

	<!--
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	* Because the HTML is not entitised in the XML, this template entitises it, so it can *
	* be seen inside a <pre/> tag. You can use it like this:                              *
	* <pre><code class="html"><xsl:apply-templates mode="verb" select="."/></code></pre>  *
	* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
	-->
    <xsl:template match="*|@*" mode="verb">
        <xsl:variable name="node-type">
            <xsl:call-template name="node-type"/>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$node-type='element'"> <!-- element -->
                <xsl:text>&lt;</xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:apply-templates select="@*" mode="verb"/>
                <xsl:text>&gt;</xsl:text>
                <xsl:apply-templates mode="verb"/>
                <xsl:text>&lt;/</xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text>&gt;</xsl:text>
            </xsl:when>
            <xsl:when test="$node-type='text'"> <!-- text -->
                <xsl:value-of select="self::text()"/>
            </xsl:when>
            <xsl:when test="$node-type='attribute'"> <!--any attribute-->
                <xsl:text> </xsl:text>
                <xsl:value-of select="name()"/>
                <xsl:text>="</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>"</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="node-type">
        <xsl:param name="node" select="."/>
        <xsl:apply-templates mode="nodetype" select="$node"/>
    </xsl:template>
    <xsl:template mode="nodetype" match="*">element</xsl:template>
    <xsl:template mode="nodetype" match="@*">attribute</xsl:template>
    <xsl:template mode="nodetype" match="text()">text</xsl:template>

</xsl:stylesheet>
