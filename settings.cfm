<cfsilent>
  <cfif NOT structKeyExists(Session, 'XXAutoToken')>
    <cfparam name="Session.XXAutoToken" default="">
  </cfif>
  <cfparam name="dmDB" default="#application.dsn#"> 
  <cfparam name="dbDatasource" default="#dmDB#">
  <cfset UseNewBISPlayer = true>
</cfsilent>