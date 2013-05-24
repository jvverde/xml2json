<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="text"  encoding="UTF-8" media-type="text/plain" omit-xml-declaration="yes"/>
	<xsl:template match="/*" priority="5">
		<xsl:text>{</xsl:text>
		<xsl:apply-templates select="*|@*"/>
		<!-- text node always appers last -->	
		<xsl:apply-templates select="text()[normalize-space(.) != ''][last()]"/>
		<xsl:text>
}</xsl:text>
	</xsl:template>

	<!-- single elements --> 
	<xsl:template match="*[not(following-sibling::*[name() = name(current())]) and not(preceding-sibling::*[name() = name(current())])]">
		<xsl:apply-templates select="." mode="tab"/>	 
		<xsl:text>"</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text>" : </xsl:text>
		<xsl:apply-templates select="." mode="value"/>
		<xsl:apply-templates select="." mode="separator"/>
	</xsl:template>
	
	<!-- first of multiples elements -->
	<xsl:template match="*[following-sibling::*[name() = name(current())] and not(preceding-sibling::*[name() = name(current())])]">
		<xsl:apply-templates select="." mode="tab"/>
		<xsl:text>"</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text>" :[ </xsl:text>
		<xsl:apply-templates select="." mode="value"/>
		<xsl:apply-templates select="." mode="separator"/>
	</xsl:template>

	<!-- last of multiples elements -->
	<xsl:template match="*[not(following-sibling::*[name() = name(current())]) and preceding-sibling::*[name() = name(current())]]">
		<xsl:apply-templates select="." mode="tab"/>
		<xsl:apply-templates select="." mode="value"/>
		<xsl:text>]</xsl:text>
		<xsl:apply-templates select="." mode="separator"/>
	</xsl:template>

	<!-- multiples elements except the first and last -->
	<xsl:template match="*">
		<xsl:apply-templates select="." mode="tab"/>
		<xsl:apply-templates select="." mode="value"/>
		<xsl:apply-templates select="." mode="separator"/>
	</xsl:template>


	<xsl:template match="@*">
		<xsl:for-each select="../@*[. != current()]">
			<xsl:apply-templates select="." mode="xpto"/>
			<xsl:apply-templates select="." mode="separator"/>
		</xsl:for-each>
		<xsl:apply-templates select="." mode="xpto"/>
	</xsl:template>
	
	<xsl:template match="@*" mode="xpto">
		<xsl:apply-templates select="." mode="tab"/>
		<xsl:text>"</xsl:text>
		<xsl:value-of select="name()"/>
		<xsl:text>" : "</xsl:text>
		<xsl:apply-templates select="." mode="escape"/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<xsl:template match="text()">
		<xsl:apply-templates select="." mode="tab"/>
		<xsl:value-of select="name(..)"/>
		<xsl:text>:[</xsl:text>
		<xsl:for-each select="../text()[. != current()][normalize-space(.) != '']">
			<xsl:text>"</xsl:text>
			<xsl:apply-templates select="." mode="escape"/>
			<xsl:text>",</xsl:text>
		</xsl:for-each>
		<xsl:text>"</xsl:text>
		<!--xsl:value-of select="normalize-space(.)"/-->
		<xsl:apply-templates select="." mode="escape"/>
		<xsl:text>"]</xsl:text>
	</xsl:template>

	<xsl:template match="text()[count(../text()[normalize-space(.) != '']) = 1]">
		<xsl:apply-templates select="." mode="tab"/>
		<xsl:value-of select="name(..)"/>
		<xsl:text>: "</xsl:text>
		<xsl:apply-templates select="." mode="escape"/>
		<xsl:text>"</xsl:text>
	</xsl:template>

	<!-- separator mode -->
	<xsl:template match="*|@*" mode="separator">,</xsl:template>	

	<!--xsl:template match="*[count(following-sibling::*|../text()[normalize-space(.) != '']) = 0]" mode="separator"/-->
	<xsl:template match="*[last()][not(../text()[normalize-space(.) != ''])]" mode="separator"/>
	

	<!-- value mode -->
	<xsl:template match="node()" mode="value">"<xsl:apply-templates select="." mode="escape"/>"</xsl:template>

	<xsl:template match="*[not(node()|@*)]" mode="value">null</xsl:template>

	<xsl:template match="*[*|@*]" mode="value">
		<xsl:text>{</xsl:text>
		<xsl:apply-templates select="*|@*[last()]"/>
		<xsl:apply-templates select="text()[normalize-space(.) != ''][last()]"/>
		<xsl:apply-templates select="." mode="tab"/>
		<xsl:text>}</xsl:text>
	</xsl:template>

	<!-- tab mode -->
	<xsl:template match="node()|@*" mode="tab">
		<xsl:text>
</xsl:text>
		 <xsl:for-each select = "ancestor::*">
			<xsl:text>	</xsl:text>
		 </xsl:for-each>
	</xsl:template>

	<!-- tab mode -->
	<xsl:template name="escape">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text,'&quot;')">
				<xsl:value-of select="substring-before($text,'&quot;')"/>
				<xsl:text>\"</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="text" select="substring-after($text,'&quot;')"/>
				</xsl:call-template>	
			</xsl:when>
			<xsl:when test="contains($text,'\')">
				<xsl:value-of select="substring-before($text,'\')"/>
				<xsl:text>\\</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="text" select="substring-after($text,'\')"/>
				</xsl:call-template>	
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="node()|@*" mode="escape">
		<xsl:call-template name="escape">
			<xsl:with-param name="text" select="normalize-space(.)"/>
		</xsl:call-template>	 
	</xsl:template>
</xsl:stylesheet>
