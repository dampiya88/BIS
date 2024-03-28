<cfparam name="attributes.action" default="">
<cfparam name="variables.ActionEventNotFound" default="0">
<cfswitch expression = "#attributes.action#">
	<!--- ******* MANAGER LEARNERS VIEW / DASHBOARD ******* --->
	<cfcase value="manager.LearnerView">
		<cfset variables.dec = decrypt('#url.node#', 'password', 'BLOWFISH', 'Hex')>
		<cfset variables.enc = application.fwDummy.uEncrypt(variables.dec)>
		<cfif structKeyExists(url, "newuser")>
			<cfset variables.uDec = decrypt('#url.newuser#', 'password', 'BLOWFISH', 'Hex')>
			<cfset user = application.fwDummy.uEncrypt(variables.uDec)>
			<cflocation url = "#application.sysBasePath#?action=manager.users&nodes=#variables.enc#&newuser=#user#">
		</cfif>
		<cflocation url = "#application.sysBasePath#?action=manager.users&nodes=#variables.enc#">
	</cfcase>


    <!--- ******* MANAGER EMAIL INVITATION CODE / DASHBOARD ******* --->
	<cfcase value="manager.emailInvitationCode">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template="learner/newHome/qryGetEmailFailToAddress.cfm">
		<cfinclude template = "manager/qryEmailInvitationCode.cfm">
		<cfinclude template = "manager/newManageLearners/qryUserLanguage.cfm">
		<cfinclude template = "learner/qryGetCompanyName.cfm">
		<cfinclude template = "manager/dspEmailInvitationCode.cfm">
		<cfinclude template="layout/BISFooterLogged.cfm">
	</cfcase>

    <!--- ******* MANAGER PRINT INVITATION CODE / DASHBOARD ******* --->
	<cfcase value="manager.printInvitationCode">
		<!--- Never allow public access to numeric user ID --->
		<cfif isDefined("user") && isValid('integer', user)>
			<cfinclude template = "secure/chk_secured.cfm">
		</cfif>
		<cfinclude template = "manager/qryEmailInvitationCode.cfm">
		<cfinclude template = "manager/newManageLearners/qryUserLanguage.cfm">
		<cfinclude template = "learner/qryGetCompanyName.cfm">
		<cfinclude template = "manager/newManageLearners/dspPrintInvitationCode.cfm">
	</cfcase>

    <!--- ******* MANAGER DEACTIVATE LEARNERS / DASHBOARD ******* --->
	<cfcase value="manager.DeActivateLearners">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "manager/qryDeActivateLearner.cfm">
		<cfinclude template = "manager/dspDeActivateLearner.cfm">
		<cfinclude template="layout/BISFooterLogged.cfm">
	</cfcase>

    <!--- ******* MANAGER ADD LEARNER FORM/ DASHBOARD ******* --->
	<cfcase value="manager.AddLearnerForm">
		<cfset variables.locationId = left(url.nodes, 1) EQ "_" ? url.nodes : application.fwDummy.uEncrypt(url.nodes)>
		<cflocation url = "#application.sysBasePath#?action=manager.user&node=#variables.locationId#" addtoken = "no">
	</cfcase>

 	<!--- ******* MANAGER VIEW  LEARNER PROFILE BEFORE ACCOUNT ACTIVTION/ DASHBOARD ******* --->
	<cfcase value="manager.ViewLearnerProfile-OLD">
		<cfabort>
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
    <cfset user = left(url.user, 1) EQ "_" ? application.fwDummy.uDecrypt(url.user) : url.user>
		<cfinclude template = "manager/qryViewLearnerProfile.cfm">
		<cfinclude template = "learner/UpdateProfile/qryGetSysLanguages.cfm">
		<cfinclude template = "learner/UpdateProfile/qryGetAllStatesAndCountries.cfm" >
		<cfinclude template = "manager/newManageLearners/dspViewLearnerProfile.cfm">
		<cfinclude template="layout/BISFooterLogged.cfm">
	</cfcase>

	<!--- ******* MANAGER EDIT  LEARNER PROFILE/ DASHBOARD ******* --->
	<cfcase value="manager.EditLearnerProfile">
		<cfabort>
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfif (structKeyExists(form, 'DuplicateEmail') AND form.DuplicateEmail EQ 1)
			OR NOT structKeyExists(form, 'email1') OR NOT len(form.email1)>
			<cfset noduplicateemail = 0>
		<cfelse>
			<cfinclude template = "manager/newManageLearners/dspDuplicateEmailAddress.cfm">
		</cfif>
		<cfset noDuplicateEmployeeID = 0>
			<cfif isDefined("noduplicateemail") AND noduplicateemail EQ 0 AND isDefined("form.IDNumber") AND len(trim(form.IDNumber))  >
				<cfset noDuplicateEmployeeID = request.UserManager.ChkDuplicateEmployeeID(EmployeeID = trim(form.IDNumber), CompanyID = form.fldcompanyid, UserID = form.user)>
				<cfif noDuplicateEmployeeID NEQ 0>
					<cfinclude template = "learner/dspDuplicateEmployeeIdMsg.cfm">
				</cfif>
			</cfif>
		<cfif isDefined("noduplicateemail") AND (#noduplicateemail# EQ 0) AND noDuplicateEmployeeID EQ 0>
			<cfinclude template = "manager/qryEditLearnerProfile.cfm">
			<cfif structKeyExists(session, 'GetCompanyGroupID') AND val(session.GetCompanyGroupID) GT 0>
				<cflocation url="index.cfm?action=manager.LearnerView&node=#encrypt('#session.GetCompanyGroupID#', 'password', 'BLOWFISH', 'Hex')#&newuser=#encrypt(form.user, 'password', 'BLOWFISH', 'Hex')#">
			<cfelse>
				<cflocation url="index.cfm?action=bisadmin.ManageCompanies">
			</cfif>
			<!--- END: OSSA - BIS-3631 TV0119 8/25/2017 --->
		</cfif>
		<cfinclude template="layout/BISFooterLogged.cfm">
	</cfcase>

	<!--- ******* MANAGER SEND OPEN INVITATIONS/ DASHBOARD ******* --->
	<cfcase value="manager.SendOpenInvitations">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset variables.params = "">
		<cfif structKeyExists(url, "node")>
			<cfset variables.params = "#variables.params#&node=#url.node#">
		</cfif>
		<cfif structKeyExists(url, "includesubloc")>
			<cfset variables.params = "#variables.params#&includesubloc=#url.includesubloc#">
		</cfif>
		<cflocation  url="/v1/index.cfm?action=manager.sendopeninvitations#variables.params#">
	</cfcase>

	<!--- ******* MANAGER SEND OPEN INVITATIONS FOR A HEIRARCHY/ DASHBOARD ******* --->
	<cfcase value="manager.SendOpenInvitationsForAHierarchy">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "manager/OpenInvitations/qryGetOpenInvitationForWholehierarchy.cfm">
		<cfinclude template = "manager/newManageLearners/qryUserLanguage.cfm">
		<cfinclude template = "learner/newHome/qryGetEmailFailToAddress.cfm">
	  	<cfinclude template = "manager/OpenInvitations/dspOpenInvitationsForWholehierarchy.cfm">
	  	<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* MANAGER DCRReport / DASHBOARD (PART OF NEW DESIGN)******* --->
	<cfcase value="manager.DCRReport">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template = "secure/chk_secured.cfm">
        <cfinclude template = "manager/dspDecriptURLVariables.cfm">
		<cfinclude template = "BISadmin/ManageReports/DCResults.cfm">
	</cfcase>
	<!--- ******* MANAGER DCRReport for scorm courses/ DASHBOARD (PART OF NEW DESIGN)******* --->
	<cfcase value="manager.DCRSCORMReport">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template = "secure/chk_secured.cfm">
        <cfinclude template = "manager/dspDecriptURLVariables.cfm">
		<cfinclude template = "BISadmin/ManageReports/DCScormResults.cfm">
	</cfcase>
	<!--- ******* ADMINISTRATOR SYSTEM SETUP/ DASHBOARD ******* --->
	<cfcase value="manager.SystemSetUp">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManagerCourses/qryGetBannerUrlTypes.cfm">
		<cfinclude template = "learner/UpdateProfile/qryGetAllStatesAndCountries.cfm" >
		<cfinclude template = "learner/UpdateProfile/qryGetSysLanguages.cfm">
		<cfinclude template = "manager/actSystemSetup.cfm">
	  	<cfinclude template = "manager/dspSystemSetUp.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="manager.ReportingDetails">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="manager.EmailCourseCertificate">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="manager.uploadmultipleuserrecord">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset EventTo = 'manager.LearnerView'>
		<cfinclude template="BISadmin/ManageUsers/actUploadMultipleUserTrainingRecord.cfm">
	</cfcase>

	<cfcase value="manager.downloadexcelnetworkcourses">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "manager/generateNetworkCoursesExcel.cfm">
	</cfcase>
	
	<cfdefaultcase>
		<cfset variables.ActionEventNotFound = variables.ActionEventNotFound + 1>
	</cfdefaultcase>
</cfswitch>