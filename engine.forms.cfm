
<!---
      Name        :   engine.forms.cfm
      Desciption  :   Engine file for forms and documents section
      Date        :   January 10, 2017
      Author      :   Techversant TV0067
 --->

<cfswitch expression="#attributes.action#">
  <cfcase value="forms.home,forms.adminHome">
    <cfset request.UdFLib.redirectNewSite(always=true)>
  </cfcase>
  <cfcase value="forms.documents,forms.adminDocuments">
    <cfset request.UdFLib.redirectNewSite(always=true)>
  </cfcase>
  <cfdefaultcase>
    <cfset variables.ActionEventNotFound = variables.ActionEventNotFound + 1>
  </cfdefaultcase>
</cfswitch>