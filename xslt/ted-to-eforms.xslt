<?xml version="1.0" encoding="UTF-8"?>
<!--
####################################################################################
#  XSLT name : ted-to-eforms
#  Version : 0.2.0
####################################################################################
-->
<xsl:stylesheet version="2.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:doc="http://www.pnp-software.com/XSLTdoc"
xmlns:fn="http://www.w3.org/2005/xpath-functions" xmlns:functx="http://www.functx.com" xmlns:opfun="http://data.europa.eu/p27/ted-xml-data-converter"
xmlns:ted="http://publications.europa.eu/resource/schema/ted/R2.0.9/publication"
xmlns:ted-1="http://formex.publications.europa.eu/ted/schema/export/R2.0.9.S01.E01"
xmlns:ted-2="ted/R2.0.9.S02/publication"
xmlns:n2016-1="ted/2016/nuts"
xmlns:dfo="dfo-conversion-hacks"
xmlns:n2016="http://publications.europa.eu/resource/schema/ted/2016/nuts" xmlns:n2021="http://publications.europa.eu/resource/schema/ted/2021/nuts"
xmlns:pin="urn:oasis:names:specification:ubl:schema:xsd:PriorInformationNotice-2" xmlns:cn="urn:oasis:names:specification:ubl:schema:xsd:ContractNotice-2" xmlns:can="urn:oasis:names:specification:ubl:schema:xsd:ContractAwardNotice-2"
xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2"
xmlns:efbc="http://data.europa.eu/p27/eforms-ubl-extension-basic-components/1" xmlns:efac="http://data.europa.eu/p27/eforms-ubl-extension-aggregate-components/1" xmlns:efext="http://data.europa.eu/p27/eforms-ubl-extensions/1"
xmlns:ccts="urn:un:unece:uncefact:documentation:2" xmlns:gc="http://docs.oasis-open.org/codelist/ns/genericode/1.0/"
exclude-result-prefixes="xlink xs xsi fn functx doc opfun ted ted-1 ted-2 gc n2016-1 n2016 n2021 pin cn can ccts ext dfo" >
<xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes"/>

<xsl:include href="functions-and-data.xslt"/>
<xsl:include href="simple.xslt"/>
<xsl:include href="award-criteria.xslt"/>
<xsl:include href="addresses.xslt"/>
<xsl:include href="procedure.xslt"/>
<xsl:include href="lot.xslt"/>
<xsl:include href="notice-result.xslt"/>
<xsl:include href="common.xslt"/>


<!-- TBD: Currently these stylesheets only cater for one form element, one language. Work is required to cater for other form elements with alternate languages -->



<!-- DEFAULT TEMPLATES -->

<!-- These templates exist to report where <xsl:apply-templates> select a TED element, but there is no matching <xsl:template> -->

<xsl:template match="*">
	<xsl:variable name="name" select="opfun:prefix-and-name(.)"/>
	<tedelement name="{$name}">
		<xsl:apply-templates select="@*|node()"></xsl:apply-templates>
	</tedelement>
</xsl:template>

<xsl:template match="@*">
	<xsl:copy/>
</xsl:template>



<!-- MAIN ROOT TEMPLATE -->

<!-- This is the starting template -->

<xsl:template match="/">
	<!-- terminate processing if XML file contains more than one type of form (form element name) -->
	<xsl:if test="fn:count($ted-form-elements-names) != 1">
		<xsl:message terminate="yes">ERROR: found <xsl:value-of select="fn:count($ted-form-elements-names)"/> different form types in <xsl:value-of select="document-uri(.)"/></xsl:message>
	</xsl:if>
	<xsl:apply-templates select="$ted-form-main-element"/>
</xsl:template>



<!-- SUPPRESSED TEMPLATES -->

<xsl:template match="*:TECHNICAL_SECTION"/>
<xsl:template match="*:LINKS_SECTION"/>
<xsl:template match="*:CODED_DATA_SECTION"/>
<xsl:template match="*:TRANSLATION_SECTION"/>
<!-- LEGAL_BASIS only occurs as direct child of the FORM ELEMENT, and is handled in <xsl:template name="notice-information"> -->
<xsl:template match="*:LEGAL_BASIS"/>

<!-- NOTICE only occurs as direct child of the FORM ELEMENT, and is only used to select the eForms Notice subtype -->
<xsl:template match="*:NOTICE"/>



<!-- Main Form ELEMENT (F01_2014, F02_2014, etc) -->
<!-- this template is called from the starting template above -->

<xsl:template match="*[@CATEGORY='ORIGINAL']">

	<!-- NOTE: all eForms dates and times should contain ISO-8601 format dates, i.e. expressed as UTC with offsets. -->
	<!-- TED date elements have no time zone associated, and TED time elements have "local time". -->
	<!-- Therefore for complete accuracy, a mapping of country codes to UTC timezone offsets would be required -->
	<!-- In this initial conversion, no such mapping is used, and TED dates and times are assumed to be CET, i.e. UTC -->

	<xsl:variable name="message">WARNING: TED date elements have no time zone associated. For all dates in this notice, the time zone is assumed to be CET, i.e. UTC </xsl:variable>
	<xsl:call-template name="report-warning"><xsl:with-param name="message" select="$message"/></xsl:call-template>
	
	<!-- root element of output XML -->
	<xsl:element name="{$eforms-element-name}" namespace="{$eforms-xmlns}">
		<xsl:namespace name="cac" select="'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2'"/>
		<xsl:namespace name="cbc" select="'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2'"/>
		<xsl:namespace name="ext" select="'urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2'"/>
		<xsl:namespace name="efac" select="'http://data.europa.eu/p27/eforms-ubl-extension-aggregate-components/1'"/>
		<xsl:namespace name="efbc" select="'http://data.europa.eu/p27/eforms-ubl-extension-basic-components/1'"/>
		<xsl:namespace name="efext" select="'http://data.europa.eu/p27/eforms-ubl-extensions/1'"/>
		<xsl:namespace name="ccts" select="'urn:un:unece:uncefact:documentation:2'"/>
		<xsl:call-template name="root-extensions"/>
		<xsl:call-template name="notice-information"/>
		<xsl:call-template name="contracting-party"/>
		<xsl:call-template name="root-tendering-terms"/>
		<xsl:call-template name="root-tendering-process"/>
		<xsl:call-template name="root-procurement-project"/>
		<xsl:call-template name="procurement-project-lots"/>
		<!-- The ContractAwardNotice schema requires cac:TenderResult/cbc:AwardDate -->
		<xsl:if test="$eforms-document-type eq 'CAN'">
			<cac:TenderResult>
				<cbc:AwardDate>
					<!--orig code 
					<xsl:text>2000-01-01Z</xsl:text>
					end orig code-->
					<!-- changed dfo -->
					<xsl:choose>						
				        <xsl:when test="//DATE_CONCLUSION_CONTRACT">
				            <xsl:value-of select="//DATE_CONCLUSION_CONTRACT"/>
				        </xsl:when>
				        <xsl:otherwise>
				            <xsl:text>2000-01-01Z</xsl:text>								
				        </xsl:otherwise>
				    </xsl:choose>
				    <!--end changed dfo -->

				</cbc:AwardDate>
			</cac:TenderResult>
		</xsl:if>
	</xsl:element>
</xsl:template>


<!-- Procedure-level templates for Notice information -->

<xsl:template name="root-extensions">
	<ext:UBLExtensions>
		<ext:UBLExtension>
			<ext:ExtensionContent>
				<efext:EformsExtension>
					<xsl:if test="$eforms-notice-subtype = '99'">
						<xsl:if test="//COMPLEMENTARY_INFO/NO_DOC_EXT">
							<efac:Changes>								
								<efbc:ChangedNoticeIdentifier schemeName="ojs-notice-id"><xsl:value-of select="//COMPLEMENTARY_INFO/NO_DOC_EXT"/></efbc:ChangedNoticeIdentifier>
							</efac:Changes>
						</xsl:if>
					</xsl:if>					
					<xsl:if test="$eforms-document-type eq 'CAN'">
					</xsl:if>
					<xsl:if test="$ted-form-notice-type eq '14'">
						<xsl:call-template name="changes"/>
					</xsl:if>
					<xsl:if test="$eforms-notice-subtype = ('38', '39', '40')">
						<xsl:call-template name="contract-modification"/>
					</xsl:if>
					<xsl:if test="$eforms-document-type eq 'CAN'">
						<xsl:call-template name="notice-result"/>
					</xsl:if>
					<!-- Notice SubType (OPP-070): eForms documentation cardinality (Procedure) = 1 -->
					<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Notice SubType (OPP-070)'"/></xsl:call-template>
					<efac:NoticeSubType>
						<!-- orig lines
						<cbc:SubTypeCode listName="notice-subtype"><xsl:value-of select="$eforms-notice-subtype"/></cbc:SubTypeCode>
					    end orig lines-->

					    <!-- start DFO juks .. hardcodet N in front, so F52 gets notice subtype N16 insetad of 16
						Dei stikkprøvane eg har gjort så er alle F52 nasjonal kunngjøring, og om det stemmer så skal alle F52 bli N16
						https://www.doffin.no/Notice/Details/2023-369830
						https://www.doffin.no/Notice/Details/2023-335996
						-->
					    <cbc:SubTypeCode listName="notice-subtype">
					    	<xsl:if test="$eforms-notice-subtype != 99">
						    	<xsl:if test="$ted-form-name eq 'F52'">N</xsl:if>
						    	<xsl:if test="$ted-form-name eq 'F65'">N</xsl:if>
						    	<xsl:if test="$ted-form-name eq 'F102'">N</xsl:if>
					    	</xsl:if>
					    	<xsl:value-of select="$eforms-notice-subtype"/>
						</cbc:SubTypeCode>
					    <!-- end DFO juks -->
					</efac:NoticeSubType>
					<xsl:call-template name="organizations"/>
					<xsl:call-template name="publication"/>
				</efext:EformsExtension>
			</ext:ExtensionContent>
		</ext:UBLExtension>
	</ext:UBLExtensions>
</xsl:template>


<xsl:template name="notice-information">
	<!-- UBL version ID (UBL) -->
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'UBL version ID (UBL)'"/></xsl:call-template>
	<cbc:UBLVersionID>2.3</cbc:UBLVersionID>
	<!-- Customization ID (SDK version) -->
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Customization ID (UBL)'"/></xsl:call-template>
	<!-- check the sdk-version parameter is valid and standardise it -->
	<xsl:variable name="sdk-version-parameter">
		<xsl:choose>
			<xsl:when test="fn:matches($sdk-version, '^eforms-sdk-[12]\.[0-9]{1,2}$')"><xsl:value-of select="$sdk-version"/></xsl:when>
			<xsl:when test="fn:matches($sdk-version, '^[12]\.[0-9]{1,2}$')"><xsl:value-of select="fn:concat('eforms-sdk-', $sdk-version)"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="'invalid'"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- if the sdk-version parameter is not valid, use default value -->
	<xsl:variable name="sdk-version-value">
		<xsl:choose>
			<xsl:when test="$sdk-version-parameter ne 'invalid'"><xsl:value-of select="$sdk-version-parameter"/></xsl:when>
			<xsl:otherwise><xsl:value-of select="$sdk-version-default"/></xsl:otherwise>
		</xsl:choose>
	</xsl:variable>
	<!-- if the sdk-version parameter is not valid, report warning -->
	<xsl:if test="$sdk-version-parameter eq 'invalid'">
		<!-- WARNING: Invalid SDK version supplied as a parameter. Using default value -->
		<xsl:variable name="message"><xsl:text>WARNING: Invalid SDK version supplied as a parameter. Using default value "</xsl:text><xsl:value-of select="$sdk-version-default"/><xsl:text>"</xsl:text></xsl:variable>
		<xsl:call-template name="report-warning"><xsl:with-param name="message" select="$message"/></xsl:call-template>
	</xsl:if>
	<cbc:CustomizationID>
		<xsl:value-of select="$sdk-version-value"/>

		<!-- added dfo -->
		<xsl:choose>
		    <xsl:when test="$ted-form-name eq 'F52'">#urn:fdc:anskaffelser.no:2023:eforms:national</xsl:when>
		    <xsl:when test="$ted-form-name eq 'F65'">#urn:fdc:anskaffelser.no:2023:eforms:national</xsl:when>
		    <xsl:otherwise>#urn:fdc:anskaffelser.no:2023:eforms:eu</xsl:otherwise>
		</xsl:choose>

		<!-- edn added dfo -->

	</cbc:CustomizationID>
	<!-- Notice Identifier (BT-701): eForms documentation cardinality (Procedure) = 1 | Mandatory for ALL subtypes -->
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Notice Identifier (BT-701)'"/></xsl:call-template>
	<cbc:ID schemeName="notice-id">
		<xsl:variable name="notice-identifier-local" select="substring-before(tokenize(base-uri(.), '/')[last()], '.')" as="xs:string"/>
		<xsl:value-of select="$notice-identifier-local"/>
	</cbc:ID>
	<!-- added dfo -->
	<xsl:if test="$eforms-notice-subtype = '99'">
		<cbc:URI>https://classic.doffin.no/Notice/Details/<xsl:value-of select="$notice-identifier"/></cbc:URI>
	</xsl:if>
	<!-- end added dfo  -->
	<xsl:if test="not($eforms-notice-subtype = ('1', '2', '3', '4', '5', '6', '7', '8', '9'))">
		<!-- Procedure Identifier (BT-04): eForms documentation cardinality (Procedure) = * | Forbidden for PIN subtypes 1-9, E1 and E2; Mandatory for other subtypes -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Procedure Identifier (BT-04)'"/></xsl:call-template>
		<cbc:ContractFolderID><xsl:value-of select="$procedure-identifier"/></cbc:ContractFolderID>
	</xsl:if>
	<!-- Notice Dispatch Date (BT-05): eForms documentation cardinality (Procedure) = 1 | Mandatory for ALL subtypes -->
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Notice Dispatch Date (BT-05)'"/></xsl:call-template>
	<xsl:choose>
	  <xsl:when test="*:COMPLEMENTARY_INFO/*:DATE_DISPATCH_NOTICE">
	  	<xsl:variable name="datetimeAsString">
	  		<xsl:choose>
	  			<xsl:when test="number(translate(*:COMPLEMENTARY_INFO/*:DATE_DISPATCH_NOTICE, '-', '')) > number(translate('2023-10-28', '-', ''))"><xsl:value-of select="*:COMPLEMENTARY_INFO/*:DATE_DISPATCH_NOTICE"></xsl:value-of>T12:00:00+01:00</xsl:when>
	  			<xsl:otherwise><xsl:value-of select="*:COMPLEMENTARY_INFO/*:DATE_DISPATCH_NOTICE"></xsl:value-of>T12:00:00+02:00</xsl:otherwise>
	  		</xsl:choose>	  	
	  	</xsl:variable>
		  <cbc:IssueDate><xsl:value-of select="format-dateTime(xs:dateTime($datetimeAsString), '[Y0001]-[M01]-[D01][Z]')"/></cbc:IssueDate>
	  	<cbc:IssueTime><xsl:value-of select="format-dateTime(xs:dateTime($datetimeAsString), '[H01]:[m01]:[s01][Z]')"/></cbc:IssueTime>
	  </xsl:when>
	  <xsl:otherwise>
		<!-- WARNING: Notice Dispatch Date (BT-05) is Mandatory for all eForms subtypes, but no DATE_DISPATCH_NOTICE was found in TED XML. -->
		<xsl:variable name="message">WARNING: Notice Dispatch Date (BT-05) is Mandatory for all eForms subtypes, but no DATE_DISPATCH_NOTICE was found in TED XML.</xsl:variable>
		<xsl:call-template name="report-warning"><xsl:with-param name="message" select="$message"/></xsl:call-template>
	  </xsl:otherwise>
	</xsl:choose>
	<!-- Notice Version (BT-757): eForms documentation cardinality (Procedure) = 1 | Mandatory for ALL subtypes -->
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Notice Version (BT-757)'"/></xsl:call-template>
	<!-- TBD: hard-coded for now -->
	<cbc:VersionID>01</cbc:VersionID>
	<!-- Future Notice (BT-127): eForms documentation cardinality (Procedure) = * | Mandatory for PIN subtypes 4 and 6; Optional for PIN subtypes 5, 7-9, E1 and E2; Forbidden for other subtypes -->
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Future Notice (BT-127)'"/></xsl:call-template>
	<xsl:if test="$eforms-notice-subtype = ('4', '5', '6', '7', '8', '9')">
		<xsl:choose>
			<xsl:when test="*:OBJECT_CONTRACT/*:DATE_PUBLICATION_NOTICE">
				<cbc:PlannedDate><xsl:value-of select="*:OBJECT_CONTRACT/*:DATE_PUBLICATION_NOTICE[0]"/></cbc:PlannedDate>
			</xsl:when>
			<xsl:when test="$eforms-notice-subtype = ('4', '6')">
			<!-- WARNING: Future Notice (BT-127) is Mandatory for eForms subtypes 4 and 6, but no DATE_PUBLICATION_NOTICE was found in TED XML. -->
			<xsl:variable name="message">WARNING: Future Notice (BT-127) is Mandatory for eForms subtypes 4 and 6, but no DATE_PUBLICATION_NOTICE was found in TED XML.</xsl:variable>
			<xsl:call-template name="report-warning"><xsl:with-param name="message" select="$message"/></xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:if>
	<!-- Procedure Legal Basis (BT-01): eForms documentation cardinality (Procedure) = 1 | Mandatory for ALL subtypes -->
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Procedure Legal Basis (BT-01)'"/></xsl:call-template>
	<cbc:RegulatoryDomain><xsl:value-of select="$legal-basis"/></cbc:RegulatoryDomain>
	<!-- Form Type (BT-03) and Notice Type (BT-02): eForms documentation cardinality (Procedure) = 1 | Mandatory for ALL subtypes -->
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Form Type (BT-03) and Notice Type (BT-02)'"/></xsl:call-template>
	<!-- TBD: hard-coded for now; to use tailored codelists -->
	<cbc:NoticeTypeCode listName="{$eforms-form-type}"><xsl:value-of select="$eforms-notice-type"/></cbc:NoticeTypeCode>
	<!-- Notice Official Language (BT-702) (first): eForms documentation cardinality (Procedure) = 1 | Mandatory for ALL subtypes -->
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Notice Official Language (BT-702) (first)'"/></xsl:call-template>
	<cbc:NoticeLanguageCode><xsl:value-of select="$eforms-first-language"/></cbc:NoticeLanguageCode>
	<xsl:for-each select="$ted-form-additional-languages">
	<!-- Notice Official Language (BT-702) (additional): eForms documentation cardinality (Procedure) = * | Optional for ALL subtypes -->
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Notice Official Language (BT-702) (additional)'"/></xsl:call-template>
		<cac:AdditionalNoticeLanguage>
			<cbc:ID><xsl:value-of select="opfun:get-eforms-language(.)"/></cbc:ID>
		</cac:AdditionalNoticeLanguage>
	</xsl:for-each>
</xsl:template>

<xsl:template name="changes">
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="' efac:changes '"/></xsl:call-template>
</xsl:template>

<xsl:template name="contract-modification">
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="' efac:ContractModification '"/></xsl:call-template>
</xsl:template>

<xsl:template name="publication">
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="' efac:Publication '"/></xsl:call-template>
	<efac:Publication>
		<!-- Notice Publication Identifier (OPP-010): eForms documentation cardinality (Procedure) = ? -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Notice Publication Identifier (OPP-010)'"/></xsl:call-template>
		<!-- TBD: hard-coded for now -->
		
		<efbc:NoticePublicationID schemeName="ojs-notice-id">
			<xsl:choose>
				<xsl:when test="//PROCEDURE/NOTICE_NUMBER_OJ"><xsl:value-of select="//PROCEDURE/NOTICE_NUMBER_OJ"/></xsl:when>
				<xsl:otherwise>n.a.</xsl:otherwise>
			</xsl:choose>
		</efbc:NoticePublicationID>
		
		<!-- OJEU Identifier (OPP-011): eForms documentation cardinality (Procedure) = ? -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'OJEU Identifier (OPP-011)'"/></xsl:call-template>
		<!-- TBD: hard-coded for now -->
		<!-- efbc:GazetteID schemeName="ojs-id">123/2023</efbc:GazetteID-->
		<!-- OJEU Publication Date (OPP-012): eForms documentation cardinality (Procedure) = ? -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'OJEU Publication Date (OPP-012)'"/></xsl:call-template>
		<efbc:PublicationDate>
			<xsl:choose>
				<xsl:when test="//COMPLEMENTARY_INFO/DATE_DISPATCH_NOTICE">
					<xsl:variable name="datetimeAsString">
						<xsl:choose>
							<xsl:when test="number(translate(//COMPLEMENTARY_INFO/DATE_DISPATCH_NOTICE, '-', '')) > number(translate('2023-10-28', '-', ''))"><xsl:value-of select="//COMPLEMENTARY_INFO/DATE_DISPATCH_NOTICE"></xsl:value-of>T12:00:00+01:00</xsl:when>
							<xsl:otherwise><xsl:value-of select="//COMPLEMENTARY_INFO/DATE_DISPATCH_NOTICE"></xsl:value-of>T12:00:00+02:00</xsl:otherwise>
						</xsl:choose>	  	
					</xsl:variable>
					<xsl:value-of select="format-dateTime(xs:dateTime($datetimeAsString), '[Y0001]-[M01]-[D01][Z]')"/>
				</xsl:when>
				<xsl:otherwise>
					2023-03-14					
				</xsl:otherwise>
			</xsl:choose>
		</efbc:PublicationDate>
	</efac:Publication>
</xsl:template>

<xsl:template name="contracting-party">
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="' cac:ContractingParty '"/></xsl:call-template>
	<xsl:apply-templates select="*:CONTRACTING_BODY/*:ADDRESS_CONTRACTING_BODY"/>
	<xsl:apply-templates select="*:CONTRACTING_BODY/*:ADDRESS_CONTRACTING_BODY_ADDITIONAL"/>
</xsl:template>

<!-- end of Procedure-level templates for Notice information -->

<!-- Procedure-level templates for Tendering Terms -->

<xsl:template name="root-tendering-terms">
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="' cac:TenderingTerms '"/></xsl:call-template>
	<cac:TenderingTerms>
		<!-- Cross Border Law (BT-09): eForms documentation cardinality (Procedure) = * | No equivalent element in TED XML -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Cross Border Law (BT-09)'"/></xsl:call-template>
		<!-- Legal Basis (BT-01) Local - Code: eForms documentation cardinality (Procedure) = * | No equivalent element in TED XML -->
		<!-- Legal Basis (BT-01) Local - Text: eForms documentation cardinality (Procedure) = * | Element PROCUREMENT_LAW -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Legal Basis (BT-01) Local - Text'"/></xsl:call-template>
		<xsl:apply-templates select="*:CONTRACTING_BODY/*:PROCUREMENT_LAW"/>
		<!-- Exclusion Grounds (BT-67): eForms documentation cardinality (Procedure) = ? | No Exclusion Grounds in TED XML-->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Exclusion Grounds (BT-67)'"/></xsl:call-template>
		<!-- Lots Max Awarded (BT-33): eForms documentation cardinality (Procedure) = 1 | Optional for PIN subtypes 7-9, CN subtypes 10-14, 16-24, and E3; Forbidden for other subtypes -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Lots Max Awarded (BT-33)'"/></xsl:call-template>
		<!-- Lots Max Allowed (BT-31): eForms documentation cardinality (Procedure) = 1 | Optional for PIN subtypes 7-9, CN subtypes 10-14, 16-24, and E3; Forbidden for other subtypes -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Lots Max Allowed (BT-31)'"/></xsl:call-template>
		<xsl:apply-templates select="*:OBJECT_CONTRACT/*:LOT_DIVISION[*:LOT_MAX_ONE_TENDERER|*:LOT_ALL|*:LOT_MAX_NUMBER|*:LOT_ONE_ONLY]"/>
		<!-- Group Identifier (BT-330): eForms documentation cardinality (Procedure) = 1 | Optional for PIN subtypes 7-9, CN subtypes 10-14, 16-24, and E3; Forbidden for other subtypes -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Group Identifier (BT-330)'"/></xsl:call-template> <!-- should it have cardinality 1? No LotsGroup in TED XML -->
		<!-- Group Lot Identifier (BT-1375): eForms documentation cardinality (Procedure) = 1 | Optional for PIN subtypes 7-9, CN subtypes 10-14, 16-24, and E3; Forbidden for other subtypes -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Group Lot Identifier (BT-1375)'"/></xsl:call-template> <!-- should it have cardinality 1? No LotsGroup in TED XML -->
	</cac:TenderingTerms>
</xsl:template>

<!-- end of Procedure-level templates for Tendering Terms -->



<!-- Procedure-level templates for Tendering Process -->

<xsl:template name="root-tendering-process">
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="' cac:TenderingProcess '"/></xsl:call-template>
	<cac:TenderingProcess>
		<ext:UBLExtensions>
			<ext:UBLExtension>
				<ext:ExtensionContent>
					<efext:EformsExtension>
						<!-- TBD: review after meeting on BT-634 and email from DG GROW -->
						<!-- Procurement Relaunch (BT-634): eForms documentation cardinality (Procedure) = ? | Optional for CN subtypes 10-24 and E3, CAN subtypes 29-37 and E4; Forbidden for other subtypes -->
						<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Procurement Relaunch (BT-634)'"/></xsl:call-template>
					</efext:EformsExtension>
				</ext:ExtensionContent>
			</ext:UBLExtension>
		</ext:UBLExtensions>
		<!-- Procedure Features (BT-88): eForms documentation cardinality (Procedure) = ? | Mandatory for CN subtypes 12, 13, 20, and 21; Optional for PIN subtypes 7-9, CN subtypes 10, 11, 16-19, 22-24, and E3, CAN subtypes 29-37 and E4, CM subtype E5; Forbidden for other subtypes -->
		<xsl:call-template name="main-features-award"/>
		<!-- Procedure Type (BT-105): eForms documentation cardinality (Procedure) = 1 | Mandatory for CN subtypes 10, 11, 16-18, 23, and 24, CAN subtypes 25-31, 36, and 37; Optional for PIN subtypes 7-9, CN subtypes 12, 13, 20-22, and E3, CAN subtypes 33, 34, and E4, CM subtype E5; Forbidden for other subtypes -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Procedure Type (BT-105)'"/></xsl:call-template>
		<xsl:apply-templates select="*:PROCEDURE/(*:DIRECTIVE_2009_81_EC|*:DIRECTIVE_2014_23_EU|*:DIRECTIVE_2014_24_EU|*:DIRECTIVE_2014_25_EU|.)/(self::node()|*)/(*:PT_OPEN|*:PT_RESTRICTED|*:PT_COMPETITIVE_NEGOTIATION|*:PT_COMPETITIVE_DIALOGUE|*:PT_INNOVATION_PARTNERSHIP|*:PT_INVOLVING_NEGOTIATION|*:PT_NEGOTIATED_WITH_PRIOR_CALL|*:PT_AWARD_CONTRACT_WITHOUT_CALL|*:PT_AWARD_CONTRACT_WITH_PRIOR_PUBLICATION|*:PT_AWARD_CONTRACT_WITHOUT_PUBLICATION|*:PT_NEGOTIATED_WITHOUT_PUBLICATION)"/>

		<!-- Lots All Required (BT-763): eForms documentation cardinality (Procedure) = ? | No equivalent element in TED XML -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Lots All Required (BT-763)'"/></xsl:call-template>
		<!-- PIN Competition Termination (BT-756): eForms documentation cardinality (Procedure) = ? | Optional for CAN subtypes 29, 30, 33, and 34; Forbidden for other subtypes -->
		<xsl:call-template name="pin-competition-termination"/>

		<!-- Previous Planning Identifier (BT-125): eForms documentation cardinality (Procedure) = - | Forbidden for CM subtypes 38-40 and E5; Optional for other subtypes. -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Previous Planning Identifier (BT-125)'"/></xsl:call-template>
		<!-- TBD: Discussion about methods of linking to previous notices is ongoing. This mapping/conversion may change. -->
		<!-- TBD: When the notice linked to is of type PIN Only, BT-125 and BT-1251 should be specified at Lot level, not at notice level. -->

		<xsl:apply-templates select="*:PROCEDURE/*:NOTICE_NUMBER_OJ"/>

		<!-- Procedure Accelerated (BT-106): eForms documentation cardinality (Procedure) = ? | Optional for CN subtypes 16-18 and E3, CAN subtypes 29-31 and E4, CM subtype E5; Forbidden for other subtypes -->
		<!-- Procedure Accelerated Justification (BT-1351): eForms documentation cardinality (Procedure) = ? | Optional for CN subtypes 16-18 and E3, CAN subtypes 29-31 and E4, CM subtype E5; Forbidden for other subtypes -->
		<xsl:apply-templates select="*:PROCEDURE/*:ACCELERATED_PROC"/>


		<!-- Direct Award Justification Previous Procedure Identifier (BT-1252): eForms documentation cardinality (Procedure) = ? | Optional for CAN subtypes 25-35 and E4, CM subtype E5; Forbidden for other subtypes -->
		<!-- Direct Award Justification (BT-136) ​/ Code: eForms documentation cardinality (Procedure) = ? | Optional for CAN subtypes 25-35 and E4, CM subtype E5; Forbidden for other subtypes -->
		<!-- Direct Award Justification (BT-135) ​/ Text: eForms documentation cardinality (Procedure) = ? | Optional for CAN subtypes 25-35 and E4, CM subtype E5; Forbidden for other subtypes -->
		<xsl:call-template name="direct-award-justification"/>
	</cac:TenderingProcess>
</xsl:template>

<!-- end of Procedure-level templates for Tendering Process -->



<!-- Procedure-level templates for Procurement Project -->

<xsl:template name="root-procurement-project">
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="' cac:ProcurementProject '"/></xsl:call-template>
	<cac:ProcurementProject>
		<!-- A limited number of BTs are specified for procurement project at root level -->
		<!-- Internal Identifier (BT-22): eForms documentation cardinality (Procedure) = 1 | Optional for ALL Notice subtypes -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Internal Identifier (BT-22)'"/></xsl:call-template>
		<xsl:apply-templates select="*:OBJECT_CONTRACT/*:REFERENCE_NUMBER"/>
		<!-- Title (BT-21): eForms documentation cardinality (Procedure) = 1 | Mandatory for ALL Notice subtypes, except Optional for CM Notice subtypes 38-40 -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Title (BT-21)'"/></xsl:call-template>
		<xsl:apply-templates select="*:OBJECT_CONTRACT/*:TITLE"/>
		<!-- Description (BT-24): eForms documentation cardinality (Procedure) = 1 | Mandatory for ALL Notice subtypes -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Description (BT-24)'"/></xsl:call-template>
		<xsl:choose>
			<xsl:when test="*:OBJECT_CONTRACT/*:SHORT_DESCR">
				<xsl:apply-templates select="*:OBJECT_CONTRACT/*:SHORT_DESCR"/>
			</xsl:when>
			<xsl:otherwise>
				<!-- WARNING: Description (BT-24) is Mandatory for all eForms subtypes, but no SHORT_DESCR was found in TED XML. -->
				<xsl:variable name="message">WARNING: Description (BT-24) is Mandatory for all eForms subtypes, but no SHORT_DESCR was found in TED XML.</xsl:variable>
				<xsl:call-template name="report-warning"><xsl:with-param name="message" select="$message"/></xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
		<!-- Main Nature (BT-23): eForms documentation cardinality (Procedure) = 1 | Optional for ALL Notice subtypes -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Main Nature (BT-23)'"/></xsl:call-template>
		<xsl:apply-templates select="*:OBJECT_CONTRACT/*:TYPE_CONTRACT"/>
		<!-- Additional Nature (BT-531): eForms documentation cardinality (Procedure) = * | No equivalent element in TED XML -->
		<!-- Additional Information (BT-300): eForms documentation cardinality (Procedure) = ? | Optional for ALL Notice subtypes -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Additional Information (BT-300)'"/></xsl:call-template>
		<xsl:call-template name="procedure-note"/>

		<!-- Estimated Value (BT-27): eForms documentation cardinality (Procedure) = ? | Optional for PIN subtypes 4-9, E1 and E2, CN subtypes 10-14, 16-22, and E3, CAN subtypes 29-35 and E4, CM subtype E5; Forbidden for other subtypes -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Estimated Value (BT-27)'"/></xsl:call-template>
		<xsl:apply-templates select="*:OBJECT_CONTRACT/*:VAL_ESTIMATED_TOTAL"/>
		<!-- Classification Type (BT-26): eForms documentation cardinality (Procedure) = 1 | Mandatory for ALL Notice subtypes, except Optional for CM Notice subtypes 38-40 -->
		<!-- Main Classification Code (BT-262): eForms documentation cardinality (Procedure) = 1 | Mandatory for ALL Notice subtypes, except Optional for CM Notice subtypes 38-40 -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Main Classification Code (BT-262)'"/></xsl:call-template>
		<xsl:apply-templates select="*:OBJECT_CONTRACT/*:CPV_MAIN"/>
		<!-- Additional Classification Code (BT-263): eForms documentation cardinality (Procedure) = * | No equivalent element in TED XML at Procedure level -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Additional Classification Code (BT-263)'"/></xsl:call-template>

		<!-- Place of Performance (*) -> RealizedLocation | No equivalent element in TED XML at Procedure level -->
		<!-- Place of Performance Additional Information (BT-728) -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Place of Performance Additional Information (BT-728)'"/></xsl:call-template>
		<!-- Place Performance City (BT-5131): eForms documentation cardinality (Procedure) = ? | No equivalent element in TED XML at Procedure level -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Place Performance City (BT-5131)'"/></xsl:call-template>
		<!-- Place Performance Post Code (BT-5121): eForms documentation cardinality (Procedure) = ? | No equivalent element in TED XML at Procedure level -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Place Performance Post Code (BT-5121)'"/></xsl:call-template>
		<!-- Place Performance Country Subdivision (BT-5071): eForms documentation cardinality (Procedure) = ? | No equivalent element in TED XML at Procedure level -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Place Performance Country Subdivision (BT-5071)'"/></xsl:call-template>
		<!-- Place Performance Services Other (BT-727): eForms documentation cardinality (Procedure) = ? | No equivalent element in TED XML at Procedure level -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Place Performance Services Other (BT-727)'"/></xsl:call-template>
		<!-- Place Performance Street (BT-5101): eForms documentation cardinality (Procedure) = ? | No equivalent element in TED XML at Procedure level -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Place Performance Street (BT-5101)'"/></xsl:call-template>
		<!-- Place Performance Country Code (BT-5141): eForms documentation cardinality (Procedure) = ? | No equivalent element in TED XML at Procedure level -->
		<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="'Place Performance Country Code (BT-5141)'"/></xsl:call-template>
	</cac:ProcurementProject>
</xsl:template>

<!-- end of Procedure-level templates for Procurement Project -->


<!-- Initial template to process each Lot -->

<xsl:template name="procurement-project-lots">
<!-- The following line can be un-commented to show the variable lot-numbers-map -->
<!-- <xsl:copy-of select="$lot-numbers-map" copy-namespaces="no"/> -->
	<xsl:call-template name="include-comment"><xsl:with-param name="comment" select="' multiple cac:ProcurementProjectLot '"/></xsl:call-template>
	<xsl:apply-templates select="*:OBJECT_CONTRACT/*:OBJECT_DESCR"/>
</xsl:template>


</xsl:stylesheet>
