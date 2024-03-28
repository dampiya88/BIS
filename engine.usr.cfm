<cfparam name="attributes.action" default="">
<cfparam name="variables.ActionEventNotFound" default="0">
<cfswitch expression = "#attributes.action#">
	<cfcase value="usr.redirect">
		<cfset XFA.redirect="learner.home">
		<cfset variables.protocol = application.appMode EQ 'Production' ? 'https' : 'http'>
		<cfheader statuscode="301" statustext="Moved Permanently">
		<cfheader name="Location" value="#variables.protocol#://#cgi.HTTP_HOST##application.sysBasePath#?action=home.loginForm">
		<cfabort>
	</cfcase>

	<cfcase value="usr.login">
		<cfset failed = "false">
		<cfset variables.protocol = application.appMode EQ 'Production' ? 'https' : 'http'>
		<cfheader statuscode="301" statustext="Moved Permanently">
		<cfheader name="Location" value="#variables.protocol#://#cgi.HTTP_HOST##application.sysBasePath#?action=home.loginForm">
		<cfabort>
	</cfcase>

	<cfcase value="usr.validate">
		<cfset XFA.redirect="usr.redirect">
		<cfset variables.protocol = application.appMode EQ 'Production' ? 'https' : 'http'>
		<cfheader statuscode="301" statustext="Moved Permanently">
		<cfheader name="Location" value="#variables.protocol#://#cgi.HTTP_HOST##application.sysBasePath#?action=home.loginForm">
		<cfabort>
	</cfcase>

	<cfcase value="usr.incorrect">
		<cfset variables.protocol = application.appMode EQ 'Production' ? 'https' : 'http'>
		<cfheader statuscode="301" statustext="Moved Permanently">
		<cfheader name="Location" value="#variables.protocol#://#cgi.HTTP_HOST##application.sysBasePath#?action=home.loginForm">
		<cfabort>
	</cfcase>

	<cfcase value = "usr.logout">
		<cfset XFA.submitForm="usr.validate">
		<cfinclude template = "usr/act_logout.cfm">
		<cfif isDefined("session.loginUserLanguagePref")>
			<cflocation url="#application.sysFolder#/index.cfm?action=home.loginForm&Language=#session.loginUserLanguagePref#" addtoken="no">
		<cfelseif structKeyExists(url, "termsAccepted") AND url.termsAccepted EQ 0>
			<cflocation url="#application.sysFolder#/index.cfm?action=home.loginform&termsaccepted=0" addtoken="no">
		<cfelse>
			<cflocation url="#application.sysFolder#/index.cfm?action=home.loginForm" addtoken="no">
		</cfif>
	</cfcase>
	<!--- BEGIN: OSSA - LMS - New ENDORSEMENT and Global ID feature (Billable) - BIS-3631 8/25/2017 TV0119 --->
	<cfcase value = "usr.generateUserUploadExcel">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "usr/generateUserUploadExcel.cfm">
	</cfcase>
	<!--- END: OSSA - LMS - New ENDORSEMENT and Global ID feature (Billable) - BIS-3631 8/25/2017 TV0119 --->
	<cfdefaultcase>
		<cfset variables.ActionEventNotFound = variables.ActionEventNotFound + 1>
	</cfdefaultcase>
</cfswitch>