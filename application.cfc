<cfcomponent displayname="Application"  output="true" hint="Handle the application.">
  <cfset this.Name = "bistrainer">
  <cfset this.SessionManagement = true>
  <cfset this.ApplicationTimeout = CreateTimeSpan(2,0,0,0)>
  <cfset this.SessionTimeout = CreateTimeSpan(0,2,0,0)>
  <cfset this.ClientManagement = false>
  <cfset this.SetClientCookies = true>
  <cfset this.loginStorage = "Session">
  <cfset this.scriptprotect="all">
  <cfset this.customTagPaths = getDirectoryFromPath(getCurrentTemplatePath()) & "common/">

  <cfsetting requesttimeout="300" showdebugoutput="true" enablecfoutputonly="true" />

  <cffunction name="onApplicationStart" returnType="boolean" output="true">
    <cfset application.dsn = "bistrainer">
    <cfset application.ReportingDsn = "bistrainer_report">
    <cfset application.ReplicaDB3Dsn = "bistrainer_replica_db3">
    <cfset application.NoMaintainConnectionDsn = "bistrainer_no_maintain_connection">
    <cfset application.ShoppingCartDsn = "shoppingcart">
    <cfset application.pmdsn = "pm">
    <cfset session.demoquestionscore = 0>
    <cfinclude template="common/actGetSetAppMode.cfm">
    <cfinclude template="common/actGetSetSysVariables.cfm">
    <cfinclude template="common/actGetSetAppVariables.cfm">
    <cfinclude template="common/actSiteInternationalizationContents.cfm">
    <cfinclude template="common/actInitializeDAO.cfm">
    <cfreturn true>
  </cffunction>

  <cffunction name="OnSessionStart" access="public" returntype="void" output="true" hint="Fires when the session is first created." >
    <cfscript>
      local.dsnname = 'bistrainer';
      /*try{
        queryExecute("
          INSERT INTO tblsessionstarttracking(cfid, cftoken, fldServer, fldInstance, fldFrom, fldClientIP) VALUES ( :cfid, :cftoken, :server, :instance, :cgi, :clientIP ) ;
        ", {
          cfid: {value: trim(session?.CFID), cfsqltype: "varchar"},
          cftoken: {value: trim(session?.cftoken), cfsqltype: "varchar"},
          server: {value: left(cgi?.LOCAL_ADDR, 32), cfsqltype: "varchar"},
          instance: {value: "1", cfsqltype: "varchar"},
          cgi: {value:"#left(cgi?.HTTP_URL, 2048)#", cfsqltype:"varchar"},
          clientIP: {value:"#left(cgi?.HTTP_X_FORWARDED_FOR, 256)#", cfsqltype:"varchar"}
        }, {datasource:local.dsnname});
      } catch(any e) {
        mail=new mail();
        try{
          local.environment = application.MailService.getSubjectPrefix();
        } catch(any a){
          local.environment = 'UNKNOWN - ';
        }
        errortext='';
        savecontent variable="errortext" {
          writeDump(var=e, label="cfcatch");
          writeDump(var=CGI, label="CGI");
        };
        mail.setSubject(local.environment & "Error at onSessionStart Tracking error");
        mail.setTo("error@bistrainer.com");
        mail.setFrom("error@bistrainer.com");
        mail.setType("html");
        mail.send(body=errortext);
      }*/
    </cfscript>
  </cffunction>

  <cffunction name="onSessionEnd" returnType="void" output="true">
    <cfargument name="sessionScope" type="struct" required="true">
    <cfargument name="appScope" type="struct" required="true">
    <cfif structKeyExists(arguments.sessionScope, 'loginuserid') AND val(arguments.sessionScope.loginuserid) GT 0>
      <cfset local.dsnname = structKeyExists(arguments.appScope, 'dsn') ? arguments.appScope.dsn : 'bistrainer'>
      <cfquery datasource="#local.dsnname#">
        UPDATE tblUser SET fldIsLoggedIn = 0 WHERE fldUser_ID = <cfqueryparam cfsqltype="integer" value="#arguments.sessionScope.loginuserid#">;
        INSERT INTO tblusersessionendtracking(fldUserID, fldFrom, fldSessionID, fldCGI)
        VALUES (
          <cfqueryparam cfsqltype="integer" value="#arguments.sessionScope.loginuserid#">,
          1,
          <cfqueryparam cfsqltype="varchar" value="&CFID=#trim(arguments.sessionScope?.CFID)#&CFTOKEN=#trim(arguments.sessionScope?.CFTOKEN)#">,
          <cfqueryparam cfsqltype="varchar" value="#left(cgi?.HTTP_URL, 2048)#">
        );
      </cfquery>
    </cfif>
  </cffunction>

  <cffunction name="OnRequestStart">
    <cfargument name="requestname" required=true>
    <cfset request.startTime = gettickcount()>
    <cfif structKeyExists( url, "wsdl" )>
      <cfheader statuscode="403" statustext="Forbidden">
      <cfreturn false>
    </cfif>
    <cfif structKeyExists(url, "CFID") AND structKeyExists(url, "CFTOKEN")>
      <cfset newQstring = "">
      <cfloop list="#cgi.query_string#" index="urlParam" delimiters="&">
        <cfif listFirst(urlParam,"=") NEQ "CFID" AND listFirst(urlParam,"=") NEQ "CFTOKEN">
          <cfset newQstring = listAppend(newQstring,urlParam,"&")>
        </cfif>
      </cfloop>
      <cflocation url="#cgi.script_name#?#newQstring#" addtoken="no">
    </cfif>
    <cfset var actions = ''>
    <cfset application.AppInstance = this>
    <!--- RRK: NOT isdefined("application.dsn") Added to handle the condition where application variables are not created properly. I am not using structKeyExists because there will be error if application scope is not there all together. --->
    <cfif isDefined("url.reinitapp") OR NOT isdefined("application.dsn")>
      <cfset onApplicationStart()>
    </cfif>
    <!--- bock access to site for specific site --->
    <cfif findNoCase('/images/', cgi.script_name) OR( StructKeyExists(CGI, 'HTTP_USER_AGENT') AND cgi.HTTP_USER_AGENT CONTAINS 'DirBuster' )>
      <cfabort>
    </cfif>
    <cfif ( StructKeyExists(CGI, 'HTTP_X_FORWARDED_FOR') AND len(trim(cgi.HTTP_X_FORWARDED_FOR)) ) OR ( StructKeyExists(CGI, 'REMOTE_ADDR') AND len(trim(cgi.REMOTE_ADDR)) )>
      <cfif listFindNoCase(application.blockedIPs, cgi.HTTP_X_FORWARDED_FOR) OR listFindNoCase(application.blockedIPs, CGI.REMOTE_ADDR)>
        <cfabort>
      </cfif>
    </cfif>
    <cfinclude template="common/setDAO.cfm">
    <cfset application.fwUtilService.xssSanitize()>
    <cfset UDFLib = application.UDFLib>
    <cfset cadminrole = UDFLib.getUserType()>
    <cfif structKeyExists(url, "action")>
      <cfset local.roleHaveAccess = UDFLib.checkUserRoleAccess(action = url.action)>
      <cfif NOT val(local.roleHaveAccess)>
         <cflocation url="#application.sysBasePath#?action=public.noaccess" addtoken="false">
      </cfif>
    </cfif>
    <cfset request.cadminrole = cadminrole>
    <cfif val(session?.loginuserid) AND NOT application.fwUtilService.checkAccess()>
      <cflocation url="#application.sysBasePath#?action=public.noaccess" addtoken="false">
    </cfif>
    <cfset local.ipAddress = application.AppMode EQ 'Production' ? cgi.HTTP_X_FORWARDED_FOR : cgi.REMOTE_ADDR>
    <cfset local.redirectURL = urlEncodedFormat(CGI.HTTP_URL)>
    <cfif len(trim(url?.action)) AND NOT val(session?.loginuserid) AND listFindNoCase(application.rateLimitActions,url.action) AND NOT listFindNoCase(application.rateLimitExceptionIPs,local.ipAddress)>
      <cfset local.askCaptcha = application.fwUtilService.rateCheck()>
      <cfif val(local.askCaptcha)>
        <cflocation url="#application.sysFolder#/index.cfm?action=home.loginForm&verify=1&id=#application.fwDummy.uEncrypt(local.askCaptcha)#&redirect=#local.redirectURL#" addtoken="false">
      </cfif>
    </cfif>

    <cfset storeactions = "store.home,store.coursedetails,store.viewall,classroom.home">
    <cfif structKeyExists(url, "action") AND url.action EQ "home.loginform">
      <cfif FindNoCase(CGI.http_host,application.BISSiteURL)>
        <cfset session['LanguageName'] = 'English'>
        <cfset session['Language'] = 1>
      <cfelse>
        <cfset getlanguage = request.ManageCompany.getLanguageFromCompanySettings(customUrl = CGI.http_host)>
        <cfset session['LanguageName'] = getlanguage.languagename>
        <cfset session['Language'] = getlanguage.languageid>
      </cfif>
    <cfelseif NOT StructKeyExists(session, 'languagename') AND structKeyExists(url, "action") AND ListFindNoCase(storeactions, url.action)>     
      <cfif structKeyExists(url, 'category') AND isValid('integer', url.category)>
        <cfset getlanguage = request.ManageCompany.getLanguageFromCompanySettings(categoryId = url.category)>
        <cfset session['LanguageName'] = getlanguage.languagename>
        <cfset session['Language'] = getlanguage.languageid>
      <cfelseif structKeyExists(url, 'company') AND isValid('integer', url.company)>
        <cfset getlanguage = request.ManageCompany.getLanguageFromCompanySettings(companyId = url.company)>
        <cfset session['LanguageName'] = getlanguage.languagename>
        <cfset session['Language'] = getlanguage.languageid>
      <cfelse>
        <cfset session['LanguageName'] = 'English'>
        <cfset session['Language'] = 1>
      </cfif>
    <cfelseif NOT StructKeyExists(session, 'languagename')>
      <cfset session['LanguageName'] = 'English'>
      <cfset session['Language'] = 1>
    </cfif>
    <cfscript>
      if(len(trim(url?.action)) == 0){
        if(len(trim(cgi?.HTTP_URL))){
          request["fr.transaction.name"] = cgi.HTTP_URL;
        }
      }
    </cfscript>
    <cftry>
      <cfif NOT(
        FindNoCase("scormwrapper.cfm",cgi.HTTP_URL)
        OR val(session?.scormWrapper)
        OR FindNoCase("gitpull.cfm",cgi.HTTP_URL)
        OR FindNoCase("reload=1",cgi.HTTP_URL)
      )>
        <cfheader name="Content-Security-Policy" value="frame-ancestors 'self'">
        <cfheader name="X-Frame-Options" value="SAMEORIGIN">
      </cfif>
      <cfcatch type="any">
      </cfcatch>
    </cftry>
    <cfif NOT structKeyExists(session, 'companyDateFormat')
      AND val(session?.loginUserId)
    >
      <cfset session.companyDateFormat = application.defaultDateFormat>
      <cfset session.companyDateFormatID = 1>
    </cfif>
  </cffunction>
  
  <cffunction name="trackRequest">
    <cfargument name="type" type="string" required=true default="">
    <cfscript>
      if(
        val(application?.RequestLogEnabled) == 1
        || trim(cgi?.HTTP_USER_AGENT) == 'CFSCHEDULE'
      ){
        try{
          if(structKeyExists(session, 'startTime')){
            var totalExecTime = getTickCount() - request.startTime;
            if(totalExecTime GT 500 || trim(cgi?.HTTP_USER_AGENT) == 'CFSCHEDULE'){
              var taction = arguments.type;
              taction = listappend(taction, trim(url?.action), ":");
              var pageName = cgi.script_name;
              var tqueryString = cgi.query_string;
              var tuserid = val(session?.loginuserid);
              var tsessionid = trim(session?.sessionid);
              local.qoptions = {datasource=application.dsn};
              local.params = {
                taction: {value=left(taction, 200), cfsqltype="varchar", null=len(trim(taction)) == 0},
                pageName: {value=left(pageName, 200), cfsqltype="varchar"},
                tqueryString: {value=left(tqueryString, 200), cfsqltype="varchar"},
                tUserID: {value=tUserID, cfsqltype="integer", null=len(trim(tUserID)) == 0},
                totalExecTime: {value=totalExecTime, cfsqltype="integer"},
                tsessionid: {value=tsessionid, cfsqltype="varchar", null=len(trim(tsessionid)) == 0}
              };
              QueryExecute("
                INSERT INTO tblPageTracking (fldAction, fldPage, fldQueryString, fldUserID, fldTotalTime, fldSessionID, fldDateCreated)
                VALUES (:taction, :pageName, :tqueryString, :tUserID, :totalExecTime, :tsessionid, now())
              ", local.params, local.qoptions);
            }
          }
        } catch(any e){abort;};
      }
    </cfscript>
  </cffunction>

  <cffunction name="onRequestEnd" output="true">
    <cfargument type="String" name="targetPage" required=true/>
    <cfset trackRequest('success')>
  </cffunction>

  <cffunction name="onError" returnType="void" output="true">
    <cfargument name="exception" required="true">
    <cfargument name="eventname" type="string" required="true">
    <!--- Rejith : Added requesttimeout="0" to make sure timeout errors does not bounce of onError and make issues when big dumps are sent as emails. --->
    <cfsetting requesttimeout="0">
    <cfset trackRequest('error')>
    <cfif val(request?.startTime) GT 0>
      <cfset local.timeTakenInMilliseconds = getTickCount() - val(request?.startTime)>
      <cfset local.newTimeoutInMilliseconds = local.timeTakenInMilliseconds + (10 * 1000)><!--- Adding 10 seconds to the time taken for setting proper timeout --->
      <cfset local.newTimeoutInSeconds = local.newTimeoutInMilliseconds\1000><!--- Adding 10 seconds to the time taken for setting proper timeout --->
      <cfsetting requesttimeout="#local.newTimeoutInSeconds#">
    </cfif>
    <cfset var errortext = "">
    <cfif NOT(structKeyExists(url, 'action') AND url.action EQ 'home.loginForm' AND structKeyExists(url, 'reason') AND url.reason EQ 12) AND processException(arguments.exception) >
      <cfif isDefined('session.loginUserLanguagePref')>
        <cfset userLanguage = session.loginUserLanguagePref>
      <cfelse>
        <cfset userLanguage = 1>
      </cfif>
      <cflocation url="/v1/index.cfm?action=home.loginForm&reason=12&Language=#userLanguage#" addtoken="false">
    <cfelseif NOT(structKeyExists(url, 'action') AND url.action EQ 'home.loginForm' AND structKeyExists(url, 'reason') AND url.reason EQ 12)>
      <cfsavecontent variable ="errortext">
        <cfoutput>An error occurred: http://#cgi.server_name##cgi.script_name#?#cgi.query_string#<br /></cfoutput>
        <cfoutput>Time: #dateFormat(now(), "short")# #timeFormat(now(), "short")#<br />Request StartTime: #trim(request?.startTime)#<br /></cfoutput>
        <cfdump var="#arguments.exception#" label="Error">
        <cfdump var="#form#" label="Form">
        <cfdump var="#url#" label="URL">
        <cfdump var="#CGI#" label="CGI">
        <cfif StructKeyExists(CGI, 'HTTP_X_FORWARDED_FOR')>
          <cfoutput>REMOTE IP: #cgi.HTTP_X_FORWARDED_FOR#</cfoutput>
        </cfif>
      </cfsavecontent>
      <cfmail from="error@bistrainer.com" to="errors@bistraining.ca" subject="Ajax Error" type="html">
        #errortext#
      </cfmail>
      <cfthrow object="#arguments.exception#" />
    </cfif>
  </cffunction>

  <cffunction name="processException" returnType="boolean" output="true" access="public">
    <cfargument name="exception" required="true">

    <cfset var errortext = "">
    <cfset var appname = "">
    <cfset var localVars = {'sessionVars':{}}>
    <cflog file="myapperrorlog" text="#arguments.exception.message#">
    <cfif isDefined("application.dsn")>
      <cfset appname = application.dsn>
    </cfif>

    <cfsavecontent variable="errortext">
      <cfoutput>Application: #appname#<br></cfoutput>
      <cfoutput>An error occurred: http://#cgi.server_name##cgi.script_name#?#cgi.query_string#<br /></cfoutput>
      <cfoutput>Time: #dateFormat(now(), "short")# #timeFormat(now(), "short")#<br />Request StartTime: #trim(request?.startTime)#<br /></cfoutput>
      <cfdump var="#[trim(request?.cadminrole)]#" label="request-cadminrole">
      <cfdump var="#arguments.exception#" label="Error">
      <cfloop item="localVars.each" collection="#session#">
        <cfif ListFindNoCase('userobj,playhead,qrycompanyinfo', localVars.each)><!--- add large unwanted objects in session here ---><cfcontinue></cfif>
        <cfset localVars.sessionVars[localVars.each] = session[localVars.each]>
      </cfloop>
      <cfdump var="#localVars.sessionVars#" label="Session Variables ">
      <cfif structKeyExists(form, 'submit') AND form.submit EQ 'Pay Now'>
        <cfset localVars.formVars = Duplicate(form)>
        <cfif structKeyExists(localVars.formVars, 'CardNumber')><cfset localVars.formVars.CardNumber = 'XXXXX-CFMASK-XXXXX'></cfif>
        <cfif structKeyExists(localVars.formVars, 'ExpMonth')><cfset localVars.formVars.ExpMonth = 'XXXXX-CFMASK-XXXXX'></cfif>
        <cfif structKeyExists(localVars.formVars, 'ExpYear')><cfset localVars.formVars.ExpYear = 'XXXXX-CFMASK-XXXXX'></cfif>
        <cfif structKeyExists(localVars.formVars, 'CardCSV')><cfset localVars.formVars.CardCSV = 'XXXXX-CFMASK-XXXXX'></cfif>
        <cfdump var="#localVars.formVars#" label="Form">
      <cfelse>
        <cfdump var="#form#" label="Form">
      </cfif>
      <cfdump var="#url#" label="URL">
      <cfdump var="#CGI#" label="CGI">
      <cftry>
        <cfdump var="#cookie#" label="Cookie">
      <cfcatch></cfcatch>
      </cftry>
      <cfscript>
        try{
          if(findNoCase("application/json", cgi.content_type)){
            writeDump(var=deserializeJSON(toString(getHTTPRequestData().content)), label="HTTPRequestData1");
          } else {
            writeDump(var=[toString(getHTTPRequestData().content)], label="HTTPRequestData2");
          }
        } catch(any e){};
      </cfscript>
      <cfif StructKeyExists(CGI, 'HTTP_X_FORWARDED_FOR')>
      <cfoutput>REMOTE IP: #cgi.HTTP_X_FORWARDED_FOR#</cfoutput>
      </cfif>
    </cfsavecontent>
    <cfset local.subjectMessage = "">
    <cfif structKeyExists(arguments.exception, "Message")>
      <cfset local.subjectMessage = arguments.exception.Message>
    </cfif>
    <cfset local.errorEmailAddress = len(trim(application?.errormailaddreses)) ? application.errormailaddreses : 'error@bistrainer.com'>
    <cftry>
      <cfset local.environment = application.MailService.getSubjectPrefix()>
      <cfcatch type="any">
        <cfset local.environment = ''>
      </cfcatch>
    </cftry>
    <cfmail from="error@bistrainer.com" to="#local.errorEmailAddress#" subject="#local.environment#Error at #cgi.http_host# - #local.subjectMessage#" type="html">
      #errortext#
    </cfmail>
    <cfreturn true>
  </cffunction>

  <cffunction name="onMissingTemplate" access="public" returntype="boolean" output="true" hint="I execute when a non-existing CFM page was requested.">
    <cfargument name="template" type="string" required="true" hint="I am the template that the user requested.">
    <cfreturn true />
  </cffunction>

</cfcomponent>
