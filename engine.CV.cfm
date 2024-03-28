<!---
	File Name		: engine.CV.cfm
	Date Created	: 24 Apr 2015
	Purpose			: actions for assessment related pages.
 --->
<cfparam name="attributes.action" default="">
<cfparam name="variables.ActionEventNotFound" default="0">
<cfswitch expression = "#attributes.action#">

	<!--- FormTemplates --->
	<cfcase value="CV.FormTemplates">
		<cfset XFA.title = "Form Templates">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "cv/AssessmentFormTemplates.cfm">
		<cfinclude template="layout/BISFooterlogged.cfm">
	</cfcase>

	<!--- Form settings --->
	<cfcase value="CV.AssessmentFormsSettings">
		<cfset XFA.title = "Assessment Form">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "cv/AssessmentFormsSettings.cfm">
		<cfinclude template="layout/BISFooterlogged.cfm">
	</cfcase>

	<cfdefaultcase>
		<cfset variables.ActionEventNotFound = variables.ActionEventNotFound + 1>
	</cfdefaultcase>
</cfswitch>