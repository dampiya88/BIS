<cfparam name="attributes.action" default="">
<cfparam name="variables.ActionEventNotFound" default="0">
<cfswitch expression = "#attributes.action#">
	<!--- ***** Class Room Calendar Admin Home***** --->
	<cfcase value="classroom.calendar">
    	<!---<cfset XFA.title = "Classroom Calendar">--->
		<cfset request.current_module = "calendar">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
        <cfinclude template = "classroom/calendar.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="classroom.summary">
		<cfset request.current_module = "calendar">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- ***** Class Room Calendar Home***** --->
	<cfcase value="classroom.home">
		<cfif structKeyExists(url,"public") AND url.public EQ 1 AND structKeyExists(url,"company") AND val(url.company) AND (listfindnocase(request.cadminrole,'superadmin') OR listfindnocase(request.cadminrole,'bisadmin'))>
			<cfinclude template = "usr/act_logout.cfm">
			<cflocation url = "index.cfm?action=classroom.home&company=#url.company#">
		<cfelseif structKeyExists(url,"company") AND val(url.company) AND structKeyExists(url,"logoutuser") AND val(url.logoutuser) AND structKeyExists(url,"eventid")>
			<cfinclude template = "usr/act_logout.cfm">
			<cflocation url = "index.cfm?action=classroom.home&company=#url.company#&eventid=#url.eventid#">
		</cfif>
		<cfif structKeyExists(url, "company")>
			<cfset variables.companyId = url.company>
		<cfelseif val(session?.loginUserCompanyId) GT 0>
			<cfset variables.companyId = val(session?.loginUserCompanyId)>
		<cfelse>
			<cfquery name="qryGetCompanyByURL" datasource="#application.dsn#">
				SELECT DISTINCT C.fldUserCompany_ID
				FROM tblusercompany C
				WHERE C.fldActive = 1
					AND C.fldCustomUrl LIKE <cfqueryparam value="%#cgi.http_host#%" cfsqltype="varchar">;
			</cfquery>
			<cfif qryGetCompanyByURL.recordcount>
				<cfset cookie.PrivateSiteCompanyNumber = qryGetCompanyByURL.fldUserCompany_ID>
				<cfset variables.companyId = qryGetCompanyByURL.fldUserCompany_ID>
			<cfelse>
				<cfset variables.companyId = 1>
			</cfif>
		</cfif>
		<cfif NOT isValid('integer', variables.companyId)>
			<cflocation url = "/v1/index.cfm?action=home.loginForm&reason=12&Language=1" addtoken="false">
		</cfif>
		<cfif structKeyExists(url, "eventId") AND val(url.eventId) GT 0>
			<cflocation url = "v1/index.cfm?action=classroom.eventdetails&event=#application.fwDummy.uEncrypt(val(url.eventId))#&company=#application.fwDummy.uEncrypt(variables.companyId)#">
		<cfelseif NOT structKeyExists(url, "company")>
			<cflocation url = "#application.sysBasePath#?#cgi.query_string#&company=#application.fwDummy.uEncrypt(variables.companyId)#">
		<cfelse>
			<cfset application.udFLib.redirectNewSite()>
		</cfif>
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="classroom.ViewAll">
		<cfif NOT structKeyExists(session, 'locale') AND structkeyexists(url,'company') AND isNumeric(url.company) AND isValid("integer", url.company)>
			<cfset getlanguage = request.ManageCompany.getLanguageFromCompanySettings(companyId = url.company)>
			<cfset session.locale = getlanguage.locale>
		<cfelseif NOT structKeyExists(session, 'locale')>
			<cfset session.locale = "English (US)">
		</cfif>
		<cfif StructKeyExists(url, "company") AND Val(url.company) AND isValid("integer", url.company)>
			<cfset variables.CompanyID = url.company>
		<cfelseif StructKeyExists(session, "loginuserid") AND Val(session.loginuserid)>
			<cfset variables.CompanyID = session.loginusercompanyid>
		</cfif>
		<cfset variables.course = "">
		<cfif StructKeyExists(url, "course") AND len(trim(url.course))>
			<cfset variables.course = url.course>
		</cfif>
		<cflocation url = "/index.cfm?action=classroom.home&company=#url.company#&listView=1&course=#variables.course#"><!--- Redirecting to home action on the old page, that will take care of the rest. --->
	</cfcase>

	<cfcase value="classroom.classroomlist">
		<cfset application.udFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="classroom.manageclassroom">
		<!---<cfset XFA.title = "Manage Classroom">--->
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="classroom.instructor">
		<!---<cfset XFA.title = "Instructors">--->
        <cfset request.current_module = "instructor">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template ="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "classRoom/actInstructor.cfm">
		<cfinclude template = "classRoom/instructor.cfm">
		<cfinclude template ="layout/BISFooter.cfm">
		<cfset structDelete(session, 'classroomAddInstructor')>
	</cfcase>

	<cfcase value="classroom.manageInstructor">
		<!---<cfset XFA.title = "Manage Instructors">--->
		<cfset request.current_module = "instructor">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template ="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "classRoom/actManageInstructor.cfm">
		<cfinclude template = "classRoom/manageInstructor.cfm">
		<cfinclude template ="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="classroom.course">
		<!---<cfset XFA.title = "Manage Course">--->
		<cfset request.current_module = "calendar">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "learner/UpdateProfile/qryGetAllStatesAndCountries.cfm" >
		<cfinclude template = "ClassRoom/actClassroomCourse.cfm">
		<cfinclude template = "ClassRoom/ClassroomCourse.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="classroom.uploadCourse">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "classroom/actCourseUpload.cfm">
	</cfcase>

	<cfcase value="classroom.generateInstructorMatrixReport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "classroom/generateInstructorMatrixReport.cfm">
	</cfcase>

	<cfcase value="classroom.multiplecourseupload">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "classRoom/actMultipleCourseUpload.cfm">
	</cfcase>

	<cfcase value="classroom.classroomevent">
		<!---<cfset XFA.title = "Manage Event">--->
		<cfset request.current_module = "calendar">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template ="layout/BISHeaderPrivate.cfm">
		<cfif structKeyExists(url, 'encrypt')>
			<cfif structKeyExists(url, 'event')>
				<cfset url.eid = application.fwDummy.uDecrypt(url.event)>
			</cfif>
			<cfif structKeyExists(url, 'instructor')>
				<cfset url.cid = application.fwDummy.uDecrypt(url.instructor)>
			</cfif>
		</cfif>
		<cflocation url = "#application.sysBasePath#?action=classroom.eventdetailsadmin&event=#application.fwDummy.uEncrypt(url.eId)#" addtoken = "no">
	</cfcase>

	<cfcase value="classroom.settings">
		<!---<cfset XFA.title = "Settings">--->
		<cfset application.current_module = "settings">
		<cfset application.udFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="classroom.notifications">
		<!---<cfset XFA.title = "Notification">--->
		<cfset request.current_module = "notification">
		<cfset application.udfLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="classroom.uploadimage">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "ClassRoom/actUploadImage.cfm">
	</cfcase>

	<cfcase value="classroom.uploadvideo">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "ClassRoom/actUploadVideo.cfm">
	</cfcase>

	<!--- BEGIN : RRK :: AMTA - Classroom - A price over-ride for a training event based on a period of time - BIS566Q - (Billable) --->
	<cfcase value="classroom.uploadlogo">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "ClassRoom/actUploadLogo.cfm">
	</cfcase>
	<!--- END : RRK :: AMTA - Classroom - A price over-ride for a training event based on a period of time - BIS566Q - (Billable) --->

	<cfcase value="classroom.uploadcertificate">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "ClassRoom/actUploadCertificate.cfm">
	</cfcase>

	<cfcase value="classroom.printparticipantlist">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="classroom/PrintParticipantList.cfm">
	</cfcase>

  <!--- BEGIN : RRK: BCMSA - Calendar - New PDF Report called Event Details (Billable)  --->
	<cfcase value="classroom.eventdetailsreport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="classroom/PrintEventDetails.cfm">
	</cfcase>
  <!--- END : RRK: BCMSA - Calendar - New PDF Report called Event Details (Billable)  --->

	<cfcase value="classroom.emailprintparticipantlist">
		<cfset request.current_module = "participantlist">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfinclude template="classroom/EmailParticipantList.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="classroom.sendEmailParticpantList">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="classroom/sendEmailParticpantList.cfm">
	</cfcase>

	<cfcase value="classroom.emailparticipants">
		<cfset request.current_module = "emailparticipants">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfinclude template="classroom/EmailParticipants.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="classroom.sendEmailParticpants">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="classroom/sendEmailParticpants.cfm">
	</cfcase>

	<cfcase value="classroom.printwaitlistusers">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="classroom/PrintWaitlistUsers.cfm">
	</cfcase>

	<cfcase value="classroom.emailwaitlistusers">
		<cfset request.current_module = "participantlist">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfinclude template="classroom/EmailWaitlistUsers.cfm">
		<cfinclude template="layout/BISFooter1.cfm">
	</cfcase>

	<cfcase value="classroom.sendEmailwaitlistusers">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="classroom/sendEmailwaitlistusers.cfm">
	</cfcase>

	<cfcase value="classroom.eventvoucher">
		<cfset application.udFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="classroom.deleteclassroomevent">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "classroom/actDeleteEvent.cfm">
	</cfcase>

	<cfcase value="classroom.deleteCourse">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "classroom/actDeleteCourse.cfm">
	</cfcase>

	<cfcase value="classroom.addWaitlistPublic">
		<cfinclude template = "classroom/actAddPublicUserToWaitlist.cfm">
	</cfcase>
	
	<cfcase value="classroom.uploadCourseDocuments">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "classroom/actUploadCourseDocuments.cfm">
	</cfcase>

	<cfcase value="classroom.confirmwithdrawlearnerpublic">
		<cflocation 
		url="#application.fwDummy.buildUrl(
		   action = "classroom.ConfirmWithdrawLearnerPublic",
		   path = application.sysBasePath,
		   queryString = "data=" & url?.data
		)#"
		addToken="no"
		statusCode="301">
	</cfcase>

	<cfcase value="classroom.cutoffadminconfirm">
		<cfinclude template = "classroom/actCutOffAdminConfirm.cfm">
	</cfcase>

	<cfcase value="classroom.cutoffadmincancel">
		<cfinclude template = "classroom/actCutOffAdminCancel.cfm">
	</cfcase>

	<cfcase value="classroom.ConfirmWithdrawInstructorPublic">
		<cfinclude template = "classroom/actConfirmWithdrawInstructorPublic.cfm">
	</cfcase>

	<cfcase value="classroom.ParticipantExamResults">
		<cfinclude template = "classroom/actParticipantExamResults.cfm">
	</cfcase>

	<!--- Begin : Email Classroom Vouchercode - 13-01-2016 --->
	<cfcase value="classroom.EmailClassroomVoucherCodes"><cfabort></cfcase>
	<!--- End : Email Classroom Vouchercode - 13-01-2016 --->

<!--- START: Add instructor from classroom instructor section, 20 APR 2016 --->
	<cfcase value="classroom.AddInstructor">
		<cfset session.classroomInstructorSelect = 1>
		<cfif isDefined("url.ClassroomNode") AND len(trim(url.ClassroomNode))>
			<cfset session.admincompanygroupid = url.ClassroomNode>
		</cfif>
		<cfif isDefined("url.nodeName") AND len(trim(url.nodeName))>
			<cfset session.adminGetNodeName = url.nodeName>
		</cfif>
		<cfif listfind(cadminrole,'superadmin') OR listfind(cadminrole,'bisadmin')>
			<cflocation url="index.cfm?action=bisadmin.AddManagerForm&classroomInstructor=1&node=#application.fwDummy.uEncrypt(session.admincompanygroupid)##session.xxautotoken#">
		<cfelse>
			<cfif isDefined("url.ClassroomNode") AND len(trim(url.ClassroomNode))>
				<cfset session.GetCompanyGroupID = url.ClassroomNode>
			</cfif>
			<cflocation url="index.cfm?action=manager.AddLearnerForm&classroomInstructor=1&nodes=#application.fwDummy.uEncrypt(session.GetCompanyGroupID)##session.xxautotoken#">
		</cfif>
	</cfcase>
	<!--- END: Add instructor from classroom instructor section, 20 APR 2016 --->

	<!--- BEGIN: Invoicing feature; May 3, 2016 --->
	<cfcase value="classroom.generateInvoice">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset variables.invoiceParameter = "">
		<cfif structKeyExists(url, "invoiceId")>
			<cfset url.invoiceId = left(url.invoiceId, 1) EQ "_" ? decrypt(listLast(url.invoiceId, "_"), application.uEncryptKey, "AES", "Hex") : url.invoiceId>
		</cfif>
		
		<cfif structKeyExists(url, "eid")>
			<cfset url.eid = left(url.eid, 1) EQ "_" ? decrypt(listLast(url.eid, "_"), application.uEncryptKey, "AES", "Hex") : url.eid>
		</cfif>
		<cfif structKeyExists(url, "locationId")>
			<cfset url.locationId = left(url.locationId, 1) EQ "_" ? decrypt(listLast(url.locationId, "_"), application.uEncryptKey, "AES", "Hex") : url.locationId>
		</cfif>
		<cfif structKeyExists(url, "VoucherCode")>
			<cfset url.VoucherCode = left(url.VoucherCode, 1) EQ "_" ? decrypt(listLast(url.VoucherCode, "_"), application.uEncryptKey, "AES", "Hex") : url.VoucherCode>
		</cfif>
		<cfif structKeyExists(url, "invoiceId")>
			<cfset variables.invoiceParameter = "&invoice=" & "_" & encrypt(url.invoiceId, application.uEncryptKey, "AES", "Hex")>
		<cfelse>
			<cfif structKeyExists(url, "eid")>
				<cfset variables.invoiceParameter = variables.invoiceParameter & "&event=" & "_" & encrypt(url.eid, application.uEncryptKey, "AES", "Hex")>
			</cfif>
			<cfif structKeyExists(url, "locationId")>
				<cfset variables.invoiceParameter = variables.invoiceParameter & "&location=" & "_" & encrypt(url.locationId, application.uEncryptKey, "AES", "Hex")>
			</cfif>
		</cfif>
		<cflocation url="v1/index.cfm?action=manager.generateinvoice#variables.invoiceParameter#" addtoken="false">
	</cfcase>
	<!--- END: Invoicing feature; May 3, 2016 --->

	<!--- BEGIN: Email Invoicing feature 05/10/2016 --->
	<cfcase value="classroom.InvoicingEmail">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfinclude template = "classroom/actClassRoomInvoicingEmail.cfm">
		<cfinclude template = "classroom/ClassRoomInvoicingEmail.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>
	<!--- END: Email Invoicing feature 05/10/2016--->

	<!--- BEGIN: Invoicing Summary report 05/17/2016 --->
	<cfcase value="classroom.InvoiceReports">
		<cfset variables.invoiceParameter = "">
		<cfif len(trim(url?.courseCode))>
			<cfset variables.invoiceParameter = "&courseCode=" & "#isNumeric(url.courseCode) ? application.fwDummy.uEncrypt(url.courseCode) : url.courseCode#">
		</cfif>
		<cfif len(trim(url?.invoiceId))>
			<cfset variables.invoiceParameter = variables.invoiceParameter & "&invoiceid=" & "#isNumeric(url.invoiceId) ? application.fwDummy.uEncrypt(url.invoiceId) : url.invoiceId#">
		</cfif>
		<cfif len(trim(url?.eventId))>
			<cfset variables.invoiceParameter = variables.invoiceParameter & "&eventId=" & "#isNumeric(url.eventId) ? application.fwDummy.uEncrypt(url.eventId) : url.eventId#">
		</cfif>
		<cfif len(trim(url?.companyId))>
			<cfset variables.invoiceParameter = variables.invoiceParameter & "&companyId=" & "#isNumeric(url.companyId) ? application.fwDummy.uEncrypt(url.companyId) : url.companyId#">
		</cfif>
		<cfif len(trim(url?.locationId))>
			<cfset variables.invoiceParameter = variables.invoiceParameter & "&locationId=" & "#isNumeric(url.locationId) ? application.fwDummy.uEncrypt(url.locationId) : url.locationId#">
		</cfif>
		<cflocation url="v1/index.cfm?action=classroom.invoicereports#variables.invoiceParameter#" addtoken="false">
	</cfcase>
	<!--- END: Invoicing Summary report 05/17/2016 --->

	<!--- BEGIN: Invoicing Payment Status 05/17/2016 --->
	<cfcase value="classroom.invoiceStatus">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfinclude template = "classroom/actClassRoomInvoiceStatus.cfm">
		<cfinclude template = "classroom/ClassRoomInvoiceStatus.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>
	<!--- END: Invoicing Payment Status 05/17/2016 --->

	<!--- BEGIN: Invoicing Payment Status 05/17/2016 --->
	<cfcase value="classroom.printInvoice">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset variables.invoiceParameter = "">
		<cfif structKeyExists(url, "invoiceId")>
			<cfset variables.invoiceId = left(url.invoiceId, 1) EQ "_"
				? application.fwDummy.uDecrypt(url.invoiceId)
				: url.invoiceId>
			<cfset variables.invoiceParameter = "&invoiceid=" & variables.invoiceId>
		</cfif>
		<cfif structKeyExists(url, "eventId")>
			<cfset variables.eventId = left(url.eventId, 1) EQ "_"
				? application.fwDummy.uDecrypt(url.eventId)
				: url.eventId>
			<cfset variables.invoiceParameter = variables.invoiceParameter & "&eventid=" & variables.eventId>
		</cfif>
		<cfif structKeyExists(url, "startDate")>
			<cfset variables.invoiceParameter = variables.invoiceParameter & "&startdate=" & url.startDate>
		</cfif>
		<cfif structKeyExists(url, "endDate")>
			<cfset variables.invoiceParameter = variables.invoiceParameter & "&enddate=" & url.endDate>
		</cfif>
		<cfif structKeyExists(url, "filteredBy")>
			<!--- <cfset url.filteredBy = isNumeric(url.filteredBy) ? url.filteredBy : application.fwDummy.uDecrypt(url.filteredBy)> --->
			<cfset variables.invoiceParameter = variables.invoiceParameter & "&filteredby=" & url.filteredBy>
		</cfif>
		<cfif structKeyExists(url, "companyId")>
			<!--- <cfset url.companyId = isNumeric(url.companyId) ? url.companyId : application.fwDummy.uDecrypt(url.companyId)> --->
			<cfset variables.invoiceParameter = variables.invoiceParameter & "&companyid=" & url.companyId>
		</cfif>
		<cfif structKeyExists(url, "locationId")>
			<!--- <cfset url.locationId = isNumeric(url.locationId) ? url.locationId : application.fwDummy.uDecrypt(url.locationId)> --->
			<cfset variables.invoiceParameter = variables.invoiceParameter & "&locationid=" & url.locationId>
		</cfif>
		<cflocation url="v1/index.cfm?action=manager.printclassroominvoices#variables.invoiceParameter#" addtoken="false">
	</cfcase>
	<!--- END: Invoicing Payment Status 05/17/2016 --->

	<cfcase value="classroom.TaxExcemptDocUpload">
		<cfinclude template = "secure/chk_secured.cfm">

		<cfinclude template = "classroom/TaxExcemptDocUpload.cfm">
	</cfcase>

	<!--- Inventory management; July 5, 2016 --->
	<cfcase value="classroom.inventory">
		<cfset request.current_module = 'inventory'>
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfinclude template = "classroom/actInventoryManagement.cfm">
		<cfinclude template = "classroom/inventoryManagement.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="classroom.inventoryRecieved">
		<cfinclude template = "public/inventoryRecieved.cfm">
	</cfcase>

	<cfcase value="classroom.PrintAllCertificates">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "classroom/PrintAllCertificates.cfm">
	</cfcase>

	<!--- BEGIN: AMHSA - Classroom - Add an excel report for the detail on the inventory BIS15595 (Billable) 3/20/2017 TV019 --->
	<cfcase value="classroom.DownloadInventoryReport">
	    <cfinclude template = "classroom/DownloadInventoryReport.cfm">
	</cfcase>
	<!--- END: AMHSA - Classroom - Add an excel report for the detail on the inventory BIS15595 (Billable) 3/20/2017 TV019 --->

	<cfcase value="classroom.printparticipantpasswordreset">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "classroom/printparticipantpasswordreset.cfm">
	</cfcase>

	<cfcase value="classroom.printallidbadges">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "classroom/printallidbadges.cfm">
	</cfcase>

	<cfcase value="classroom.getCourseDocuments">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "classroom/getcoursedocuments.cfm">
	</cfcase>

	<cfcase value="classroom.downloadEventDocuments">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "classroom/downloadEventDocuments.cfm">
	</cfcase>

	<cfdefaultcase>
		<cfset variables.ActionEventNotFound = variables.ActionEventNotFound + 1>
	</cfdefaultcase>

</cfswitch>