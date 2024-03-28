<cfparam name="attributes.action" default="">
<cfparam name="variables.ActionEventNotFound" default="0">
<cfswitch expression = "#attributes.action#">
	<!--- BISTRAINER PUBLIC HOME  (home.Welcome)   --->
	<cfcase value="home.Welcome">
		<cfheader statuscode="301" statustext="Moved permanently">
		<cfheader name="Location" value="#application.BISSiteURL#">
	</cfcase>

	<cfcase value="home.loginForm">
		<cfset request.UdFLib.redirectNewSite(companyid=1, always=true)>
	</cfcase>

	<!--- CONTACT US Email  (home.contactUSEmail) --->
	<cfcase value="home.contactUsEmail">
		<cfinclude template="public/qryGetALanguageName.cfm">
		<cfinclude template="learner/newHome/qryGetEmailFailToAddress.cfm">
		<cfinclude template="public/dspContactUsEmail.cfm">
	</cfcase>

	<!--- TERMS AND CONDITIONS (home.termsAndConditions) --->
	<cfcase value="home.termsAndConditions">
		<!--- Check and redirect to responsive site --->
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- PRIVACY POLICY (home.privacyPolicy) --->
	<cfcase value="home.PrivacyPolicy">
		<cflocation url = "#application.fwDummy.buildUrl(
			action = "home.termsandconditions",
			path = application.sysBasePath,
			queryString = "privacy=1"
		)#" addtoken = "no">
	</cfcase>

	<!--- LOGIN Password Forget --->
	<cfcase value="home.ForgetPassword">
		<cflocation url="#application.sysBasePath#?action=home.forgotPassword" addtoken="false">
	</cfcase>

	<!--- BISTRAINER SYSTEM REQUIREMENTS  (home.SysemRequirements)   --->
	<cfcase value="home.SystemRequirements">
		<!--- Check and redirect to responsive site --->
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- BISTRAINER PUBLIC LEARNER ADD FORM (home.AddLearnerForm)  --->
	<cfcase value="home.AddLearnerForm">
		<cfif !val(session?.allowAddLearnerForm)>
			<cflocation url="#application.sysBasePath#?action=public.noaccess" addtoken="false">
		</cfif>
		<!--- 2023-07-25 This is still in user from SSO for fountain tire and WSP --->
		<cfset xfa.Title = "BISTrainer - System Requirements!" />
		<cfinclude template = "public/qryGetALanguageName.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#" />
		<cfinclude template = "learner/UpdateProfile/qryGetAllStatesAndCountries.cfm" >
		<cfinclude template = "usr/publicLearners/dspAddPublicLearnerForm.cfm">
		<cfinclude template = "layout/BISFooter1.cfm">
	</cfcase>

	<!--- BISTRAINER PUBLIC LEARNER ADD FORM (home.AddLearner)  --->
	<cfcase value="home.AddLearner">
		<cfset xfa.Title = "BISTrainer - System Requirements!">
		<cfinclude template = "public/qryGetALanguageName.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "usr/publicLearners/dspAddPublicLearnerComplete.cfm">
		<cfinclude template = "layout/BISFooter1.cfm">
	</cfcase>
	<cfcase value="home.unsubscribeemail">
		<cfinclude template="learner/actUnsubscribeEmail.cfm">
	</cfcase>
	<cfdefaultcase>
		<cfset variables.ActionEventNotFound = variables.ActionEventNotFound + 1>
	</cfdefaultcase>
</cfswitch>