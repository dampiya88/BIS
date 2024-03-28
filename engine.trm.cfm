<cfparam name="attributes.action" default="">
<cfparam name="variables.ActionEventNotFound" default="0">
<cfset scrollerheight = 500>
<cfswitch expression = "#attributes.action#">
	<!--- TRM Switches --->
	<cfcase value="trm.home">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="trm.providers">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="trm.excelupload">
		<cfinclude template = "secure/chk_secured.cfm">  <!--- Start security --->
		<cfinclude template = "layout/BISHeaderPrivate.cfm">
		<cfinclude template = "trm/actProviderExcelUpload.cfm">
		<cfinclude template = "layout/BISFooter.cfm">
	</cfcase>

	<cfcase value="trm.addprovider">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="trm.topiclinks">
		<!--- Check and redirect to responsive site --->
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="trm.trainingmatrix">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="trm.trainingcourses">
		<cfinclude template = "secure/chk_secured.cfm">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="trm.approvedcourses">
		<!--- Check and redirect to responsive site --->
		<cfinclude template="secure/chk_secured.cfm">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="trm.userrecordupload">
		<cfinclude template="secure/chk_secured.cfm">
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="trm.unsubscribeemail">
		<cfinclude template="trm/actUnsubscribeEmail.cfm">
	</cfcase>
	<!--- *******Download trm certificate  ******* --->
	<cfcase value="trm.downloadcertificate">
		<cfif NOT (
				isDefined("URL.fromemail")
				OR isDefined("URL.frommail")
			)
			AND NOT isDefined("url.data")
		>
			<cfinclude template = "secure/chk_secured.cfm"><!--- security check --->
		</cfif>
		<cfinclude template = "trm/actDownloadCertificate.cfm">
	</cfcase>
	<!--- BEGIN: AJ - TRMS - Add a PURGE option to Courses in Training Providers (Non-Billible) 2/17/2017 T0000V --->
	<cfcase value="trm.DeactivatedCourse">
		<cfinclude template="secure/chk_secured.cfm">
		<cfinclude template="trm/DeactivatedCourseList.cfm">
	</cfcase>
	<!--- END: AJ - TRMS - Add a PURGE option to Courses in Training Providers (Non-Billible) 2/17/2017 T0000V --->
	<cfcase value="trm.removeduplicates">
		<cfinclude template="secure/chk_secured.cfm">
		<cfinclude template="layout/BISHeaderPrivate.cfm">
		<cfinclude template="trm/RemoveDuplicatesRecords.cfm">
		<cfinclude template="layout/BISFooter.cfm">
	</cfcase>

	<!--- BEGIN: JACOS - TRMS - Add an option to upload an image file of the test results to a classoom training record or to a TRM training record (Billable) BIS-3425 --->
	<cfcase value="trm.downloadresult">
		<cfinclude template = "secure/chk_secured.cfm"><!--- security check --->
		<cfinclude template = "trm/actDownloadResult.cfm">
	</cfcase>
	<!--- END: JACOS - TRMS - Add an option to upload an image file of the test results to a classoom training record or to a TRM training record (Billable) BIS-3425 --->

    <cfdefaultcase>
		<cfset variables.ActionEventNotFound = variables.ActionEventNotFound + 1>
	</cfdefaultcase>
</cfswitch>