<cfparam name="attributes.action" default="">
<cfparam name="variables.ActionEventNotFound" default="0">
<cfswitch expression = "#attributes.action#">

	<cfcase value="store.home">
		<cfinclude template="store/results.cfm">
	</cfcase>

	<cfcase value="store.viewall">
		<cfinclude template="store/results.cfm">
	</cfcase>

	<cfcase value="store.CourseDetails">
		<cfif isDefined("companyNumber") AND companyNumber EQ 0>
			Invalid category. There is no company configured to use the specified category.
		<cfelse>
			<cfinclude template = "store/Details.cfm">
		</cfif>
	</cfcase>

	<cfcase value="store.PrintInvoice">
		<cfset request.UdFLib.redirectNewSite()>
	</cfcase>

	<cfcase value="store.TicketVerification">
		<cfset request.UdFLib.redirectNewSite()>
	</cfcase>

	<cfcase value="store.addtocartfrombundle">
		<cfinclude template = "store/addtocartfrombundle.cfm">
	</cfcase>

	<cfdefaultcase>
		<cfset variables.ActionEventNotFound = variables.ActionEventNotFound + 1>
	</cfdefaultcase>
</cfswitch>