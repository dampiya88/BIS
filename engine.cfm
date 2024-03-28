<!--- ******************************* DOCUMENTATION HEADER START ************************** [ ***** DETAILS ****** ]
Filename: engine.cfm
* Version: v 1.1
Function: This is the main switch which decodes the URL.action string and tells it where to go.

Updated: Jas Panesar

Date Created: December 10, 2007
[ ***** D E P E N D A N C I E S ***** ]

[ Input ]

URL.action    - The action to goto, called from index.cfm.

************************************ DOCUMENTATION HEADER END ***************************--->

<!--- Include global settings for all switches --->
<!--- DB information is stored within settings.cfm --->
<cfparam name="url.action" default="">
<cfinclude template = "settings.cfm">
<cfset application.fwUtilService.ensureSessionLanguage()>
<cfset scrollerheight = 500>
<!--- Instantiate global objects and factories --->

<cfset UDFLib = createObject("component", "#application.ComponentPath#.UDFLib").init() />
<cfif len(trim(url.action))>
	<cfset request["fr.transaction.name"] = url.action>
</cfif>
<cfset cadminrole = UDFLib.getUserType()>
<cfset request.cadminrole = cadminrole>
<cfset request.clientAdmin_Role = structKeyExists(application, 'ClientAdminRoles') ? trim(application.ClientAdminRoles) : '3'>
<cfset request.AdminManager_Role = structKeyExists(application, 'AdminManagerRoles') ? trim(application.AdminManagerRoles) : '3'>
<cfset request.clientAdmin_Role = listfind(request.cadminrole,'clientsenioradmin')
	? listAppend(request.clientAdmin_Role, '46')
	: request.clientAdmin_Role>
<cfset cadmin = application.fwUtilService.fixedBooleanFormat(
	listfind(cadminrole,'superadmin')
	OR listfind(cadminrole,'bisadmin')
	OR listfind(cadminrole,'clientsenioradmin')
	OR listfind(cadminrole,'clientadmin')
	OR listfind(cadminrole,'locationadmin')
	OR listfind(cadminrole,'courseadmin')
	OR listfind(cadminrole,'adminmanager')
	OR listfind(cadminrole,'senniormanagerreporting')
	OR listfind(cadminrole,'managerreporting')
	OR listfindNoCase(cadminrole,'LocationManager')
	OR listfindNoCase(cadminrole,'systemadmin')
)>
<!--- Define failed to NULL, failed is used when login is incorrect --->
<cfif NOT IsDefined( 'failed' )><cfparam name = "failed" default = ""></cfif>

<!--
	If the user isn't logged in, we force the private company number
	(that is, the company number to use for any *private* (eg, eCommerce)
	pages we visit) to either the company for the given category, or
	1.
-->
<cfif IsDefined("URL.category") OR IsDefined("URL.company")>
	<cfset objManageCompany = createObject("component", "#application.ComponentPath#.ManageCompany").init() />
	<cftry>
	<cfif structKeyExists(url, "company") AND val(trim(url.company)) GT 0 AND isvalid('integer', url.company)>
		<cfset companyNumber = trim(url.company)>
	<cfelse>
		<cfset companyNumber = objManageCompany.GetCompanyNumberForCategory(dbDatasource, URL.category)>
	</cfif>
	<cfcatch>
		<cfset companyNumber = 0>
	</cfcatch>
	</cftry>
	<cfcookie name="PrivateSiteCompanyNumber" value="#companyNumber#" />
	<cfif companyNumber NEQ 0>
		<cfcookie name="PrivateSiteCurrencyType" value="#objManageCompany.GetCurrencyTypeForCompany(companyNumber)#" />
	</cfif>
<cfelse>
	<cfif url.action EQ 'learner.Invitation' and (isdefined("url.form.fldInvitationCode") OR isdefined("form.fldInvitationCode")) and isNumeric(form.fldInvitationCode) AND left(form.fldInvitationCode, 2) EQ '10'>
		<cfset objInvitation = request.InvitationManager.GetInvitationByCode(form.fldInvitationCode)>
		<cftry>
			<cfcookie name="PrivateSiteCompanyNumber" value="#objInvitation.getNode().getCompanyID()#" />
		<cfcatch>
			<cfif isObject(objInvitation.getUser().getCompany()) AND val(objInvitation.getUser().getCompany().getID())>
				<cfcookie name="PrivateSiteCompanyNumber" value="#objInvitation.getUser().getCompany().getID()#" />
			<cfelse>
				<cfcookie name="PrivateSiteCompanyNumber" value="1" />
			</cfif>
		</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT IsDefined("cookie.PrivateSiteCompanyNumber")>
		<cfcookie name="PrivateSiteCompanyNumber" value="1" />
	</cfif>
</cfif>
<!--- To fix branding issue for custom url case --->
<cfif structKeyExists(session, 'loginusercompanyid') AND val(session.loginusercompanyid) AND session.loginusercompanyid NEQ cookie.PrivateSiteCompanyNumber AND action NEQ 'learner.invitation'>
	<cfcookie name="PrivateSiteCompanyNumber" value="#session.loginusercompanyid#" />
	<cfcookie name="PrivateSiteCurrencyType" value="#application.ManageCompany.GetCurrencyTypeForCompany(session.loginusercompanyid)#" />
</cfif>

<cfset request.appVersion=application.appVersion><!--- Change the version for each css or js change to avoid caching issues --->

<cfset currenttime = NOW()>
<cfif structKeyExists(session, "loginUserId") AND val(session.loginUserId) GT 0>
	<cfset local.userObj = createObject("component", application.servicePath & ".user")>
	<cfif structKeyExists(session, "tAndCUpdatedNotification")
		AND session.tAndCUpdatedNotification == 1
		AND local.userObj.showAcceptTAndCNotification(userId = session.loginUserId).showAcceptTAndCNotification EQ 0>
		<cfset structDelete(session, "tAndCUpdatedNotification")>
	</cfif>
	<cfset local.redirectURL = urlEncodedFormat(CGI.HTTP_URL)>
	<cfset local.NORedirectionEditProfilePages = ["learner.editprofile", "usr.logout", "home.termsandconditions", "learner.changepassword", "learner.setupMFA", "home.verifyMFA"]>
	<cfif url.action NEQ "home.termsandconditions"
		AND url.action NEQ "usr.logout"
		AND url.action NEQ "learner.help"
		AND structKeyExists(session, "redirectTermsAndConditions")
		AND session.redirectTermsAndConditions EQ 1
		AND (NOT structKeyExists(session, "directLogin") || session.directLogin EQ 0)
		AND local.userObj.checkToAcceptTerms(userId = session.loginUserId) EQ 1>
		<cfset variables.redirectOnAccept = "">
		<cfif url.action EQ "home.launchCourse" OR url.action EQ "home.launchForm">
			<cfset variables.redirectOnAccept = "redirect=" & urlEncodedFormat(CGI.HTTP_URL)>
		</cfif>
		<cflocation url = "#application.sysBasePath#?action=home.termsandconditions&#variables.redirectOnAccept#"
			addToken = "no">
	<cfelseif action NEQ "learner.changepassword"
		AND action NEQ "usr.logout"
		AND (structKeyExists(session, 'passwordExpired') AND session.passwordExpired)
		AND local.userObj.isPasswordExpired(userId = session.loginuserid)
		AND url.action NEQ "home.termsandconditions">
		<cflocation url = "/v1/index.cfm?action=learner.changePassword&expwd=1" addtoken = "false">
	<cfelseif url.action NEQ "learner.editprofile"
		AND url.action NEQ "usr.logout"
		AND structKeyExists(session, "redirectProfilePage")
		AND session.redirectProfilePage EQ 1
		AND (NOT structKeyExists(session, "directLogin") OR session.directLogin EQ 0)
		AND NOT (structKeyExists(session, "loginUserTemporaryPassword") AND session.loginUserTemporaryPassword EQ 1)
		AND url.action NEQ "home.termsandconditions"
		AND url.action NEQ "learner.changepassword"
		AND url.action NEQ "learner.updateProfile">
		<cflocation url = "#application.sysBasePath#?action=learner.editprofile"
			addToken = "no">
	<cfelseif 
		arrayFindNoCase(local.NORedirectionEditProfilePages, url.action) EQ 0
	>
		<cfif 
			structKeyExists(session, 'mfaSettings')
			AND session.mfaSettings.mfaEnabled EQ 1
			AND session.MFASettings.isMFASetupForUser EQ 1
			AND session.MFASettings.deviceIsTrusted EQ 0
			AND session.MFASettings.isMFAVerifiedForUser EQ 0
			AND (!structKeyExists(session, "directLogin") || session.directLogin == 0)
		>
			<cflocation url="#application.sysFolder#/index.cfm?action=home.verifyMFA&redirect=#local.redirectURL#" addtoken="false">
		</cfif>
	<cfelseif 
		lCase(url.action) NEQ "home.termsandconditions"
		AND lCase(url.action) NEQ "usr.logout"
		AND lCase(url.action) NEQ "learner.help"
		AND lCase(url.action) NEQ "learner.setupmfa"
		AND (!structKeyExists(session, "directLogin") || session.directLogin == 0)
	>
		<cfif 
			structKeyExists(session, 'mfaSettings')
			AND session.mfaSettings.mfaEnabled EQ 1
			AND session.mfaSettings.isMFASetupForUser EQ 0
		>
			<cflocation url="#application.sysFolder#/index.cfm?action=learner.setupMFA&redirect=#local.redirectURL#" addtoken="false">
		</cfif>
	</cfif>
</cfif>
<cfoutput>
	<cfset variables.ActionEventNotFound = 0>
	<cfset variables.TotalActionEvents = 11><!--- This number should be the number of sub engine files included. --->
	<cfinclude template="engine.usr.cfm">
	<cfinclude template="engine.home.cfm">
	<cfinclude template="engine.learner.cfm">
	<cfinclude template="engine.manager.cfm">
	<cfinclude template="engine.bisadmin.cfm">
	<cfinclude template="engine.store.cfm">
	<cfinclude template="engine.trm.cfm">
	<cfinclude template="engine.classroom.cfm">
	<cfinclude template="engine.CV.cfm">
	<cfinclude template="engine.Equipment.cfm">
	<cfinclude template="engine.forms.cfm">
	<!--- Show 404 page not found message when no action found in engine files. --->
	<cfif variables.ActionEventNotFound EQ variables.TotalActionEvents>
		<cfinclude template="common/404PageNotFound.cfm">
	</cfif>
</cfoutput>
