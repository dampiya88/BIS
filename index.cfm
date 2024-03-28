<cfsetting enablecfoutputonly="Yes">
<!--- ******************************* DOCUMENTATION HEADER START **************************
[ ***** DETAILS ***** ]
Filename: index.cfm
* Version: v 1.2
Function: This file listens to all requests on our URL, everything goes throu INDEX.CFM, then passed
	    to the engine to decode the path where to go.
	    	
Original Author: Jas Panesar

Date Created: Mar-12-2003
* Last Modified: Apr-09-2007
[ ***** D E P E N D A N C I E S ***** ]

[ Input ]

URL.action    - The action to goto, called from index.cfm.

[ Change log ]

Apr-09-2003 K Khosa - Added <cftry> and error reporting for over all application.

************************************ DOCUMENTATION HEADER END ***************************--->
<!--- breadcrub logic--->
    
<cfset session.breadcrumb="Learner Home">
<!--- ***********--->

<!--- Set a var named self, contains "index.cfm" --->

<cfparam name="self" default="index.cfm">


<!--- if no action URL.action exists, let's set it to blank, the engine will default it to usr.login on blank --->

<cfif NOT IsDefined( 'attributes.action' )>
<cfparam name = "attributes.action" default = "">
</cfif>

<cfif NOT IsDefined( 'url.action' )>
<cfparam name = "url.action" default = "home.Welcome">
</cfif>

<cfoutput><cfset attributes.action ="#URL.action#"></cfoutput> 


<!--- Include our engine now --->
<!--- We send our action request to our engine file to find where the action wants to go --->
<cfsetting enablecfoutputonly="no">

<cfinclude template = "engine.cfm">
