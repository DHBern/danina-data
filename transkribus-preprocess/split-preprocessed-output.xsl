<?xml version="1.0" encoding="UTF-8"?>
<xsl:transform xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:split="urn:local:split-fragment"
    exclude-result-prefixes="#all" 
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

    <xsl:mode on-no-match="shallow-copy"/>


    <!-- how many ru/de pairs per extracted file -->
    <xsl:param name="group-size" as="xs:integer" select="25"/>
    <!-- where to write the fragment files (relative to main output) -->
    <xsl:param name="output-dir" as="xs:string" select="'parts'"/>

    <xsl:output method="xml" indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="div[p]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>

            <xsl:variable name="div-id" as="xs:string"
                select="'div-'||preceding-sibling::div => count()"/>

            <xsl:for-each-group select="node()" group-adjacent="xs:integer(
                preceding-sibling::p[@xml:lang='ru'] => count()
                div $group-size => floor())">

                <xsl:variable name="group">
                    <xsl:choose>
                        <xsl:when test="(current-group()//pb)[1]/@xml:id=>replace('\D','')=>number() le 69">group1</xsl:when>
                        <xsl:when test="(current-group()//pb)[1]/@xml:id=>replace('\D','')=>number() le 127">group2</xsl:when>
                        <xsl:otherwise>group3</xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>

                <xsl:variable name="href" as="xs:string"
                    select="$output-dir || '/' || $group || '/' || $div-id || '_'
                    || (current-grouping-key() +1) => format-number('000') || '.xml'"/>

                <xsl:result-document href="{$href}">
                    <xsl:processing-instruction name="xml-model">
                        <xsl:text>type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0" href="null"</xsl:text>
                    </xsl:processing-instruction>
                    <xsl:processing-instruction name="xml-stylesheet">
                        <xsl:text>type="text/css" href="null"</xsl:text>
                    </xsl:processing-instruction>
                    <xsl:processing-instruction name="xml-model">
                      <xsl:text>href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:text>
                    </xsl:processing-instruction>
                    <xsl:processing-instruction name="xml-model">
                        <xsl:text>href="http://www.tei-c.org/release/xml/tei/custom/schema/relaxng/tei_all.rng" type="application/xml" schematypens="http://purl.oclc.org/dsdl/schematron"</xsl:text>
                    </xsl:processing-instruction>
                                        
                    <TEI xmlns="http://www.tei-c.org/ns/1.0" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#">
                        <teiHeader>
                            <fileDesc>
                                <titleStmt>
                                    <title/>
                                </titleStmt>
                                <publicationStmt>
                                    <p/>
                                </publicationStmt>
                                <sourceDesc>
                                    <p/>
                                </sourceDesc>
                            </fileDesc>
                            <xenoData>
                                <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
                                    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#"
                                    xmlns:as="http://www.w3.org/ns/activitystreams#"
                                    xmlns:cwrc="http://sparql.cwrc.ca/ontologies/cwrc#"
                                    xmlns:dc="http://purl.org/dc/elements/1.1/"
                                    xmlns:dcterms="http://purl.org/dc/terms/"
                                    xmlns:foaf="http://xmlns.com/foaf/0.1/"
                                    xmlns:geo="http://www.geonames.org/ontology#"
                                    xmlns:oa="http://www.w3.org/ns/oa#"
                                    xmlns:schema="http://schema.org/"
                                    xmlns:xsd="http://www.w3.org/2001/XMLSchema#"
                                    xmlns:fabio="https://purl.org/spar/fabio#"
                                    xmlns:bf="http://www.openlinksw.com/schemas/bif#"
                                    xmlns:cito="https://sparontologies.github.io/cito/current/cito.html#"
                                    xmlns:org="http://www.w3.org/ns/org#"/>
                            </xenoData>
                        </teiHeader>
                        <text>
                            <body>
                                <xsl:copy-of select="current-group()"/>
                            </body>
                        </text>
                    </TEI>
                </xsl:result-document>

                <xsl:element name="xi:include" namespace="http://www.w3.org/2001/XInclude">
                    <xsl:attribute name="href" select="$href"/>
                    <xsl:element name="xi:fallback" namespace="http://www.w3.org/2001/XInclude"/>
                </xsl:element>

            </xsl:for-each-group>
        </xsl:copy>
    </xsl:template>

</xsl:transform>
