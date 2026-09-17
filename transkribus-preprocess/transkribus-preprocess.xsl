<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:xi="http://www.w3.org/2001/XInclude"
  xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
  xmlns:dsl="https://dsl.unibe.ch"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="xi xs xd dsl map"
  expand-text="true"
  version="3.0">
  <!-- {http://www.w3.org/1999/XSL/Transform}initial-template -->
  <xd:doc scope="stylesheet">
    <xd:desc>
      <xd:p><xd:b>Created on:</xd:b> Jul 21, 2026</xd:p>
      <xd:p><xd:b>Author:</xd:b> pd</xd:p>
      <xd:p></xd:p>
    </xd:desc>
  </xd:doc>
  
  <!-- 
  TO DO:
  
  - [x] substitute lb by milestone/@unit=line
  - [x] duplicate paragraphs (for translation in LEAF writer)
  - [ ] reach parity with LEAF transkribus conversion:
     - [ ] add schema reference
     - [ ] add xml-stylesheet PI (css)
     - [ ] add xenodata element
  - [ ] split file according to decisions (to be taken)
  - [ ] hyphenation ¬
  
  -->
  
<!--  <xsl:strip-space elements="*"/>-->
  
  <xsl:mode name="preprocess" on-no-match="shallow-copy"/>
  <xsl:mode name="preprocess-integrate" on-no-match="shallow-copy"/>
  
  <xsl:template name="xsl:initial-template">
    <xsl:variable name="uris" as="xs:string*" select="uri-collection('input-file?select=*.xml')"/>
    <xsl:assert test="count($uris) = 1">Expected exactly one XML file in input-file.</xsl:assert>
    
    <xsl:apply-templates select="$uris => doc()" mode="preprocess"/>
    
  </xsl:template>
  
  <xsl:template match="/" mode="preprocess">
    
    <xsl:result-document href="../danina.xml" indent="true">
      <xsl:apply-templates mode="preprocess"/>
    </xsl:result-document>
        
  </xsl:template>
  
  <xsl:template match="profileDesc" mode="preprocess">
    <xenoData><rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" xmlns:as="http://www.w3.org/ns/activitystreams#" xmlns:cwrc="http://sparql.cwrc.ca/ontologies/cwrc#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:foaf="http://xmlns.com/foaf/0.1/" xmlns:geo="http://www.geonames.org/ontology#" xmlns:oa="http://www.w3.org/ns/oa#" xmlns:schema="http://schema.org/" xmlns:xsd="http://www.w3.org/2001/XMLSchema#" xmlns:fabio="https://purl.org/spar/fabio#" xmlns:bf="http://www.openlinksw.com/schemas/bif#" xmlns:cito="https://sparontologies.github.io/cito/current/cito.html#" xmlns:org="http://www.w3.org/ns/org#"/></xenoData>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="preprocess"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="langUsage" mode="preprocess">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <language ident="ru">Russisch</language>
      <language ident="de">Deutsch</language>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="surface" mode="preprocess">
    <xsl:result-document href="../facs/{@xml:id}.xml" indent="true">
      <xsl:sequence select="."/>
    </xsl:result-document>
    <xsl:element name="xi:include" namespace="http://www.w3.org/2001/XInclude">
      <xsl:attribute name="href" select="'facs/' ||@xml:id||'.xml'"/>
      <xsl:element name="xi:fallback" namespace="http://www.w3.org/2001/XInclude"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template match="lb" mode="preprocess">
    <milestone unit="line">
      <xsl:sequence select="@*"/>
    </milestone>
  </xsl:template>
  
  <xsl:template match="lb" mode="preprocess-integrate">
    <milestone unit="line">
      <xsl:sequence select="@*"/>
    </milestone>
  </xsl:template>
  
  <xsl:template match="p" mode="preprocess">
    <xsl:variable name="n" as="xs:string">
      <xsl:number level="any" count="p" format="0000"/>
    </xsl:variable>
    <xsl:variable name="next-p" select="following::p[1]/generate-id()"/>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xml:lang" select="'ru'"/>
      <xsl:attribute name="xml:id" select="'p'||$n||'-ru'"/>
      <xsl:apply-templates mode="preprocess"/>
      <!-- merge in all following pb, fw, and ab until the next p -->
      <xsl:if test="ancestor::text">      
        <xsl:apply-templates select="following-sibling::node()[following::p[generate-id()=$next-p]] except self::ab[@type='dated_entry_header']" mode="preprocess-integrate"/>
      </xsl:if>
    </xsl:copy>
    <!-- German translation -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xml:lang" select="'de'"/>
      <xsl:attribute name="corresp" select="'#p'||$n||'-ru'"/>
      <xsl:text expand-text="false">{TRANSLATION GOES HERE}</xsl:text>
      <xsl:apply-templates select="node()" mode="preprocess-integrate"/>
      <!-- merge in all following pb, fw, and ab until the next p -->
      <xsl:if test="ancestor::text">    
        <xsl:apply-templates select="following-sibling::node()[following::p[generate-id()=$next-p]] except self::ab[@type='dated_entry_header']" mode="preprocess-integrate">
          <xsl:with-param name="lang" select="'de'" tunnel="true"/>
        </xsl:apply-templates>
      </xsl:if>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="head" mode="preprocess">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates mode="preprocess"/>
    </xsl:copy>
    <!-- German translation -->
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xml:lang" select="'de'"/>
      <xsl:text expand-text="false">{TRANSLATION GOES HERE}</xsl:text>
      <xsl:apply-templates mode="preprocess"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="ab[@type='paragraph_to_be_merged_with_previous']" mode="preprocess"/>
  
  <xsl:template match="ab[@type='paragraph_to_be_merged_with_previous']" mode="preprocess-integrate">
    <xsl:comment>MERGED: 
    </xsl:comment> 
    <xsl:apply-templates mode="preprocess-integrate"/>
  </xsl:template>
  
  <xsl:template match="ab[@type='page_number__deleted_or_striked_out']" mode="preprocess-integrate">
    <fw>
      <xsl:sequence select="@facs,@type"/>
      <del>
        <xsl:apply-templates mode="preprocess"/>
      </del>
    </fw>
  </xsl:template>
  
  <xsl:template match="ab[@type='quotation']" mode="preprocess">
    <p>
      <quote>
        <xsl:apply-templates mode="preprocess"/>
      </quote>
    </p>
    <!-- German translation -->
    <p xml:lang="de">
      <quote>
        <xsl:text expand-text="false">{TRANSLATION GOES HERE}</xsl:text>
        <xsl:apply-templates mode="preprocess"/>
      </quote>
    </p>
  </xsl:template>
  
  <xsl:template match="ab[@type='quotation']" mode="preprocess-integrate">
    <quote>
      <xsl:apply-templates mode="preprocess"/>
    </quote>
  </xsl:template>
  
  <xsl:template match="ab[@type='dated_entry_header']" mode="preprocess-integrate"/>
    
  <xsl:template match="ab[@type='dated_entry_header']" mode="preprocess">
    <p>
      <xsl:copy-of select="@* except @type"/>
      <xsl:attribute name="ana" select="@type"/>
      <xsl:apply-templates mode="preprocess"/>
    </p>
    <!-- German translation -->
    <p>
      <xsl:copy-of select="@* except @type"/>
      <xsl:attribute name="ana" select="@type"/>
      <xsl:text expand-text="false">{TRANSLATION GOES HERE}</xsl:text>
      <xsl:apply-templates mode="preprocess"/>
    </p>
  </xsl:template>
  
  <xsl:template match="pb[following-sibling::p|following-sibling::ab[starts-with(@type,'paragraph')]]" mode="preprocess"/>
    
  <xsl:template match="fw[@type='page-number'][following-sibling::p|following-sibling::ab[starts-with(@type,'paragraph')]]" mode="preprocess"/>
  
  <xsl:template match="ab[@type='page_number__deleted_or_striked_out'][following-sibling::p|following-sibling::ab[starts-with(@type,'paragraph')]]" mode="preprocess"/>
  
  <xsl:template match="pb" mode="preprocess-integrate">
    <xsl:param name="lang" tunnel="true"/>
    <xsl:choose>
      <xsl:when test="$lang='de'">
        <xsl:copy>
          <xsl:copy-of select="@*"/>
          <xsl:attribute name="xml:id" select="@xml:id||'-de'"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:transform>