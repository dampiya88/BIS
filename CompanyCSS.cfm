<cfset application.util.recordTemplatePathUsage(template=getCurrentTemplatePath())>
<cfcontent type="text/css" />
<cfinclude template = "settings.cfm" />
<cfsilent>
<cfif not isDefined("URL.companyno") OR (isDefined("URL.companyno") AND trim(URL.companyno) EQ "")>
	<cfset URL.companyno = 1>
</cfif>
<cfquery name="qryCompanyBanner" datasource="#application.dsn#">
  SELECT fldCSSFileContent FROM tblusercompany WHERE fldUserCompany_ID = <cfqueryparam value="#val(URL.companyno)#" cfsqltype="INTEGER" maxlength="11">
</cfquery>
<cfif len(trim(qryCompanyBanner.fldCSSFileContent)) EQ 0>
  <cfquery name="qryCompanyBanner" datasource="#application.dsn#">
    SELECT fldCSSFileContent FROM tblusercompany WHERE fldUserCompany_ID = <cfqueryparam value="1" cfsqltype="INTEGER">
  </cfquery>
</cfif>
</cfsilent><cfoutput>#qryCompanyBanner.fldCSSFileContent#</cfoutput>
