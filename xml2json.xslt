<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<!--
  Copyright (c) 2013, Isidro Vila Verde
  All rights reserved.

  Redistribution and use in source and binary forms, with or without modification, 
  are permitted provided that the following conditions are met:

  Redistributions of source code must retain the above copyright notice, this 
  list of conditions and the following disclaimer. Redistributions in binary 
  form must reproduce the above copyright notice, this list of conditions and the 
  following disclaimer in the documentation and/or other materials provided with 
  the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED 
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. 
  IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, 
  INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
  BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, 
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR 
  OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF 
  THE POSSIBILITY OF SUCH DAMAGE.
-->
	<xsl:output method="text"  encoding="UTF-8" media-type="text/plain" omit-xml-declaration="yes"/>
	<xsl:param name="textNodeName" select="''"/>
	<xsl:param name="includeRoot" select="0"/>
	<xsl:param name="includexsiAttributes" select="0"/>
	<xsl:param name="removeNS" select="1"/>	
	<xsl:param name="normalize" select="1"/>
	<xsl:variable name="xsiNS" select="'http://www.w3.org/2001/XMLSchema-instance'"/>	
	<xsl:template match="/">
		<xsl:if test="$includeRoot">
			<xsl:text>{</xsl:text>
			<xsl:apply-templates select="*"/>
			<xsl:text>
}</xsl:text>
		</xsl:if>
		<xsl:if test="not($includeRoot)">
			<xsl:apply-templates select="." mode="value"/>
		</xsl:if>
	</xsl:template>	
	<!-- single elements --> 
	<xsl:template match="*[not(following-sibling::*[name() = name(current())]) and not(preceding-sibling::*[name() = name(current())])]">
		<xsl:apply-templates select="." mode="tab"/>	 
		<xsl:text>"</xsl:text>
		<xsl:apply-templates select="." mode="name"/>
		<xsl:text>" : </xsl:text>
		<xsl:apply-templates select="." mode="value"/>
		<xsl:apply-templates select="." mode="separator"/>
	</xsl:template>
	
	<!-- first of multiples elements -->
	<xsl:template match="*[following-sibling::*[name() = name(current())] and not(preceding-sibling::*[name() = name(current())])]">
		<xsl:apply-templates select="." mode="tab"/>
		<xsl:text>"</xsl:text>
		<xsl:apply-templates select="." mode="name"/>
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

	<!-- atributte nodes -->
	<xsl:template match="@*">
		<xsl:for-each select="../@*[. != current()][$includexsiAttributes  or namespace-uri(.) != $xsiNS]">
			<xsl:apply-templates select="." mode="xpto"/>
			<xsl:apply-templates select="." mode="separator"/>
		</xsl:for-each>
		<xsl:apply-templates select="." mode="xpto"/>
		<xsl:apply-templates select="." mode="last"/>
	</xsl:template>
	
	<xsl:template match="@*" mode="xpto">
		<xsl:apply-templates select="." mode="tab"/>
		<xsl:text>"</xsl:text>
		<xsl:apply-templates select="." mode="name"/>
		<xsl:text>" : "</xsl:text>
		<xsl:apply-templates select="." mode="escape"/>
		<xsl:text>"</xsl:text>
	</xsl:template>
	
	<!-- decide when to include or not a separator -->
	<xsl:template match="@*" mode="last"/>
	<xsl:template match="@*[../*|../text()[normalize-space(.) != '']]" mode="last">
		<xsl:apply-templates select="." mode="separator"/>
	</xsl:template>

	<!-- text() nodes -->
	<xsl:template match="text()">
		<xsl:apply-templates select="." mode="textNodeName"/>		
		<xsl:text>:[</xsl:text>
		<!-- for each brother which has not null text-->
		<xsl:for-each select="../text()[. != current()][normalize-space(.) != '']">
			<xsl:text>"</xsl:text>
			<xsl:apply-templates select="." mode="escape"/>
			<xsl:text>",</xsl:text>
		</xsl:for-each>
		<!-- and last the node itself -->
		<xsl:text>"</xsl:text>
		<xsl:apply-templates select="." mode="escape"/>
		<xsl:text>"]</xsl:text>
	</xsl:template>

	<xsl:template match="text()[count(../text()[normalize-space(.) != '']) = 1]">
		<xsl:apply-templates select="." mode="textNodeName"/>		
		<xsl:text>: "</xsl:text>
		<xsl:apply-templates select="." mode="escape"/>
		<xsl:text>"</xsl:text>
	</xsl:template>
	<xsl:template match="text()" mode="textNodeName">
		<xsl:apply-templates select="." mode="tab"/>
		<xsl:if test="$textNodeName">
			<xsl:text>"</xsl:text>
			<xsl:value-of select="$textNodeName"/>
			<xsl:text>"</xsl:text>
		</xsl:if>
		<xsl:if test="not($textNodeName)">
			<xsl:text>"</xsl:text>
			<xsl:apply-templates select=".." mode="name"/>
			<xsl:text>"</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- separator mode -->
	<xsl:template match="*|@*" mode="separator">,</xsl:template>	

	<!--xsl:template match="*[count(following-sibling::*|../text()[normalize-space(.) != '']) = 0]" mode="separator"/-->
	<xsl:template match="*[last()][not(../text()[normalize-space(.) != ''])]" mode="separator"/>
	

	<!-- value mode -->
	<xsl:template match="node()" mode="value">"<xsl:apply-templates select="." mode="escape"/>"</xsl:template>
	<xsl:template match="node()[. = number(.)]" mode="value"><xsl:value-of select="."/></xsl:template>

	<xsl:template match="*[not(node()|@*)]" mode="value" priority="5">null</xsl:template>

	<xsl:template match="*[*|@*]" mode="value">
		<xsl:variable name="cnt" select ="count(*|@*[$includexsiAttributes  or namespace-uri(.) != $xsiNS][last()])"/>
		<xsl:if test="$cnt&gt;0">
			<xsl:text>{</xsl:text>
			<xsl:apply-templates select="*|@*[$includexsiAttributes  or namespace-uri(.) != $xsiNS][last()]"/>
			<xsl:apply-templates select="text()[normalize-space(.) != ''][last()]"/>
			<xsl:apply-templates select="." mode="tab"/>
			<xsl:text>}</xsl:text>
		</xsl:if>
		<xsl:if test="$cnt = 0">"<xsl:apply-templates select="." mode="escape"/>"</xsl:if>	
	</xsl:template>

	<!-- tab mode -->
	<xsl:template match="node()|@*" mode="tab">
		<xsl:text>
</xsl:text>
		 <xsl:for-each select = "ancestor::*">
			<xsl:text>	</xsl:text>
		 </xsl:for-each>
		<xsl:if test="$includeRoot">
			<xsl:text>	</xsl:text>
		</xsl:if>
	</xsl:template>

	<!-- tab mode -->
	<xsl:template name="escape">
		<xsl:param name="text"/>
		<xsl:choose>
			<xsl:when test="contains($text,'&quot;')">
				<xsl:call-template name="escape">
					<xsl:with-param name="text" select="substring-before($text,'&quot;')"/>
				</xsl:call-template>
				<xsl:text>\"</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="text" select="substring-after($text,'&quot;')"/>
				</xsl:call-template>	
			</xsl:when>
			<xsl:when test="contains($text,'\')">
				<xsl:call-template name="escape">
					<xsl:with-param name="text" select="substring-before($text,'\')"/>
				</xsl:call-template>	
				<xsl:text>\\</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="text" select="substring-after($text,'\')"/>
				</xsl:call-template>	
			</xsl:when>
			<xsl:when test="contains($text,'&#9;')">
				<xsl:call-template name="escape">
					<xsl:with-param name="text" select="substring-before($text,'&#9;')"/>
				</xsl:call-template>	
				<xsl:text>\t</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="text" select="substring-after($text,'&#9;')"/>
				</xsl:call-template>	
			</xsl:when>
			<xsl:when test="contains($text,'&#10;')">
				<xsl:call-template name="escape">
					<xsl:with-param name="text" select="substring-before($text,'&#10;')"/>
				</xsl:call-template>	
				<xsl:text>\n</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="text" select="substring-after($text,'&#10;')"/>
				</xsl:call-template>	
			</xsl:when>
			<xsl:when test="contains($text,'&#13;')">
				<xsl:call-template name="escape">
					<xsl:with-param name="text" select="substring-before($text,'&#13;')"/>
				</xsl:call-template>
				<xsl:text>\r</xsl:text>
				<xsl:call-template name="escape">
					<xsl:with-param name="text" select="substring-after($text,'&#13;')"/>
				</xsl:call-template>	
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$text"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="node()|@*" mode="escape">
		<xsl:if test="$normalize">
			<xsl:call-template name="escape">
				<xsl:with-param name="text" select="normalize-space(.)"/>
			</xsl:call-template>
		</xsl:if>	 
		<xsl:if test="not($normalize)">
			<xsl:call-template name="escape">
				<xsl:with-param name="text" select="."/>
			</xsl:call-template>
		</xsl:if>	 
	</xsl:template>

	<!-- mode name -->
	<xsl:template match="@*|*" mode="name">
		<xsl:if test="not($removeNS)">
			<xsl:value-of select="name()"/>
		</xsl:if>
		<xsl:if test="$removeNS">
			<xsl:value-of select="local-name()"/>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet>
