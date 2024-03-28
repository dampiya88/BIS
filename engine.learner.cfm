<cfparam name="attributes.action" default="">
<cfparam name="variables.ActionEventNotFound" default="0">
<cfoutput>
	<cfswitch expression = "#attributes.action#">
		<!--- ******* LEARNER HOME / DASHBOARD ******* --->
		<cfcase value="learner.home">
			<cfset request.UdFLib.redirectNewSite(always=true)>
		</cfcase>
		<cfcase value="learner.newhome">
			<cfset request.UdFLib.redirectNewSite(always=true)>
		</cfcase>
		<!--- ******* Edit Learner Profile ******* --->
		<cfcase value="learner.EditProfile">
			<cfset request.UdFLib.redirectNewSite(always=true)>
		</cfcase>
		<!--- ******* Invitation Profile ******* --->
		<cfcase value="learner.Invitation">
			<cfset XFA.MenuBarSelected = "AboutUs">
			<cfset XFA.bannerFile = "images/banner_about.jpg">
			<cfif structKeyExists(url, "form.fldInvitationCode")>
				<cfset form.fldInvitationCode= application.fwDummy.uDecrypt(form.fldInvitationCode)>
			</cfif>
			<cfinclude template = "public/qryGetALanguageName.cfm">
			<cfset form.action = "#action#">
			<cfinclude template="usr/qryUserInvitationStatus.cfm">
			<cfset form.action = "#action#">
			<cfinclude template="usr/qryUserInvitationStatus.cfm">
			<cfif isDefined("qryUserInvitationStatus.recordcount") AND
				qryUserInvitationStatus.fldValid EQ 1
				AND
				(
					qryUserInvitationStatus.fldInvitationType EQ 1
					OR
					(
						qryUserInvitationStatus.fldInvitationType EQ 2
						AND
						(
							(qryUserInvitationStatus.fldUnlimitedInvites EQ 0 AND qryUserInvitationStatus.fldUsedInvites LT qryUserInvitationStatus.fldMaxInvites)
							OR
							qryUserInvitationStatus.fldUnlimitedInvites EQ 1
						)
					)
				)
			>
				<!--- BEGIN: Custom URL redirection for Invitation Login --->
				<cfif val(qryUserInvitationStatus.fldCustomURLSetupComplete) AND len(trim(qryUserInvitationStatus.fldCustomUrl))>
					<cfset variables.CustomUserCompanyURL = trim(qryUserInvitationStatus.fldCustomUrl)>
				<cfelse>
					<cfset variables.CustomUserCompanyURL = application.bissiteurl>
				</cfif>
				<cfif len(trim(variables.CustomUserCompanyURL)) AND NOT Find(cgi.http_host, trim(variables.CustomUserCompanyURL))>
					<cfinclude template="public/InvitationCustomURLSwitch.cfm">
				</cfif>
				<!--- END: Custom URL redirection for Invitation Login --->
				<cfif NOT val(qryUserInvitationStatus.fldLanguagePref)>
					<cfset getlanguage = request.ManageCompany.getLanguageFromCompanySettings(companyId = qryUserInvitationStatus.fldUserCompany_ID)>
					<cfset session['LanguageName'] = getlanguage.languagename>
					<cfset session['Language'] = getlanguage.languageid>
				</cfif>
				<!--- Check and redirect to responsive site --->
				<cfset request.UdFLib.redirectNewSite(qryUserCompany.company, structKeyExists(form, 'fldInvitationCode') AND NOT structKeyExists(url, 'form.fldInvitationCode') ? 'fldInvitationCode=' & application.fwDummy.uEncrypt(form.fldInvitationCode) : '')>
				<cfabort>
			<cfelse>
				<cflocation url="/v1/index.cfm?action=home.loginForm&reason=3&Language=#Language#">
			</cfif>
		</cfcase>
		<!--- ******* Voucher Code Profile ******* --->
		<cfcase value="learner.VoucherInvitation">
			<cfset application.MailService.customErrorEmailHandler(subject = "Debug - learner.VoucherInvitation", toAddresses = 'rejith@bistraining.ca', session = session, url = url, form = form, cgi = cgi, httpRequestContent = request.httpRequestContent)>
			<cfset XFA.MenuBarSelected = "AboutUs">
			<cfset XFA.bannerFile = "images/banner_about.jpg">
			<cfinclude template = "public/qryGetALanguageName.cfm">
			<cfinclude template="layout/BISHeaderBlank.cfm">
			<cfinclude template="layout/BISFooter1.cfm">
		</cfcase>
		<!--- ******* Update Learner Profile ******* --->
		<cfcase value="learner.UpdateProfile">
			<cfparam name="form.csrftoken" default="">
			<cfif NOT CSRFVerifyToken(form.csrftoken)>
				<cflocation url = "#application.sysBasePath#?action=public.noaccess">
			</cfif>
			<cfif structKeyExists(session, 'LID')>
				<cfinclude template = "secure/chk_secured.cfm">
				<cfinclude template = "learner/UpdateProfile/actSetUserLanguage.cfm">
			</cfif>
			<cfinclude template="layout/BISHeaderPrivate.cfm">
			<cfif structKeyExists(form, 'Language')>
				<cfinclude template = "learner/UpdateProfile/actCheckUserLanguageChange.cfm">
				<cfset noduplicateemail = 0>
				<cfif structKeyExists(form, 'Email1')>
					<cfinclude template = "manager/newManageLearners/dspDuplicateEmailAddress.cfm">
				</cfif>
				<cfset noDuplicateEmployeeID = 0>
				<cfif isDefined("noduplicateemail") AND noduplicateemail EQ 0 AND structKeyExists(form, 'IDNumber') AND len(trim(form.IDNumber))>
					<cfset noDuplicateEmployeeID = request.UserManager.ChkDuplicateEmployeeID(EmployeeID = trim(form.IDNumber), CompanyID = session.loginusercompanyid, UserID = session.loginUSERID)>
					<cfif noDuplicateEmployeeID NEQ 0>
						<cfinclude template = "learner/dspDuplicateEmployeeIdMsg.cfm">
					</cfif>
				</cfif>
				<cfif isDefined("noduplicateemail") AND noduplicateemail EQ 0 AND noDuplicateEmployeeID EQ 0>
					<cfset nameNotRequired = 1>
					<cfinclude template = "manager/newManageLearners/dspValidateFormFields.cfm">
					<cfif resultOk EQ 1>
						<cfinclude template = "learner/qryUpdateAccount.cfm">
						<cflocation url="/v1/index.cfm?action=learner.editProfile&update=1">
					</cfif>
				</cfif>
			<cfelse>
				<b>
					Wrong form data. Press button back.
				</b>
			</cfif>
			<cfinclude template="layout/BISFooterLogged.cfm">
		</cfcase>

		<cfcase value="learner.updateGhostProfile">
			<cfparam name="form.csrftoken" default="">
			<cfif NOT CSRFVerifyToken(form.csrftoken)>
				<cflocation url = "#application.sysBasePath#?action=public.noaccess">
			</cfif>
			<cfinclude template = "secure/chk_secured.cfm">
			<cfif structKeyExists(session, 'LID')>
				<cfinclude template = "learner/UpdateProfile/actSetUserLanguage.cfm">
			</cfif>
			<cfinclude template="layout/BISHeaderPrivate.cfm">
			<cfinclude template = "learner/qryUpdateGhostAccount.cfm">
			<cfinclude template="layout/BISFooterLogged.cfm">
		</cfcase>

		<!--- ******* LEARNER START A COURSE ******* --->
		<cfcase value="learner.startCourse">
			<cfset request.UdFLib.redirectNewSite(always=true)>
		</cfcase>
		<!--- ******* do a Course ******* --->
		<cfcase value="learner.doCourse">
			<cfset request.UdFLib.redirectNewSite(always=true)>
		</cfcase>
		<!--- ******* Submit an Answer ******* --->

		<cfcase value="learner.SubmitAnswer">
			<cfinclude template = "secure/chk_secured.cfm">
			<cfset XFA.MenuBarSelected = "AboutUs">
			<cfset XFA.bannerFile = "images/banner_about.jpg">
			<cfinclude template="layout/BISHeaderPrivate.cfm">
			<cfinclude template="layout/BISFooterLogged.cfm">
		</cfcase>
		<!--- ******* Feedback Questions ******* --->
		<cfcase value="learner.FeedbackQuestions">
			<cfinclude template = "secure/chk_secured.cfm">
			<cfset XFA.MenuBarSelected = "AboutUs">
			<cfset XFA.bannerFile = "images/banner_about.jpg">
			<cfinclude template="layout/BISHeaderPrivate.cfm">
			<cfset form.action = "#action#">
			<cfif session.PlayHead.GetCurrentCourseElement() GTE 0>
				<cfset hid = session.playhead.getID() />
				<cfset cid = session.playhead.getCourse().id />
				<cfset aid = session.playhead.getTag() />
				<cfset mcid = '' />
				<cfset mcgid = '' />
				<cflocation url="index.cfm?action=learner.doCourse&cid=#cid#&hid=#hid#&mcid=#mcid#&mcgid=#mcgid#&aid=#aid##session.xxautotoken#">
			</cfif>
			<cfset session.TimeTakenForFeedbackQuestion="#NOW()#">
			<cfset courseObj = request.CourseManager.GetCourseByID(val(session.loginCurrentCourse)) />
			<cfset coursescore = request.courses.Calculatescore(courseid=session.logincurrentcourse,historyid=session.playhead.getID())>
			<cfset netscore = coursescore>
			<cfset session.FinalScore = netscore>
			<cfset cursor = session.PlayHead.GetCursor() />
			<cfif courseObj.getRequestFeedback() AND NOT (listFind(session.loginuserroleid, 45) OR listFind(session.loginuserroleid, 53) OR listFind(session.loginuserroleid, 7))>
				<cfset request.UdFLib.redirectNewSite()>
			<cfelse>
				<cflocation url="index.cfm?action=learner.SubmitFeedbackAnswer&noThanks=1#session.xxautotoken#">
			</cfif>
		</cfcase>
		<!--- ******* Feedback Question's Answer Submission ******* --->
		<cfcase value="learner.SubmitFeedbackAnswer">
			<cfinclude template = "secure/chk_secured.cfm">
			<cfset XFA.MenuBarSelected = "AboutUs">
			<cfset XFA.bannerFile = "images/banner_about.jpg">
			<cfinclude template="layout/BISHeaderPrivate.cfm">
			<cfset form.action = "#action#">
			<cfif IsDefined("UseNewBISPlayer") AND UseNewBISPlayer>
				<cfset playhead = session.PlayHead />
			<cfelse>
				<cfset playhead = request.PlayHeadManager.GetPlayHeadByID(session.CourseHistoryID) />
			</cfif>
			<cftry>
				<cfif NOT isNumeric(session.FinalScore)>
					<cfset session.FinalScore = request.courses.Calculatescore(
						courseid = session.playhead.getCourse().id,
						historyid = session.playhead.getID())>
				</cfif>
				<cfset playhead.SetCourseComplete(session.FinalScore) />
				<cfcatch type="InvalidState">
					<cfset hid = playhead.getID() />
					<cfset cid = playhead.getCourse().getID() />
					<cfset aid = playhead.getTag() />
					<cflocation url="index.cfm?action=learner.doCourse&cid=#cid#&hid=#hid#&aid=#aid##session.xxautotoken#">
				</cfcatch>
			</cftry>
			<cfif StructKeyExists(form, "noThanks") >
				<cfset noThanks = form.noThanks />
			<cfelseif StructKeyExists(url, "noThanks") >
				<cfset noThanks = url.noThanks />
			<cfelse>
				<cfset noThanks = 0 />
			</cfif>
			<cfif noThanks EQ 0>
				<cfset ratingArray = []>
				<cfquery name="getRatings" datasource="#application.dsn#">
					SELECT
						fldRatingType_ID,
						fldRatingTypeName
					FROM
						tblratingtype
					WHERE
						fldActive = 1
				</cfquery>
				<cfloop query="getRatings">
					<cfset starRating = {}>
					<cfset starRating['ID'] = getRatings.fldRatingType_ID>
					<cfset starRating['rating'] = form[getRatings.fldRatingTypeName]>
					<cfset ArrayAppend(ratingArray, starRating)>
				</cfloop>
				<cfinclude template = "learner/qrySubmitFeedbackAnswer.cfm">
			<cfelse>
				<!---
					Ensure these are blank, as the mail code checks them as a
					heuristic to see if feedback was skipped.  Fugly?  Yes.  But
					I'm lazy and it's easier than passing the damn noThanks flag
					through...
					--->
				<cfset form.FeedbackAnswer1 = "" />
				<cfset form.FeedbackAnswer2 = "" />
			</cfif>
			<cfinclude template = "learner/actEmailFeedbackQuestions.cfm">
			<cflocation url = "#application.sysBasePath#?action=learner.coursecomplete&historyid=#application.fwDummy.uEncrypt(session.courseHistoryId)#"
				addToken = "no">
			<cfinclude template="layout/BISFooterLogged.cfm">
		</cfcase>
		<cfcase value="learner.Coursetimeup">
			<cfinclude template = "secure/chk_secured.cfm">
			<cfset form.action = "#action#">
			<cfset courseObj = request.CourseManager.GetCourseByID(session.loginCurrentCourse) />
			<cfset coursescore = request.courses.Calculatescore(courseid=session.logincurrentcourse,historyid=url.hid)>
			<cfset netscore = coursescore>
			<cfset session.FinalScore = netscore >
			<cfif IsDefined("UseNewBISPlayer") AND UseNewBISPlayer>
				<cfset playhead = session.PlayHead />
			<cfelse>
				<cfset playhead = request.PlayHeadManager.GetPlayHeadByID(session.CourseHistoryID) />
			</cfif>
			<cftry>
				<cfset playhead.SetCourseComplete(Score=session.FinalScore,forceToComplete = 1) />
				<cfcatch type="InvalidState">
					<cfset hid = playhead.getID() />
					<cfset cid = playhead.getCourse().getID() />
					<cfset aid = playhead.getTag() />
					<cflocation url="index.cfm?action=learner.doCourse&cid=#cid#&hid=#hid#&aid=#aid##session.xxautotoken#">
				</cfcatch>
			</cftry>
			<cfset session.coursetimeup = "The time allowed for this course has run out. We will submit your final results to the system.">
			<!--- BEGIN:ABSA - LMS - Notes for Timer triggers (Non-Billable)  -TV0026 --->
			<cfset timeupnotes =  "Intermittent timer ran out after #courseObj.getCourseTimer()# and moved #courseObj.getTitle()# to #timeformat(now(),'hh:mm tt')# on #dateformat(now(),'medium')#">
			<cfset user = session.PlayHead.getUser() />
			<cfset result = request.UserManager.saveUserNotes(User.id, timeupnotes) />
			<!--- END:ABSA - LMS - Notes for Timer triggers (Non-Billable)  -TV0026 --->
			<cflocation url = "#application.sysBasePath#?action=learner.coursecomplete&historyid=#application.fwDummy.uEncrypt(session.courseHistoryId)#"
				addToken = "no">
			<cfinclude template="layout/BISFooterLogged.cfm">
		</cfcase>
		<cfcase value="learner.CourseAccesstimeup">
			<cfset form.action = "#action#">
			<cfset ManageCoursePermissions = createObject("component", "#application.ComponentPath#.ManageCoursePermissions").init() />
			<cfset GetCourseHistoryID=ManageCoursePermissions.getUserCourseHistory(courseHistoryID=url.hid)>
			<cfset GetCoursePermissionDetails=ManageCoursePermissions.GetCoursePermissionsDetails(dbDatasource,"tblsyscoursepermission",GetCourseHistoryID.fldSysCoursePermissionID) >
			<cfset courseObj = request.CourseManager.GetCourseByID(GetCoursePermissionDetails.fldsyscourseid) />
			<cfset GetCourseHistoryStatus= GetCourseHistoryID.fldstatus>
			<cfif GetCourseHistoryStatus neq 'completed'>
				<cfset session.CourseHistoryID = GetCourseHistoryID.FLDUSERCOURSEHISTORY_ID>
				<cfset session.loginCurrentCourse = GetCoursePermissionDetails.FLDSYSCOURSEID>
				<cfif GetCourseHistoryID.recordcount>
					<cfset coursescore = request.courses.Calculatescore(courseid=session.logincurrentcourse,historyid=url.hid)>
					<cfset netscore = coursescore>
					<cfset session.FinalScore = netscore >
				<cfelse>
					<cfset session.FinalScore = 0 >
					<cfset GetHistory=ManageCoursePermissions.insertUserCourseHistory(coursepermission=GetCoursePermissionDetails)>
					<cfset GetCourseHistoryID=ManageCoursePermissions.getUserCourseHistory(courseHistoryID=GetHistory)>
					<cfset session.CourseHistoryID = GetCourseHistoryID.FLDUSERCOURSEHISTORY_ID>
				</cfif>
				<cfif IsDefined("UseNewBISPlayer") AND UseNewBISPlayer>
					<cflock timeout="30" type="exclusive">
						<cfset session.PlayHead = request.PlayHeadManager.GetPlayHeadByID(session.CourseHistoryID) />
					</cflock>
					<cfset playhead = session.PlayHead />
				<cfelse>
					<cfset playhead = request.PlayHeadManager.GetPlayHeadByID(session.CourseHistoryID) />
				</cfif>
				<cftry>
					<cfset playhead.SetCourseComplete(Score=session.FinalScore,forceToComplete = 1) />
					<cfcatch type="InvalidState">
						<cfset hid = playhead.getID() />
						<cfset cid = playhead.getCourse().getID() />
						<cfset aid = playhead.getTag() />
						<cflocation url="index.cfm?action=learner.doCourse&cid=#cid#&hid=#hid#&aid=#aid##session.xxautotoken#">
					</cfcatch>
				</cftry>
				<cfset timeupnotes =  "Continuous timer ran out after #courseObj.getCourseAccessTimer()# and moved #courseObj.getTitle()# to #timeformat(now(),'hh:mm tt')# on #dateformat(now(),'medium')#">
				<cfset user = session.PlayHead.getUser() />
				<cfset result = request.UserManager.saveUserNotes(User.id, timeupnotes) />
			</cfif>
			<cfschedule action="delete" task="permission#GetCourseHistoryID.fldSysCoursePermissionID#">
			<!--- END: URGENT - ABSA - Accessing Course Causes A Logout Error - (Non Billable) - BIS-3424 4/6/2017 TV0119 --->
			<cfset session.coursetimeup = "The time allowed for this course has run out. We will submit your final results to the system.">
			<cflocation url = "#application.sysBasePath#?action=learner.coursecomplete&historyid=#application.fwDummy.uEncrypt(url.hid)#"
				addToken = "no">
			<cfinclude template="layout/BISFooterLogged.cfm">
		</cfcase>
		<!--- ******* COURSE COMPLETE ******* --->
		<cfcase value="learner.CourseComplete">
			<cfset application.udfLib.redirectNewSite()>
		</cfcase>
		<!--- ******* Learner HELP******* --->
		<cfcase value="learner.Help">
			<!--- Check and redirect to responsive site --->
			<cfset request.UdFLib.redirectNewSite(always=true)>
		</cfcase>
		<!--- ******* Learner COURSE COMPLETION CERTIFICATE******* --->
		<cfcase value="learner.CourseCertificate">
			<cfif NOT isDefined("URL.frommail")>
				<cfinclude template = "secure/chk_secured.cfm">
			</cfif>
			<!--- <cfset XFA.MenuBarSelected = "AboutUs">
			<cfset XFA.bannerFile = "images/banner_about.jpg">
			<cfinclude template="layout/BISHeaderPrivate.cfm"> --->
			<cfset form.action = "#action#">
			<cfinclude template = "manager/dspDecriptURLVariables.cfm">
			<cfinclude template = "learner/newHome/dspCourseCertificate.cfm">
			<!--- <cfinclude template="layout/BISFooterLogged.cfm"> --->
		</cfcase>

		<cfcase value="learner.purchases">
			<cfset request.UdFLib.redirectNewSite(always=true)>
		</cfcase>

		<cfcase value="learner.StartAssessmentForm">
			<!--- <cfinclude template = "secure/chk_secured.cfm"> --->
			<cflocation url = "#application.sysBasePath#?action=public.noaccess&deprecated=1">
		</cfcase>
		<cfcase value="learner.AssessmentForm">
			<cflocation url = "#application.sysBasePath#?action=public.noaccess&deprecated=1">
		</cfcase>
		<cfcase value="learner.DownloadAssessmentForm">
			<cfinclude template="learner/DownloadCompletedAssessment.cfm">
		</cfcase>
		<cfcase value="learner.SendCustomClassroomEmail">
			<!--- <cfinclude template="layout/BISHeaderPrivate.cfm"> --->
			<cfinclude template="learner/dspSendCustomClassroomEmail.cfm">
		</cfcase>
		<cfcase value="learner.SwitchAccount">
			<cfinclude template="secure/chk_secured.cfm">
			<cfif structKeyExists(session, 'loginUserTemporaryPassword') AND session.loginUserTemporaryPassword EQ 1>
				<cflocation url="index.cfm?action=Manager.SetNewPassword#session.xxautotoken#">
			</cfif>
			<cfinclude template="learner/dspSwitchAccount.cfm">
		</cfcase>
		<cfcase value="learner.VerifyGhostByEmail">
			<cfinclude template="learner/dspVerifyGhostByEmail.cfm">
		</cfcase>
		<cfcase value="learner.VerifyGhostFromEmail">
			<cfinclude template="learner/actVerifyGhostFromEmail.cfm">
		</cfcase>
		<cfcase value="learner.GetLoginDetails">
			<cfinclude template="learner/actGetLoginDetails.cfm">
		</cfcase>
		<!--- BEGIN: SSO course redirect--->
		<cfcase value="learner.SSOCourseRedirect">
			<cfinclude template="learner/actSSOCourseRedirect.cfm">
		</cfcase>
		<!--- END: SSO course redirect--->
		<!--- BEGIN: BIS - Form Builder - Remaining Fountain Tire Form Builder Revisions (non-billable) 2/3/2017 T0000V  --->
		<cfcase value="learner.uploadimage">
			<cfinclude template = "learner/AssessmentFormUploadImage.cfm">
		</cfcase>
		<!--- END: BIS - Form Builder - Remaining Fountain Tire Form Builder Revisions (non-billable) 2/3/2017 T0000V --->
		<cfcase value="learner.deactivateaccount">
			<cfinclude template = "learner/DeactivateAccount.cfm">
		</cfcase>
		<!--- End : URGENT - BIS - LMS - Unlimited retakes functionality not working for master packages - (Non Billable) --->
		<cfcase value="learner.alreadyExist">
			<cfinclude template="common/alreadyExist.cfm">
		</cfcase>
		<cfcase value="learner.viewasset">
			<!--- Check and redirect to responsive site --->
			<cfset request.UdFLib.redirectNewSite(always=true)>
		</cfcase>
		<cfdefaultcase>
			<cfset variables.ActionEventNotFound = variables.ActionEventNotFound + 1>
		</cfdefaultcase>
	</cfswitch>
</cfoutput>
