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
  version="3.0">
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
  - [x] move entity information to register file
  - [x] substitute <Literary_Work> by <rs type="work">
  - [ ] split file according to decisions (to be taken)
  
  -->
  
<!--  <xsl:strip-space elements="*"/>-->
  
  <xsl:mode name="preprocess" on-no-match="shallow-copy"/>
  
  <xsl:template name="xsl:initial-template">
    <xsl:variable name="uris" as="xs:string*" select="uri-collection('input-file?select=*.xml')"/>
    <xsl:assert test="count($uris) = 1">Expected exactly one XML file in input-file.</xsl:assert>
    
    <xsl:variable name="register-state" as="map(*)" select="$uris => doc() => dsl:register()"/>
    
    <xsl:apply-templates select="$uris => doc()" mode="preprocess">
      <xsl:with-param name="register-state" as="map(*)" tunnel="yes" select="$register-state"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <xsl:template match="/" mode="preprocess">
    <xsl:param name="register-state" as="map(*)" tunnel="yes"/>
    
    <xsl:result-document href="../danina.xml" indent="false">
      <xsl:apply-templates mode="preprocess"/>
    </xsl:result-document>
    
    <xsl:call-template name="register">
      <xsl:with-param name="register-state" select="$register-state"/>
    </xsl:call-template>
    
  </xsl:template>
  
  <xsl:template match="facsimile" mode="preprocess">
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
  
  <xsl:template match="p" mode="preprocess">
    <xsl:variable name="n" as="xs:string">
      <xsl:number level="any" count="p" format="0000"/>
    </xsl:variable>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xml:lang" select="'ru'"/>
      <xsl:attribute name="xml:id" select="'p'||$n||'-ru'"/>
      <xsl:apply-templates mode="preprocess"/>
    </xsl:copy>
    <xsl:text> 
        </xsl:text>
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:attribute name="xml:lang" select="'de'"/>
      <xsl:attribute name="corresp" select="'#p'||$n||'-ru'"/>
      <xsl:text>{TRANSLATION GOES HERE}</xsl:text>
      <xsl:apply-templates mode="preprocess"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="Literary_Work" mode="preprocess">
    <rs type="work">
      <xsl:comment>
        <xsl:sequence select="@Comment"/>
      </xsl:comment>
      <xsl:apply-templates mode="preprocess"/>
    </rs>
  </xsl:template>
  
  <!-- Generic inline rewrite for all supported entity types -->
  <xsl:template match="persName | placeName" mode="preprocess">
    <xsl:param name="register-state" as="map(*)" tunnel="yes"/>
    
    <xsl:variable name="key" as="xs:string?" select="dsl:lookup-key(.)"/>
    <xsl:variable name="id" as="xs:string?" select="
      if (exists($key) and map:contains($register-state?register, $key))
      then $register-state?register($key)?id
      else ()
      "/>
    <xsl:variable name="spec" as="map(*)" select="dsl:entity-spec(.)"/>
    <xsl:variable name="drop" as="xs:string*" select="$spec?drop-attrs"/>
    
    <xsl:element name="{name()}" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:copy-of select="@*[not(local-name() = $drop)]"/>
      <xsl:if test="exists($id)">
        <xsl:attribute name="ref" select="'#' || $id"/>
      </xsl:if>
      <xsl:apply-templates select="node() except (birth, country, death, forename, surname)" mode="preprocess"/>
    </xsl:element>
  </xsl:template>
  
  <xsl:template name="register">
    <xsl:param name="register-state" as="map(*)"/>
    <xsl:result-document href="../register.xml" indent="true">
      <TEI>
        <teiHeader>
          <fileDesc>
            <titleStmt>
              <title type="main">Entity register</title>
            </titleStmt>
            <publicationStmt>
              <p>Generated by transkribus-preprocess.xsl</p>
            </publicationStmt>
            <sourceDesc>
              <p>Derived from source TEI document.</p>
            </sourceDesc>
          </fileDesc>
        </teiHeader>
        <text>
          <body>
            <listPerson>
              <xsl:perform-sort select="
                map:keys($register-state?register) ! $register-state?register(.)[?kind = 'persName']?entry">
                <xsl:sort select="@xml:id"/>
              </xsl:perform-sort>
            </listPerson>
            <listPlace>
              <xsl:perform-sort select="
                map:keys($register-state?register) ! $register-state?register(.)[?kind = 'placeName']?entry">
                <xsl:sort select="@xml:id"/>
              </xsl:perform-sort>
            </listPlace>
          </body>
        </text>
      </TEI>
    </xsl:result-document>
  </xsl:template>
  
  <!-- functions -->
  
  <xsl:function name="dsl:register" as="map(*)">
    <xsl:param name="doc" as="document-node()"/>
    
    <xsl:iterate select="$doc//(persName | placeName)">
      <xsl:param name="state" as="map(*)"
        select="map{
        'register' : map{},
        'counters' : map{}
        }"/>
      <xsl:on-completion select="$state"/>
      
      <xsl:variable name="key" as="xs:string?" select="dsl:lookup-key(.)"/>
      <xsl:variable name="spec" as="map(*)?" select="dsl:entity-spec(.)"/>
      
      <xsl:choose>
        <xsl:when test="empty($key) or empty($spec)">
          <xsl:next-iteration>
            <xsl:with-param name="state" select="$state"/>
          </xsl:next-iteration>
        </xsl:when>
        
        <xsl:when test="map:contains($state?register, $key)">
          <xsl:next-iteration>
            <xsl:with-param name="state" select="$state"/>
          </xsl:next-iteration>
        </xsl:when>
        
        <xsl:otherwise>
          <xsl:variable name="kind" as="xs:string" select="$spec?kind"/>
          <xsl:variable name="prefix" as="xs:string" select="$spec?prefix"/>
          <xsl:variable name="entry-name" as="xs:string" select="$spec?entry-name"/>
          
          <xsl:variable name="old-count" as="xs:integer"
            select="if (map:contains($state?counters, $kind))
            then $state?counters($kind)
            else 0"/>
          <xsl:variable name="new-count" as="xs:integer" select="$old-count + 1"/>
          <xsl:variable name="new-id" as="xs:string"
            select="$prefix || format-integer($new-count, '0000')"/>
          
          <xsl:variable name="entry" as="element()"
            select="dsl:make-entry(., $new-id, $entry-name)"/>
          
          <xsl:variable name="new-counters" as="map(*)"
            select="map:put($state?counters, $kind, $new-count)"/>
          
          <xsl:variable name="new-register" as="map(*)"
            select="
            map:put(
            $state?register,
            $key,
            map{
            'id'   : $new-id,
            'kind' : $kind,
            'entry': $entry
            }
            )
            "/>
          
          <xsl:next-iteration>
            <xsl:with-param name="state"
              select="map{
              'register' : $new-register,
              'counters' : $new-counters
              }"/>
          </xsl:next-iteration>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:iterate>
  </xsl:function>
  
  <xsl:function name="dsl:entity-spec" as="map(*)?">
    <xsl:param name="n" as="element()"/>
    <xsl:sequence select="
      if ($n/self::persName) then
      map{
      'kind'      : 'persName',
      'prefix'    : 'p',
      'entry-name': 'person',
      'drop-attrs': ('wikiData','pseudonym','pseudonym_2','pseudonym_3','first_name_cyrillic')
      }
      else if ($n/self::placeName) then
      map{
      'kind'      : 'placeName',
      'prefix'    : 'pl',
      'entry-name': 'place',
      'drop-attrs': ('wikiData','placeName')
      }
      else ()
      "/>
  </xsl:function>
  
  <xsl:function name="dsl:make-entry" as="element()">
    <xsl:param name="n" as="element()"/>
    <xsl:param name="id" as="xs:string"/>
    <xsl:param name="entry-name" as="xs:string"/>
    
    <xsl:element name="{$entry-name}" namespace="http://www.tei-c.org/ns/1.0">
      <xsl:attribute name="xml:id" select="$id"/>
      <xsl:copy-of select="$n/@*"/>
      <xsl:copy-of select="$n/node()"/>
    </xsl:element>
  </xsl:function>
  
  <xsl:function name="dsl:lookup-key" as="xs:string?">
    <xsl:param name="n" as="element()"/>
    
    <xsl:choose>
      <xsl:when test="$n/self::persName">
        <xsl:choose>
          <xsl:when test="normalize-space(string($n/@wikiData))">
            <xsl:sequence select="'persName:wikidata:' || normalize-space(string($n/@wikiData))"/>
          </xsl:when>
          <xsl:when test="normalize-space(string($n/@pseudonym))">
            <xsl:sequence select="'persName:pseudonym:' || dsl:normalize-key(string($n/@pseudonym))"/>
          </xsl:when>
          <xsl:when test="normalize-space(string($n/@first_name_cyrillic))">
            <xsl:sequence select="'persName:first_name_cyrillic:' || dsl:normalize-key(string($n/@first_name_cyrillic))"/>
          </xsl:when>
          <xsl:otherwise><xsl:sequence select="()"/></xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      
      <xsl:when test="$n/self::placeName">
        <xsl:choose>
          <xsl:when test="normalize-space(string($n/@wikiData))">
            <xsl:sequence select="'placeName:wikidata:' || normalize-space(string($n/@wikiData))"/>
          </xsl:when>
          <xsl:when test="normalize-space(string($n/@placeName))">
            <xsl:sequence select="'placeName:placeName:' || dsl:normalize-key(string($n/@placeName))"/>
          </xsl:when>
          <xsl:otherwise><xsl:sequence select="()"/></xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      
      <xsl:otherwise><xsl:sequence select="()"/></xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="dsl:normalize-key" as="xs:string">
    <xsl:param name="s" as="xs:string?"/>
    <xsl:sequence select="
      $s
      => normalize-space()
      => replace('\.+', '')
      => replace('\s+', ' ')
      => lower-case()
      "/>
  </xsl:function>
  
</xsl:transform>