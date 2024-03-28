<!---
	File Name		: engine.Equipment.cfm
	Date Created	: 13 june 2016
	Purpose			: actions for Equipment related pages.
 --->
<cfparam name="attributes.action" default="">
<cfparam name="variables.ActionEventNotFound" default="0">
<cfswitch expression = "#attributes.action#">
	<cfcase value="Equipment.home">
		<!--- Check and redirect to responsive site; November 29, 2016 --->
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="Equipment.admin">
		<!--- Check and redirect to responsive site; November 29, 2016 --->
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="Equipment.addequipment">
		<!--- 	Added condition for redirecting to new react page	 --->
		<cfif NOT(structKeyExists(url, "old")) OR url.old EQ 0>
			<cfif structKeyExists(url, "equipmentid")>
				<cfset equipmentId = application.fwDummy.uEncrypt(url.equipmentId)>
				<cflocation url = "#application.sysBasePath#?action=equipment.details&equipmentId=#equipmentId#" addToken=false>
			</cfif>
		</cfif>

		<!--- Check and redirect to responsive site; November 29, 2016 --->
		<cfset request.UdFLib.redirectNewSite(always=true)>
	</cfcase>

	<cfcase value="Equipment.openform">
		<cflocation url = "#application.sysBasePath#?action=public.noaccess&deprecated=1">
	</cfcase>
	<!--- Begin: Build an Excel Equipment Uploader similar to User Uploader --->
	<cfcase value="Equipment.downloaduploadtemplate">
		<cfinclude template = "equipment/generateEquipmentUploadExcel.cfm">
	</cfcase>
	<!--- End: Build an Excel Equipment Uploader similar to User Uploader --->


	<cfdefaultcase>
		<cfset variables.ActionEventNotFound = variables.ActionEventNotFound + 1>
	</cfdefaultcase>

</cfswitch>