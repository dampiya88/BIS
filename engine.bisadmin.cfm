<cfparam name="attributes.action" default="">
<cfparam name="variables.ActionEventNotFound" default="0">
<cfswitch expression = "#attributes.action#">

	<!--- ******* BIS ADMINISTRATOR HOME / DASHBOARD ******* --->
	<cfcase value="bisadmin.Home">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- ******* BIS ADMINISTRATOR HOME / DASHBOARD ******* --->
	<cfcase value="bisadmin.SubTabs">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- ******* ADMINISTRATOR Company List Display / DASHBOARD ******* --->
	<cfcase value="bisadmin.companyHome">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!---************ ADMINISTRATOR comapnies NewMonthEndReports display************************ --->
	<cfcase value="bisadmin.newmonthendreport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfif NOT(listfindnocase(request.cadminrole,'bisadmin') OR listfindnocase(request.cadminrole,'superadmin'))><cfabort></cfif>
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/dspNewMonthEndReports.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.billableuserreport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfif NOT(listfindnocase(request.cadminrole,'bisadmin') OR listfindnocase(request.cadminrole,'superadmin') OR listFindNoCase(request.cadminrole,'clientsenioradmin') OR listFindNoCase(request.cadminrole,'clientadmin') OR listFindNoCase(request.cadminrole,'courseadmin'))><cfabort></cfif>
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "bisadmin/dspNewBillableUserReports.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!---************ ADMINISTRATOR comapnies Purchase MonthEndReports display************************ --->
	<cfcase value="bisadmin.purchasemonthendreport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfif NOT(listfindnocase(request.cadminrole,'bisadmin') OR listfindnocase(request.cadminrole,'superadmin'))><cfabort></cfif>
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<!--- BEGIN : RRK :: BIS - eCommerce Report Copy (nonbillable) --->
		<cfset variables.rootPath = "#application.appAssetPath#/PurchaseMonthEndReports/">
		<cfset variables.urlPath = "/Assets/PurchaseMonthEndReports/">
		<!--- END : RRK :: BIS - eCommerce Report Copy (nonbillable) --->
		<cfinclude template = "bisadmin/dspPurchaseMonthEndReports.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.esafetyreport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfif NOT listfindnocase(request.cadminrole,'clientsenioradmin')><cfabort></cfif>
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/dspeSafetyReport.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!---************ ADMINISTRATOR comapnies eCommerce Report display************************ --->
	<cfcase value="bisadmin.montheCommerceReport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfif NOT(listfindnocase(request.cadminrole,'bisadmin') OR listfindnocase(request.cadminrole,'superadmin'))><cfabort></cfif>
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/dspMonthEndEcommerceReports.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR Course home / DASHBOARD ******* --->
	<cfcase value="bisadmin.courseHome">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- ******* ADMINISTRATOR ADD COURSE/ DASHBOARD ******* --->
	<cfcase value="bisadmin.addCourse">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- ******* ADMINISTRATOR MANAGE COURSE BY LOCATION PERMISSIONS/ DASHBOARD ******* --->
	<cfcase value="bisadmin.ManageCoursePermissions">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- ******* ADMINISTRATOR EDIT COURSE/ DASHBOARD ******* --->
	<cfcase value="bisadmin.editCourse">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfparam name="url.course" default="#session.adminCourseID#">
		<cfif len(url.course) EQ 16>
			<cfset session.adminCourseID = Decrypt(url.course, 'password', 'BLOWFISH', 'Hex')>
		<cfelse>
			<cfset session.adminCourseID = url.course>
		</cfif>
		<cfquery name="local.qryGetCourseType" datasource="#application.dsn#">
			SELECT
				fldCourseTypesID
			FROM
				tblSysCourse
			WHERE
				fldSysCourse_ID = <cfqueryparam value="#session.adminCourseID#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfif local.qryGetCourseType.fldCourseTypesID NEQ 2>
			<cfset request.UdFLib.redirectNewSite()>
		</cfif>
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "learner/UpdateProfile/qryGetSysLanguages.cfm">
		<cfinclude template = "bisadmin/ManagerCourses/qryGetBannerUrlTypes.cfm">
		<cfinclude template = "bisadmin/ManagerCourses/dspEditCourse.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR EDIT COURSE/ DASHBOARD ******* --->
	<cfcase value="bisadmin.CourseEdited">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfquery name="local.qryGetCourseType" datasource="#application.dsn#">
			SELECT
				fldCourseTypesID
			FROM
				tblSysCourse
			WHERE
				fldSysCourse_ID = <cfqueryparam value="#val(session?.adminCourseID)#" cfsqltype="integer">
		</cfquery>
		<cfif local.qryGetCourseType.fldCourseTypesID NEQ 2>
			<cfabort>
		</cfif>
		<cfinclude template = "bisadmin/ManagerCourses/qryEditCourse.cfm">
		<cfif Structkeyexists(form, 'update1') AND Resultcourses NEQ 'true'>
			<cflocation url="index.cfm?action=bisadmin.EditCourse&course=#session.adminCourseID##session.xxautotoken#" addtoken="false">
		</cfif>
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR COURSE DETAILS/ DASHBOARD ******* --->
	<cfcase value="bisadmin.CourseDetails">
		<cfset application.udfLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- ******* ADMINISTRATOR REORDER COURSE CONTENTS/ DASHBOARD ******* --->
	<cfcase value="bisadmin.ReorderContents">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- ******* ADMINISTRATOR COURSE CONTENTS REORDERING/ DASHBOARD ******* --->
	<cfcase value="bisadmin.ContentsReordering">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "bisadmin/ManagerCourses/qryReorderedContents.cfm">
		<cflocation url="/v1/index.cfm?action=bisadmin.ReorderContents&courseId=#form.courseId#">
	</cfcase>

	<!--- ******* ADMINISTRATOR Question Contents/ DASHBOARD ******* --->
	<cfcase value="bisadmin.QuestionContents">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset setfocus = "YES">
 		<cfset bodyloadcmd = "setfocus();">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManagerCourses/dspDisplayQuestionContent.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR Chapter Contents/ DASHBOARD ******* --->
	<cfcase value="bisadmin.ChapterContents">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "BISadmin/ManagerCourses/dspDisplayChapterContents.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.ImageContents">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
	    <cfinclude template = "bisadmin/ManagerCourses/dspDisplayImageContents.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR EDIT Question/ DASHBOARD ******* --->
	<cfcase value="bisadmin.editQuestion">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
      	<cfinclude template = "bisadmin/ManagerCourses/qryEditAQuestion.cfm">
        <cfset args = ArrayNew(1) />
        <cfset ArrayAppend(args, "questionno=#form.questionno#") />
        <cfif IsDefined('form.pid')>
            <cfset ArrayAppend(args, "pid=#form.pid#") />
        </cfif>
        <cfif IsDefined('form.coursecontentno')>
            <cfset ArrayAppend(args, "coursecontentno=#form.coursecontentno#") />
        </cfif>
       <cfif StructKeyExists(url, 'id')>
			<cflocation url="index.cfm?action=bisadmin.QuestionContents&id=#url.id#&#ArrayToList(args, "&")##session.xxautotoken#">
		<cfelse>
			<cflocation url="index.cfm?action=bisadmin.QuestionContents&#ArrayToList(args, "&")##session.xxautotoken#">
		</cfif>
	</cfcase>

	<!--- ******* ADMINISTRATOR EDIT Chapter/ DASHBOARD ******* --->
	<cfcase value="bisadmin.editChapter">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
      	<cfinclude template = "BISadmin/ManagerCourses/qryEditAChapter.cfm">
        <cfif session.admincourseid AND NOT Structkeyexists(url,'id')>
        	<cflocation url="index.cfm?action=bisadmin.CourseDetails&course=#session.adminCourseID##session.xxautotoken#">
		<cfelse>
			<cflocation url="index.cfm?action=bisadmin.ContentLibraryDetails&id=#url.id##session.xxautotoken#">
		</cfif>
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.editImage">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
      	<cfinclude template = "BISadmin/ManagerCourses/qryEditImage.cfm">
        <cfif structkeyexists(url,'id')>
			<cflocation url="index.cfm?action=bisadmin.ContentLibraryDetails&id=#url.id##session.xxautotoken#">
		<cfelse>
			<cflocation url="index.cfm?action=bisadmin.CourseDetails&course=#session.adminCourseID##session.xxautotoken#">
		</cfif>
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- *******Upload Questions and Answers from Excel Sheet to Question pool ******* --->
	<cfcase value="bisadmin.UploadQuestionPoolQuestions">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<!--- code for editing a question--->
      	<cfinclude template = "bisadmin/ManagerCourses/dspQuestionpoolUploadQuestions.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>
	
	<!--- *******Download Questions and Answers to Excel Sheet  ******* --->
	<cfcase value="bisadmin.DownloadQuestionsexcel">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<!--- code for editing a question--->
      	<cfinclude template = "bisadmin/ManagerCourses/dspQuestionexceldownload.cfm">
	</cfcase>

	<!--- *******Download Questions and Answers in PDF  ******* --->
	<cfcase value="bisadmin.DownloadQuestionsPDF">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "bisadmin/ManagerCourses/dspQuestionPDFdownload.cfm">
	</cfcase>

	<!--- *******Download  Excel Template  ******* --->
	<cfcase value="bisadmin.DownloadExceltemplate">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<!--- code for downloading excel template--->
      	<cfinclude template = "bisadmin/ManagerCourses/dspDownloadExceltemplate.cfm">
	</cfcase>
	
	<!--- BEGIN: BIS-4034- Adding "Download Questions" button to course pools - Same functionality as Playlist -TV0193--->
	<!--- *******Download  Excel Template For Question pool ******* --->
	<cfcase value="bisadmin.DownloadExceltemplateForQuestionPools">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<!--- code for downloading excel template--->
      	<cfinclude template = "bisadmin/ManagerCourses/dspDownloadExceltemplateForQuestionPools.cfm">
	</cfcase>
	<!--- END: BIS-4034- Adding "Download Questions" button to course pools - Same functionality as Playlist -TV0193--->
	
	<!--- ******* ADMINISTRATOR REORDER A Question Answers/ DASHBOARD ******* --->
	<cfcase value="bisadmin.ReorderAnswers">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManagerCourses/qryGetContentOfQuestion.cfm">
		<cfinclude template = "bisadmin/ManagerCourses/qryGetAnswersOfAQuestion.cfm">
		<cfinclude template = "bisadmin/ManagerCourses/dspDisplayAnswersForReordering.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR EMBED AN ASSET IN A QUESTION ******* --->
	<cfcase value="bisadmin.ModifyAssetEmbedding">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfset form.action = "#action#">
		<cfscript>
			asset = request.AssetManager.GetAssetByID(url.aid);
			if (StructKeyExists(url, 'coursecontentno')) {
				if (StructKeyExists(url, 'clear')) {
					asset.RemoveLocation(ContentID: url.coursecontentno);
				} else {
					asset.AddLocation(ContentID: url.coursecontentno);
				}
			} else {
				if (StructKeyExists(url, 'clear')) {
					asset.RemoveLocation(QuestionID: url.questionno);
				} else {
					asset.AddLocation(QuestionID: url.questionno);
				}
			}
		</cfscript>
		<cfset args = ArrayNew(1) />
		<cfif StructKeyExists(url, "questionno")>
			<cfset ArrayAppend(args, "questionno=#url.questionno#") />
		</cfif>
		<cfif StructKeyExists(url, "pid")>
			<cfset ArrayAppend(args, "pid=#url.pid#") />
		</cfif>
		<cfif StructKeyExists(url, "coursecontentno")>
			<cfif StructKeyExists(url, "course")>
				<cfset ArrayAppend(args, "course=#url.course#") />
			</cfif>
			<cfset ArrayAppend(args, "coursecontentno=#url.coursecontentno#") />
		</cfif>
		<cflocation url="index.cfm?action=bisadmin.#url.return#&#ArrayToList(args, "&")#">
	</cfcase>

	<!--- ******* ADMINISTRATOR QUESTION ANSWERS REORDERED/ DASHBOARD ******* --->
	<cfcase value="bisadmin.AnswersReordering">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManagerCourses/qryReorderedAnswers.cfm">
		<cfinclude template = "bisadmin/ManagerCourses/dspReorderedAnswers.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR Deactivate a course/ DASHBOARD ******* --->
	<cfcase value="bisadmin.deactivateACourse">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfset form.action = "#action#">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "bisadmin/ManagerCourses/qrydeactivateACourse.cfm">
	    <cfinclude template = "bisadmin/ManagerCourses/dspdeactivateACourse.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

    <cfcase value="bisadmin.ReactivateACourse">
        <cfinclude template = "secure/chk_secured.cfm">
        <cfset XFA.MenuBarSelected = "AboutUs">
        <cfset XFA.bannerFile = "images/banner_about.jpg">
        <cfset form.action = "#action#">
        <cfset course = request.CourseManager.GetCourseByID(url.course) />
		<!--- https://bistrainer.atlassian.net/browse/BIS-3401 --->
		<cfset CourseNotes = "Course has been reactivated">
		<cfset result = request.CourseManager.saveCourseNotes(url.course, CourseNotes) />
        <cfset course.setActive(1) />
        <cfset course.setStatus('test') />
        <cfset course.Save() />
        <cflocation url="index.cfm?action=bisadmin.courseHome#session.xxautotoken#" />
    </cfcase>

	<!--- ******* ADMINISTRATOR Deactivate a Video/ DASHBOARD ******* --->
	<cfcase value="bisadmin.deactivateAVideo">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
        <cfscript>
            objCourse = request.CourseManager.GetCourseByID(session.adminCourseID);
            contentObj = objCourse.GetContent(url.coursecontentno);
			objCourse.DeactivateContentElement(contentObj);
			CourseNotes = contentObj.Title & " deleted";
			result = request.CourseManager.saveCourseNotes(session.adminCourseID, CourseNotes);
        </cfscript>
        <cflocation url="index.cfm?action=bisadmin.CourseDetails&course=#session.adminCourseID##session.xxautotoken#">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR Deactivate a Chapter/ DASHBOARD ******* --->
	<cfcase value="bisadmin.deactivateAChapter">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
        <cfscript>
            objCourse = request.CourseManager.GetCourseByID(session.adminCourseID);
            objCourse.DeactivateContentElement(objCourse.GetContent(url.coursecontentno));
        </cfscript>
        <cflocation url="index.cfm?action=bisadmin.CourseDetails&course=#session.adminCourseID##session.xxautotoken#">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR Deactivate AN ANSWER/ DASHBOARD ******* --->
	<cfcase value="bisadmin.deactivateAAnswer">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
        <cfinclude template = "bisadmin/ManagerCourses/qrydeactivateAAnswer.cfm">
        <cfif IsDefined('form.pid')>
			<cfif structkeyexists(url,'id')>
				<cflocation url="index.cfm?action=bisadmin.QuestionContents&id=#url.id#&pid=#form.pid#&questionno=#url.questionno##session.xxautotoken#">
			<cfelse>
				<cflocation url="index.cfm?action=bisadmin.QuestionContents&pid=#form.pid#&questionno=#url.questionno##session.xxautotoken#">
			</cfif>
        <cfelse>
			<cfif structkeyexists(url,'id')>
				<cflocation url="index.cfm?action=bisadmin.QuestionContents&id=#url.id#&questionno=#url.questionno##session.xxautotoken#">
			<cfelse>
				<cflocation url="index.cfm?action=bisadmin.QuestionContents&questionno=#url.questionno##session.xxautotoken#">
			</cfif>
        </cfif>
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.addImage">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManagerCourses/actAddImage.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>

	<!--- Move/Copy a course --->
	<cfcase value="bisadmin.moveCourse">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageCompany/qryGetAllCompanies.cfm">
		<cfinclude template = "bisadmin/ManagerCourses/dspMoveACourse.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.copyCourse">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageCompany/qryGetAllCompanies.cfm">
		<cfinclude template = "bisadmin/ManagerCourses/dspCopyACourse.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.copyQuestionpool">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageCompany/qryGetAllCompanies.cfm">
		<cfinclude template = "bisadmin/ManagerCourses/dspCopyQuestionpool.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.MoveQuestionpool">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageCompany/qryGetAllCompanies.cfm">
		<cfinclude template = "bisadmin/ManagerCourses/dspMoveQuestionpool.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.ViewCourseQuestionPool">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
        <cfinclude template="bisadmin/ManagerCourses/dspViewCourseQuestionPool.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.AddToCourseQuestionPool">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
        <cfinclude template="bisadmin/ManagerCourses/actAddToCourseQuestionPool.cfm">
	</cfcase>

	<cfcase value="bisadmin.deactivateQuestionInPool">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
        <cfinclude template="bisadmin/ManagerCourses/actDeactivateQuestionInPool.cfm">
	</cfcase>

	<cfcase value="bisadmin.RandomQuestionContents">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template="bisadmin/ManagerCourses/dspDisplayRandomQuestionContent.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.editRandomQuestion">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
        <cfinclude template="BISadmin/ManagerCourses/actEditRandomQuestion.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR MANAGER VIEW/ DASHBOARD ******* --->
	<cfcase value="bisadmin.ManagerView">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset variables.dec = decrypt('#url.nodes#', 'password', 'BLOWFISH', 'Hex')>
		<cfset node = application.fwDummy.uEncrypt(variables.dec)>
		<cfif structKeyExists(url, "newuser")>
			<cfset variables.uDec = decrypt('#url.newuser#', 'password', 'BLOWFISH', 'Hex')>
			<cfset user = application.fwDummy.uEncrypt(variables.uDec)>
			<cflocation url = "#application.sysBasePath#?action=manager.users&nodes=#node#&newuser=#user#">
		</cfif>
		<cflocation url = "#application.sysBasePath#?action=manager.users&nodes=#node#">
	</cfcase>

	<!--- ******* ADMINISTRATOR MOVE A USER / DASHBOARD ******* --->
	<cfcase value="bisadmin.MoveUser">
			<cfset variables.moveUserParameter = "">
			<cfset variables.users = "">
			<cfif structKeyExists(url, "users")
				AND listLen(url.users)>
				<cfset variables.users = url.users>
			<cfelseif structKeyExists(form, "users")
				AND listLen(form.users)>
				<cfset variables.users = form.users>
			</cfif>
			<cfif val(url?.fromSearch)>
				<cfset variables.moveUserParameter &= "&fromSearch=" & url.fromSearch>
			</cfif>
			<cfif listLen(variables.users)>
				<cfset variables.moveUserParameter &= "&users=" & "#isNUmeric(listFirst(variables.users)) EQ 1
					? application.fwDummy.uEncrypt(variables.users)
					: variables.users#">
			</cfif>
			<cfif listfind(cadminrole,'superadmin')
				OR listfind(cadminrole,'bisadmin')
				OR listfind(cadminrole,'clientsenioradmin')>
			<cfelseif listfind(cadminrole,'clientadmin')
				OR listfind(cadminrole,'locationadmin')
				OR listfind(cadminrole,'courseadmin')
				OR listfind(cadminrole, 'LearnerSearch')>
				<cfset variables.moveUserParameter &= "&companyId=" &  session.loginusercompanyid>
			</cfif>
			<cflocation url="/v1/index.cfm?action=bisadmin.moveuser#variables.moveUserParameter#" addtoken="false">
	</cfcase>

	<!--- ******* ADMINISTRATOR ADD MANAGER FORM/ DASHBOARD ******* --->
	<cfcase value="bisadmin.AddManagerForm">
		<cfset variables.locationId = left(url.node, 1) EQ "_"
			? url.node
			: application.fwDummy.uEncrypt(url.node)>
		<cflocation url = "#application.sysBasePath#?action=manager.user&node=#variables.locationId#" addtoken = "no">
	</cfcase>

	<!--- ******* ADMINISTRATOR EMAIL INVITATION CODE / DASHBOARD ******* --->
	<cfcase value="bisadmin.emailInvitationCode">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "manager/dspEmailInvitationCode.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR DEACTIVATE MANAGERS / DASHBOARD ******* --->
	<cfcase value="bisadmin.DeActivateManagers">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "manager/qryDeActivateLearner.cfm">
		<cflocation url="index.cfm?action=bisadmin.ManagerView&nodes=#encrypt('#session.adminCompanyGroupID#', 'password', 'BLOWFISH', 'Hex')##session.xxautotoken#">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR VIEW  MANAGER PROFILE/ DASHBOARD ******* --->
	<cfcase value="bisadmin.ViewManagerProfile">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- ******* ADMINISTRATOR MANAGE COMPANIES/ DASHBOARD ******* --->
	<cfcase value="bisadmin.ManageCompanies">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- ******* ADMINISTRATOR ADD A NEW NODE/ DASHBOARD ******* --->
	<cfcase value="bisadmin.AddNewNode">
			<cflocation url = "#application.sysBasePath#?action=manager.addlocation&locationid=#application.fwDummy.uEncrypt(url.node)#"
				addtoken = "no">
	</cfcase>

	<!--- ******* ADMINISTRATOR ACTIVATION/DEACTIVATION OF A COMPANY/ DASHBOARD ******* --->
	<cfcase value="bisadmin.ActivateDeactivateACompany">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "bisadmin/ManageCompany/qryActivateDeactivateACompany.cfm">
		<cflocation url="index.cfm?action=bisadmin.Home&flag=1#session.xxautotoken#">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR ADD COMPANY/ DASHBOARD ******* --->
	<cfcase value="bisadmin.AddCompany">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- ******* ADMINISTRATOR EDIT COMPANY/ DASHBOARD ******* --->
	<cfcase value="bisadmin.EditCompany">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfset form.company = url.companyno>
		<cfinclude template = "bisadmin/ManagerCourses/qryGetBannerUrlTypes.cfm">
		<cfinclude template = "bisadmin/ManageCompany/qryGetAllNodesOfACompany.cfm">
		<cfinclude template = "learner/UpdateProfile/qryGetAllStatesAndCountries.cfm" >
		<cfinclude template = "bisadmin/ManageCompany/dspAddEditACompany.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.ReorderNavigationLinks">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfset form.company = url.companyno>
		<cfinclude template = "bisadmin/ManageCompany/qryGetNavigationLinks.cfm">
		<cfinclude template = "bisadmin/ManageCompany/dspDisplayNavigationLinksForReodering.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.NavigationLinksReordering">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfset form.company = url.companyno>
		<cfinclude template = "bisadmin/ManageCompany/qryReorderedNavigationLinks.cfm">
		<cfinclude template = "bisadmin/ManageCompany/dspReorderedNavigationLinks.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR COMPANY EDITED/ DASHBOARD ******* --->
	<cfcase value="bisadmin.CompanyEdited">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageCompany/actEditCompany.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.BrandingAssetEdited">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageCompany/actEditBrandingAsset.cfm">
		<cflocation url="index.cfm?action=bisadmin.EditCompany&companyno=#form.companyno#&#session.xxAutoToken#">
	</cfcase>


	<!--- ******* ADMINISTRATOR Company ADDED/ DASHBOARD ******* --->
	<cfcase value="bisadmin.EditANode">
		<cflocation url = "#application.sysBasePath#?action=manager.editlocation&locationid=#application.fwDummy.uEncrypt(url.node)#"
			addtoken = "no">
	</cfcase>

	<!--- ******* ADMINISTRATOR ATTACH A NODE/ DASHBOARD ******* --->
	<cfcase value="bisadmin.AttachANode">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfif !isValid("integer", node)>
			<cfset node = application.fwDummy.uDecrypt(node)>
		</cfif>
		<cfinclude template = "bisadmin/ManageCompany/qryGetAttachedNodes.cfm">
		<cfinclude template = "bisadmin/ManageCompany/qryGetNameOfANode.cfm">
		<cfif isDefined("form.company") AND (#form.company# GT 0)>
			<cfif !isDefined("form.nodetoattach")>
				 <cfinclude template = "bisadmin/ManageCompany/qryGetAllNodesOfACompany.cfm">
			<cfelseif isDefined("form.nodetoattach") AND (#form.nodetoattach# GT 0)>
				<cfinclude template = "bisadmin/ManageCompany/dspCheckForSameCompanyNodes.cfm">
				<cfif #nodeexist# eq 0>
					<cfinclude template = "bisadmin/ManageCompany/qryAttachNode.cfm">
					<cflocation url="index.cfm?action=bisadmin.AttachANode&node=#session.adminParentID##session.xxAutoToken#">
				</cfif>
			</cfif>
		</cfif>
		<cfif (isDefined("nodeexist") AND #nodeexist# eq 0) OR (!isDefined("nodeexist"))>
			<cfinclude template = "bisadmin/ManageCompany/dspAttachedNodes.cfm">
		</cfif>
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR DELETE A CHILD NODE/ DASHBOARD ******* --->
	<cfcase value="bisadmin.DeleteAChildNode">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageCompany/qryDeleteAChildNode.cfm">
		<cflocation url="index.cfm?action=bisadmin.AttachANode&node=#session.adminParentID##session.xxAutoToken#">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR VIEW DELETED NODES/ DASHBOARD ******* --->
	<cfcase value="bisadmin.ViewDeletedNodes">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfif isDefined("node")>
			<cfif isDefined("mode") and mode EQ 1>
				<cfinclude template = "bisadmin/ManageCompany/qryUndeleteANode.cfm">
			<cfelseif isDefined("mode") and mode EQ 0>
				<cfinclude template = "bisadmin/ManageCompany/qryPurgeANode.cfm">
			</cfif>
		</cfif>
		<cfinclude template = "bisadmin/ManageCompany/qryViewDeletedNodes.cfm">
		<cfinclude template = "bisadmin/ManageCompany/dspViewDeletedNodes.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR SYSTEM SETTINGS/ DASHBOARD ******* --->
	<cfcase value="bisadmin.SystemSettings">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfif isDefined("form.Property") OR isDefined('form.OptionalFeatures') OR isDefined('form.MasterNotification')>
	  	 <cfinclude template = "bisadmin/qryUpdateSystemSettings.cfm">
		</cfif>
		<cfif isDefined("form.savesystemthreshold")>
		 <cfinclude template = "bisadmin/qryUpdateSystemThresholds.cfm">
		</cfif>
		<cfinclude template = "bisadmin/qryGetSystemThresholds.cfm">
	  	<cfinclude template = "bisadmin/qryGetSystemSettings.cfm">
	  	<cfinclude template = "bisadmin/dspSystemSettings.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR ALL REPORTS/ DASHBOARD ******* --->
	<cfcase value="bisadmin.AllReports">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
	  	<cfinclude template = "bisadmin/ManageReports/qryGetAllReports.cfm">
		<!--- BEGIN: RRK :: Suncor - LMS - Report auto-run & email schedule BIS517Q (Billable) --->
	  	<cfinclude template = "bisadmin/ManageReports/qryGetAllScheduledReports.cfm">
		<!--- END: RRK :: Suncor - LMS - Report auto-run & email schedule BIS517Q (Billable) --->
	  	<cfinclude template = "bisadmin/ManageReports/dspAllReports.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR REPORT PARAMETERS/ DASHBOARD ******* --->
	<cfcase value="bisadmin.ReportParameters">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
	  	<cfinclude template = "bisadmin/ManageReports/qryGetReportParameters.cfm">
	  	<cfinclude template = "bisadmin/ManageReports/dspReportParameters.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

<!--- BEGIN: RRK :: Suncor - LMS - Report auto-run & email schedule BIS517Q (Billable) --->
	<!--- ******* ADMINISTRATOR REPORT PARAMETERS/ DASHBOARD ******* --->
	<cfcase value="bisadmin.ReportParametersAjax">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageReports/qryGetReportParameters.cfm">
		<cfinclude template = "bisadmin/ManageReports/dspReportParametersAjax.cfm">
	</cfcase>
<!--- END: RRK :: Suncor - LMS - Report auto-run & email schedule BIS517Q (Billable) --->

	<!--- ******* ADMINISTRATOR REPORT PARAMETERS/ DASHBOARD ******* --->
	<cfcase value="bisadmin.RunReport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
	  	<cfinclude template = "bisadmin/ManageReports/dspRunReport.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR ADD EDIT LANGUAGES/ DASHBOARD ******* --->
	<cfcase value="bisadmin.LanguageAddEdit">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
	  	<cfinclude template = "bisadmin/ManageLanguages/qryGetAllLanguages.cfm">
	  	<cfinclude template = "bisadmin/ManageLanguages/dspAllLanguages.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- BEGIN: Language Table Updation 0/18/2016 --->
	<cfcase value="bisadmin.AddLanguageEntry">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "bisadmin/ManageLanguages/qryGetAllLanguages.cfm">
	  	<cfinclude template = "bisadmin/ManageLanguages/dspAddLanguageEntry.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>
	<!--- END: Language Table Updation 0/18/2016 --->

	<!--- ******* ADMINISTRATOR EDIT  A LANGUAGES/ DASHBOARD ******* --->
	<cfcase value="bisadmin.LanguageEdit">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
	  	<cfinclude template = "bisadmin/ManageLanguages/qryGetALanguage.cfm">
	  	<cfinclude template = "bisadmin/ManageLanguages/dspGetALanguage.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR A LANGUAGE UPDATED/ DASHBOARD ******* --->
	<cfcase value="bisadmin.LanguageEdited">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
	  	<cfinclude template = "bisadmin/ManageLanguages/qryIfALanguageAlreadyExists.cfm">
		<cfif isDefined("qryIfALanguageAlreadyExists.recordcount") AND (#qryIfALanguageAlreadyExists.recordcount# GT 0)>
			<cfinclude template = "bisadmin/ManageLanguages/dspIfALanguageAlreadyExists.cfm">
		<cfelse>
			<cfinclude template = "bisadmin/ManageLanguages/qryALanguageUpdated.cfm">
			<cflocation url="index.cfm?action=bisadmin.LanguageAddEdit#session.xxAutoToken#">
		</cfif>
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR ADD A NEW LANGUAGE/ DASHBOARD ******* --->
	<cfcase value="bisadmin.LanguageAdded">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
	  	<cfinclude template = "bisadmin/ManageLanguages/qryALanguageAdded.cfm">
		<cflocation url="index.cfm?action=bisadmin.LanguageAddEdit#session.xxAutoToken#">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR Manage Language Contents/ DASHBOARD ******* --->
	<cfcase value="bisadmin.LanguageManageContents">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "bisadmin/ManageLanguages/dspManageLanguageContents.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR Manage Language Contents/ Auto Translate ******* --->
	<cfcase value="bisadmin.LanguageAutoTranslate">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "bisadmin/ManageLanguages/actAutoTranslate.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.ReloadLanguageContents">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
        <cfinclude template = "common/actSiteInternationalizationContents.cfm" />
		<cflocation url="index.cfm?action=bisadmin.LanguageAddEdit#session.xxAutoToken#">
	</cfcase>

	<!--- ******* ADMINISTRATOR Update Content Structure/ DASHBOARD ******* --->
	<cfcase value="bisadmin.UpdateContentStructure">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
	  	<cfinclude template = "bisadmin/ManageLanguages/qryUpdateLanguageStructure.cfm">
        <cfinclude template = "common/actSiteInternationalizationContents.cfm" />
		<cfif isDefined("AnException")>
			<cfinclude template = "bisadmin/ManageLanguages/dspExceptionDisplay.cfm">
		<cfelse>
			<cflocation url="index.cfm?action=bisadmin.LanguageManageContents&language=#language##session.xxAutoToken#">
		</cfif>
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR Export Language Contents/ DASHBOARD ******* --->
	<cfcase value="bisadmin.ExportLanguageContents">
		<cfinclude template = "bisadmin/ManageLanguages/actExportLanguageFile.cfm" >
	</cfcase>

	<!--- ******* ADMINISTRATOR Upload Import Language Contents File/ DASHBOARD ******* --->
	<cfcase value="bisadmin.UploadImportLanguageContentsFile">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "bisadmin/ManageLanguages/dspImportLanguageData.cfm" >
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR Import Language Contents/ DASHBOARD ******* --->
	<cfcase value="bisadmin.ImportLanguageContents">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "bisadmin/ManageLanguages/actImportLanguageData.cfm" >
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR Search/ DASHBOARD ******* --->
	<cfcase value="bisadmin.Search">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- ******* ADMINISTRATOR Search Results/ DASHBOARD ******* --->
	<cfcase value="bisadmin.SearchResults">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfif isDefined("url.reindex")>
			<cfinclude template = "bisadmin/Search/SearchCollections.cfm">
		</cfif>
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- 8760 - todo (wait for test): check if we can remove below as the functionality has been recreated --->
	<cfcase value="bisadmin.MoveACompany">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageCompany/dspMoveACompany.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- 8760 - todo (wait for test): check if we can remove below as the functionality has been recreated --->
	<cfcase value="bisadmin.CompanyMoved">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageCompany/qryMoveACompany.cfm">
		<cflocation url="index.cfm?action=bisadmin.home&flag=1" addtoken="yes">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR MANAGE INVITATIONS / DASHBOARD ******* --->
	<cfcase value="bisadmin.ManageInvitations">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageCompany/actManageInvitations.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* ADMINISTRATOR CREATE LOCATION BASED INVITATIONS / DASHBOARD ******* --->
	<cfcase value="bisadmin.CreateLInvitation">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageCompany/actCreateInvitation.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

		<!--- ******* ADMINISTRATOR DEACTIVATE LOCATION BASED INVITE CODE / DASHBOARD ******* --->
	<cfcase value="bisadmin.DeactivateInviteCode">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageCompany/actDeactivateInviteCode.cfm">
		<cfinclude template="layout/BISFooter.cfm">


	</cfcase>
	<!--- BEGIN: Add Reactivation functionality for invitation code Date:24 Sep 2013 --->
	<cfcase value="bisadmin.ReactivateInviteCode">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageCompany/actReactivateInviteCode.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>
	<!--- END: Add Reactivation functionality for invitation code Date:24 Sep 2013 --->

	<!--- ******* ADMINISTRATOR MANAGE Course Voucher ******* --->
	<cfcase value="bisadmin.ManageCourseVouchers">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!---Begin: 06-Nov 2013 bisadmin courses listing --->
	<cfcase value="bisadmin.Courses">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>
	<!---End: 06-Nov 2013 bisadmin courses listing --->

	<cfcase value="bisadmin.uploadUser">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="bisadmin.addProduct">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManagerCourses/actAddProduct.cfm">
		<cfinclude template = "bisadmin/ManagerCourses/dspAddProduct.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.downloadInstructions">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "bisadmin/managercourses/dspQuestionTypes.cfm">
	</cfcase>
	<!--- BEGIN: BIS-4034- Adding "Download Questions" button to course pools - Same functionality as Playlist -TV0193--->
	<cfcase value="bisadmin.downloadQuestionPoolInstructions">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "bisadmin/managercourses/dspQuestionPoolInstructions.cfm">
	</cfcase>
	<!--- END: BIS-4034- Adding "Download Questions" button to course pools - Same functionality as Playlist -TV0193--->
	<cfcase value="bisadmin.ShipmentVerification">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageShipping/actManageShipping.cfm">
		<cfinclude template = "bisadmin/ManageShipping/dspManageShipping.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.ProductPurchased">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="bisadmin.UploadProductSample">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
	  	<cfinclude template = "bisadmin/ManagerCourses/qryUploadProductSample.cfm">
		<cflocation url="index.cfm?action=bisadmin.addProduct&ProductID=#form.fldProductID##session.xxautotoken#">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.uploaduserrecord">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset EventTo = 'classroom.manageInstructor'>
		<cfinclude template="BISadmin/ManageUsers/actUploadMultipleUserTrainingRecord.cfm">
	</cfcase>

	<!--- BEGIN: RRK :: Russel - TRMS - Mass upload training records for users --->
	<cfcase value="bisadmin.uploadmultipleuserrecord">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset EventTo = 'bisadmin.ManagerView'>
		<cfinclude template="BISadmin/ManageUsers/actUploadMultipleUserTrainingRecord.cfm">
	</cfcase>
	<!--- END: RRK :: Russel - TRMS - Mass upload training records for users --->

	<cfcase value="bisadmin.Browserlog">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "bisadmin/ManageUsers/dspUserBrowserLog.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	 </cfcase>

	<cfcase value="bisadmin.addcompletionforauser">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template="BISadmin/ManageUsers/dspAddManualCompletionForAUser.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.movecoursecompany">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfinclude template = "bisadmin/ManageCompany/qryGetAllCompanies.cfm">
		<cfinclude template="BISadmin/ManagerCourses/actMoveCourseCompany.cfm">
		<cfinclude template = "bisadmin/ManagerCourses/dspMoveCourseCompany.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- ******* FOR CROSS VERIFICATION USERS ******* --->
	<cfcase value="bisadmin.crossverificationUploadUser">
		<cfinclude template = "secure/chk_secured.cfm">    							<!--- security check --->
		<cfset XFA.MenuBarSelected = "AboutUs">										<!--- set selected color on menu bar to: --->
		<cfset XFA.bannerFile = "images/banner_about.jpg">							<!--- set banner image in header --->
		<cfinclude template="layout/BISHeaderPrivate.cfm">
            <!--- do the tracking --->
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageUsers/actUploadCrossverificationUsers.cfm">    			<!--- call query file --->
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.crossverificationUploadUserTemplate">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfheader name="Content-Disposition" value='inline; filename="Cross Verification Excel Template.xls"'>
		<cfcontent type="application/msexcel" file="#application.appAssetPath#/general/Cross Verification Excel Template.xls" deletefile="false">
	</cfcase>

	<cfcase value="bisadmin.individualSummaryReport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="bisadmin/manageusers/individualsummaryreport.cfm">
    </cfcase>

	<cfcase value="bisadmin.examSummaryReport">
		<!--- <cfinclude template = "secure/chk_secured.cfm"> --->
		<cfinclude template="bisadmin/manageusers/examSummaryReport.cfm">
    </cfcase>

	<cfcase value="bisadmin.uploadimageforquestion">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="BISadmin/managercourses/actUploadImageForAQuestion.cfm">
	</cfcase>

	<cfcase value="bisadmin.sendDriverEmailNotification">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfif len(trim(url.companyno))>
			<cfset variables.companyno = url.companyno>
		</cfif>
		<cfinclude template="common/actDriverDocExpiryReminderMailScheduler.cfm">
	</cfcase>

	<cfcase value="bisadmin.VideoLinkContents">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfinclude template="BISadmin/ManagerCourses/dspEditVideoLink.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.deactivateAContentLibrary">
		<cfinclude template = "secure/chk_secured.cfm">
		<!--- BEGIN: Client Admins can gain access to user accounts / courses / etc. outside of their company with URL manipulation : BIS-3752 : TV0032 : 04 Aug 2017 --->
		<cfif NOT request.UserManager.isAllowedAccessOnPage(ItemID = url.id, ItemType = 'contentlibrary', Action = 'bisadmin.deactivateAContentLibrary')>
			<cflocation url="#application.sysBasePath#?action=public.noaccess" addtoken="false">
		</cfif>
		<!--- END: Client Admins can gain access to user accounts / courses / etc. outside of their company with URL manipulation : BIS-3752 : TV0032 : 04 Aug 2017 --->
		<cfset contentLibraryID = request.ContentLibraryManager.deactivateAContentLibrary(ContentLibraryID=url.id)>
        <cflocation url="index.cfm?action=bisadmin.courseHome#session.xxautotoken#" addtoken="no">
	</cfcase>

	<cfcase value="bisadmin.ContentLibraryDetails">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfparam name="url.id" default="0">
		<cfparam name="form.contentLibraryID" default="#url.id#">
		<cfset objContentLibrary = request.ContentLibraryManager.GetContentLibraryByID(form.contentLibraryID)>
		<!--- BEGIN: Client Admins can gain access to user accounts / courses / etc. outside of their company with URL manipulation : BIS-3752 : TV0032 : 04 Aug 2017 --->
		<cfif NOT request.UserManager.isAllowedAccessOnPage(
			ItemID = form.contentLibraryID, ItemType = 'contentlibrary', Action = 'bisadmin.ContentLibraryDetails', ItemCompanyID = objContentLibrary.getCompanyID()
		)>
			<cflocation url="#application.sysBasePath#?action=public.noaccess" addtoken="false">
		</cfif>
		<cfif objContentLibrary.getID() EQ 0>
			<cfthrow message="Invalid ID">
		</cfif>
		<cfset companyID = application.fwDummy.uEncrypt(objContentLibrary.getCompanyID())>
		<cfset libraryID = application.fwDummy.uEncrypt(form.contentLibraryID)>
		<cflocation url="/v1/index.cfm?action=bisadmin.contentlibrarydetails&library=#libraryID#&company=#companyID#" addtoken="false">
	</cfcase>

	<cfcase value="bisadmin.ViewEmployeeIDConflict">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfinclude template = "bisadmin/ManageCompany/dspListEmployeeIDConflict.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.classroompurchasereport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfif NOT(listfindnocase(request.cadminrole,'bisadmin') OR listfindnocase(request.cadminrole,'superadmin'))><cfabort></cfif>
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ClassroomPurchaseReports.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.membershipPurchasereport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfif NOT(listfindnocase(request.cadminrole,'bisadmin') OR listfindnocase(request.cadminrole,'superadmin'))><cfabort></cfif>
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/membershipPurchaseReports.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.exportscormpackage">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "bisadmin/managercourses/actExportSCORMPackage.cfm">
	</cfcase>

	<!--- BEGIN: Move completions from one account to another; March 9, 2016 --->
	<cfcase value="bisadmin.movecompletionforauser">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template="BISadmin/ManageUsers/dspMoveCompletionForAUser.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>
	<!--- BEGIN: Move completions from one account to another; March 9, 2016 --->
	<cfcase value="bisadmin.SalesTracking">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>
	<!--- END: Sales Tracking 04/08/2016 --->
	<!--- BEGIN:Drag and Drop documents inside of a course  --->
	<cfcase value="bisadmin.DocumentUploadContents">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
	    <cfinclude template = "BISadmin/ManagerCourses/dspDisplayDocUploadContents.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>
	<cfcase value="bisadmin.editDocumentUpload">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
	    <cfinclude template = "BISadmin/ManagerCourses/qryEditADocUpload.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>
	<!--- END:Drag and Drop documents inside of a course  --->
	<!--- BEGIN:FORMS inside of a Course, as an element --->
	<cfcase value="bisadmin.FormContents">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
	    <cfinclude template = "BISadmin/ManagerCourses/dspDisplayFormContents.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>
	<cfcase value="bisadmin.editForm">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
	    <cfinclude template = "BISadmin/ManagerCourses/qryEditAForm.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.schedulereports">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset XFA.MenuBarSelected = "Schedule Report">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/ManageReports/qryGetAllReports.cfm">
		<cfinclude template = "bisadmin/ManageReports/actScheduledReportsManage.cfm">
		<cfinclude template = "bisadmin/ManageReports/dspScheduledReportsManage.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="bisadmin.deleteschedulereports">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "bisadmin/ManageReports/actScheduledReportsDelete.cfm">
	</cfcase>
	<cfcase value="bisadmin.RunReportHttp">
		<cfif cgi.HTTP_USER_AGENT NEQ 'ColdFusion'>
			<cfset application.mailService.customErrorEmailHandler(subject="Error - bisadmin.RunReportHttp", toAddresses="rejith.krishnan@bistraining.ca", form=form, headers=getHttpRequestData().headers, cgi=cgi)>
			<cfheader statuscode = 403 statustext = "Forbidden">
			<cfabort>
		</cfif>

		<!--- DO NOT REMOVE: This variable is used in report templates to handle the issue with the report user role --->
		<cfset isCFHTTP = true>
		<cfif structKeyExists(form, 'fldScheduledUserID') AND val(form.fldScheduledUserID)>
			<cfset cadminrole = request.UDFLib.getUserTypeByUserID(form.fldScheduledUserID)>
			<cfset request.cadminrole = cadminrole>
			<cfquery name="qScheduleCreator" datasource="#application.dsn#">
				SELECT
					U.fldUser_ID AS UserID,
					U.fldFirstName AS FirstName,
					U.fldLastName AS LastName,
					U.fldUserCompanyID AS CompanyID,
					U.fldReportingLevel AS Location
				FROM
					tblUser U
				WHERE U.fldUser_ID = <cfqueryparam cfsqltype="integer" value="#form.fldScheduledUserID#">
			</cfquery>
			<cfset session.loginusercompanyid = val(qScheduleCreator.CompanyID)>
			<cfset session.loginuserid = form.fldScheduledUserID>
			<cfset session.loginuserreportinglevel = qScheduleCreator.Location>
			<cfquery datasource="#application.dsn#" name="qryGetChildCompanyList">
				SELECT fnChildList(#val(qScheduleCreator.CompanyID)#,0) as CompList
			</cfquery>
			<cfset session.childCompanyList = qryGetChildCompanyList.CompList>
		</cfif>
		<!--- DO NOT REMOVE: This variable is used in report templates to handle the issue with the report user role --->
		<cfinclude template = "bisadmin/ManageReports/dspRunReport.cfm">
	</cfcase>
	<cfcase value="bisadmin.schedulereportactions">
		<cfinclude template = "bisadmin/ManageReports/actScheduledReportActions.cfm">
	</cfcase>
	<!--- END: RRK :: Suncor - LMS - Report auto-run & email schedule BIS517Q (Billable) --->

	<cfcase value="bisadmin.PurchaseOrderTracking">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<!--- BEGIN:Fountain - LMS - Location Excel Upload Feature (Non-Billable)  --->
	<cfcase value="bisadmin.uploadLocation">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfinclude template = "bisadmin/actuploadlocation.cfm">
		<cfinclude template = "layout/BISFooterLogged.cfm">
	</cfcase>
	<!--- END: Fountain - LMS - Location Excel Upload Feature (Non-Billable) --->
	<!--- BEGIN : RRK :: BIS - eCommerce Report Copy (nonbillable) --->
	<cfcase value="bisadmin.updatedpurchasemonthendreport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfif NOT(listfindnocase(request.cadminrole,'bisadmin') OR listfindnocase(request.cadminrole,'superadmin'))><cfabort></cfif>
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfset variables.rootPath = "#application.appAssetPath#/UpdatedPurchaseMonthEndReports/">
		<cfset variables.urlPath = "/Assets/UpdatedPurchaseMonthEndReports/">
		<cfinclude template = "bisadmin/dspPurchaseMonthEndReports.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>
	<!--- END : RRK :: BIS - eCommerce Report Copy (nonbillable) --->
	<!--- BEGIN : RRK :: Add options for BISAdmin to Run Month End report Manually --->
	<cfcase value="bisadmin.runnewmonthendreport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "common/actNewMonthEndReportScheduler.cfm">
		<cflocation url="index.cfm?action=bisadmin.newmonthendreport" addtoken="false">
	</cfcase>
	<cfcase value="bisadmin.runnewmonthendesafetyreport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "common/actNewmonthendReport_esafety.cfm">
		<cflocation url="index.cfm?action=bisadmin.newmonthendreport" addtoken="false">
	</cfcase>
	<!--- END : RRK :: Add options for BISAdmin to Run Month End report Manually --->
	<!--- BEGIN : RRK :: BIS Add Run Report Option to Reporting Screens (Nonbillable) --->
	<cfcase value="bisadmin.runclassroompurchasereport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "common/actClassroomPurchaseReportScheduler.cfm">
		<cflocation url="index.cfm?action=bisadmin.classroompurchasereport" addtoken="false">
	</cfcase>
	<cfcase value="bisadmin.runMembershipPurchaseReport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "common/actMembershipPurchaseReportScheduler.cfm">
		<cflocation url="index.cfm?action=bisadmin.membershipPurchasereport" addtoken="false">
	</cfcase>
	<!--- END : RRK :: BIS Add Run Report Option to Reporting Screens (Nonbillable) --->
	<!--- BEGIN : RRK :: URGENT - New Report - Raw Data Pull (non-billable) --->
	<!---************ ADMINISTRATOR comapnies RawMonthEndReports display************************ --->
	<cfcase value="bisadmin.rawmonthendreport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfif NOT(listfindnocase(request.cadminrole,'bisadmin') OR listfindnocase(request.cadminrole,'superadmin'))><cfabort></cfif>
		<cfset XFA.MenuBarSelected = "AboutUs">
		<cfset XFA.bannerFile = "images/banner_about.jpg">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfset form.action = "#action#">
		<cfinclude template = "bisadmin/dspRawMonthEndReports.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>
	<cfcase value="bisadmin.runrawmonthendreport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfif NOT(listfindnocase(request.cadminrole,'bisadmin') OR listfindnocase(request.cadminrole,'superadmin'))><cfabort></cfif>
		<cfset form.action = "#action#">
		<cfinclude template = "common/actRawMonthEndReportScheduler.cfm">
		<cflocation url="index.cfm?action=bisadmin.rawmonthendreport" addtoken="false">
	</cfcase>
	<!--- END : RRK :: URGENT - New Report - Raw Data Pull (non-billable) --->
	<!--- BEGIN: OSSA - LMS - New ENDORSEMENT and Global ID feature (Billable) - BIS-3631 8/25/2017 TV0119 --->
	<cfcase value="bisadmin.endorsementReport">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfif NOT(listfindnocase(request.cadminrole,'bisadmin') OR listfindnocase(request.cadminrole,'superadmin'))><cfabort></cfif>
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template = "bisadmin/dspEndorsementReports.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>
	<!--- END: OSSA - LMS - New ENDORSEMENT and Global ID feature (Billable) - BIS-3631 8/25/2017 TV0119 --->
	<cfcase value="bisadmin.runschedulereportsmanual">
		<cfinclude template = "common/actscheduledreportsscheduler.cfm">
	</cfcase>
	<cfcase value="bisadmin.generatedreportupdate">
		<cfinclude template = "BISadmin/ManageReports/actGeneratedReportUpdate.cfm">
	</cfcase>
	<cfcase value = "bisadmin.languagecopy">
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfinclude template = "bisadmin/ManageLanguages/dspLanguageCopy.cfm">
	</cfcase>
	<cfdefaultcase>
		<cfset variables.ActionEventNotFound = variables.ActionEventNotFound + 1>
	</cfdefaultcase>
</cfswitch>
