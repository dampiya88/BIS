<cfset application.util.recordTemplatePathUsage(template=getCurrentTemplatePath())>
<cftry>
<cfparam name="url.debug" default="0">
<cfset application.unique_key = "ab6a5b91-5056-0100-3e460a970839dff2">

<cfset strData = structNew()>
<cfset JSONData = ToString( ToBinary( url.data ) )>
<cfset strData = DeserializeJSON(JSONData)>

<cfparam name="url.version" default="1">
<cfparam name="strData.CompanyIdentifier" default="">
<cfparam name="strData.EmployeeID" default="">
<cfparam name="strData.CourseID" default="">
<cfparam name="strData.FirstName" default="">
<cfparam name="strData.LastName" default="">
<cfparam name="strData.Signature" default="">
<cfparam name="strData.PersonalIdentifier" default="">
<cfparam name="strData.Roles" default="">
<cfparam name="strData.Location" default="">
<cfparam name="strData.Account" default="">
<cfparam name="companyroles" default="">

<cfparam name="strData.Email" default="">
<cfparam name="strData.Address" default="">
<cfparam name="strData.StateProv" default="">
<cfparam name="strData.Country" default="">
<cfparam name="strData.PostalCode" default="">
<cfparam name="strData.Phone" default="">
<cfparam name="strData.WorkPhone" default="">
<cfparam name="strData.CellPhone" default="">
<cfparam name="strData.Employer" default="">
<cfparam name="strData.StartDate" default="">
<cfparam name="strData.UnknownField" default="">
<cfparam name="strData.CustomDropDownField" default="">
<cfparam name="strData.CustomTextField" default="">

<cfif len(trim(strData.EmployeeID)) EQ 0 AND len(trim(strData.PersonalIdentifier)) NEQ 0>
	<cfset strData.EmployeeID = strData.PersonalIdentifier>
</cfif>
<cfset error = StructNew()>

<cfif len(trim(strData.CompanyIdentifier)) NEQ 0>
	<cfset companyObj = request.CompanyManager.GetCompanyByUniqueIdentifier(strData.CompanyIdentifier)>
	<cfif companyObj.getID() EQ 0>
		<cfset error["CompanyIdentifier"] = "CompanyIdentifier is invalid.">
	<cfelseif companyObj.getSSONodeID() EQ 0>
		<cfset error["CompanyIdentifier"] = "SSO Node is not defined for the Company.">
	</cfif>
<cfelse>
	<cfset error["CompanyIdentifier"] = "CompanyIdentifier is not provided.">
</cfif>
<cfif StructIsEmpty(error)>
	<cfif NOT (structKeyExists(url,"skipOldBrowserCheck") AND url.skipOldBrowserCheck EQ 1)>
		<cfset browserDetails = createObject("component", "#application.servicePath#.auth").detectBrowser()>
		<cfset ObjHomefw = createObject("component", "#application.servicePath#.home")>
		<cfif browserDetails.name EQ "IE" AND browserDetails.version LTE 11 
			AND ObjHomefw.unsupportedBrowserCompanyToggle(companyObj.getID()).fldNotificationForOldBrowsers EQ 1>
			<cfset urlToRedirect = URLEncodedFormat(CGI.HTTP_URL)>
			<cflocation url="/v1/index.cfm?action=home.unsupportedBrowser&redirect=#urlToRedirect#&companyId=#application.fwDummy.uEncrypt(companyObj.getID())#">
		</cfif>
	</cfif>
	<cfif len(trim(strData.EmployeeID)) NEQ 0>
		<cfset userObj = request.UserManager.GetUserByEmployeeID(strData.EmployeeID,companyObj.getID())>
		<cfif userObj.getID() NEQ 0 AND  userObj.getAccountState() EQ 'Pending'>
			<cfset userObj.setAccountState("Active")>
			<cfset userObj.Save()>
		</cfif>
		<cfif userObj.getID() NEQ 0 AND userObj.getAccountState() NEQ 'Active' AND strData.Account NEQ 'reactivate'>
			<cfset error["EmployeeID"] = "Employee is not active.">
		<cfelseif userObj.getID() NEQ 0 AND userObj.getCompany().getID() NEQ companyObj.getID()>
			<cfset error["EmployeeID"] = "Employee does not belong to the company.">
		</cfif>
	<cfelse>
		<cfif strData.EmployeeID EQ strData.PersonalIdentifier>
			<cfset error["PersonalIdentifier"] = "Personal Identifier is not provided.">
		<cfelse>
			<cfset error["EmployeeID"] = "EmployeeID is not provided.">
		</cfif>
	</cfif>
</cfif>
<cfset strData.PersonalIdentifier = strData.EmployeeID>

<cfif StructIsEmpty(error)>
	<cfif len(trim(strData.Signature)) EQ 0>
		<cfset error["Signature"] = 'Signature is empty.'>
	<cfelse>
		<cfset signatureString = '#application.unique_key#:#strData.CompanyIdentifier#:#strData.EmployeeID#'>
		<cfif len(trim(strData.CourseID))>
			<cfset signatureString = signatureString & ":#strData.CourseID#">
		</cfif>
		<cfif len(trim(strData.firstName)) AND len(trim(strData.lastname))>
			<cfset signatureString = signatureString & ":#strData.firstName#:#strData.lastname#">
		</cfif>
		<cfset NewSignature = Hash(signatureString)>
		<cfif NewSignature NEQ strData.Signature>
			<cfset error["Signature"] = 'Signature is invalid.'>
		</cfif>
	</cfif>
</cfif>
<cfif StructIsEmpty(error)>
	<cfset isNewUser = 0>
	
	<cfif strData.Account EQ 'deactivate'>
		<cfif userObj.getID() NEQ 0>
			<cfset user = userObj.getID()>
			<cfset dbDatasource = application.dsn>
			<cfset application.ManageUsers.DeactivateAUser(user=user, refreshindex=0, DeactivatedByMethod="ByDeactivateUserFromSSO_v1")>
			<cfoutput>
				<html><head></head>
				<body>
					<b>Employee #userObj.getFirstName()# #userObj.getLastName()# is deactivated in BIS Trainer</b>
				</body>
				</html>
			</cfoutput>
			<cfabort>
		<cfelse>
			<cfoutput>
				<html><head></head>
				<body>
					<b>Employee does not exist to deactive.</b>
				</body>
				</html>
			</cfoutput>
			<cfabort>
		</cfif>
	<cfelseif strData.Account EQ 'reactivate'>
		<cfif userObj.getID() NEQ 0>
			<cfset user = userObj.getID()>
			<cfset dbDatasource = application.dsn>
			<cfset application.ManageUsers.ReactiavteAUser(user = user, refreshindex=0)>
			<cfoutput>
				<html><head></head>
				<body>
					<b>User #userObj.getFirstName()# #userObj.getLastName()# is reactivated in BIS Trainer</b>
				</body>
				</html>
			</cfoutput>
			<cfabort>
		<cfelse>
			<cfoutput>
				<html><head></head>
				<body>
					<b>Employee does not exists to reactive.</b>
				</body>
				</html>
			</cfoutput>
			<cfabort>
		</cfif>
	</cfif>
	<cfif userObj.getID() EQ 0>
		<cfif Not len(trim(strData.firstName)) OR Not len(trim(strData.lastname))>
			<cfcookie name="PrivateSiteCompanyNumber" value="#companyObj.getID()#" />
			<cfset session.allowAddLearnerForm = 1>
			<cflocation url="index.cfm?action=home.AddLearnerForm&data=#url.data#">
		<cfelse>
			<cfif len(trim(strData.Location))>
				<cfset StrEscUtils = createObject("java", "org.apache.commons.lang.StringEscapeUtils") />
				<cfset strData.Location = StrEscUtils.unescapeHTML(strData.Location) />
				<cfquery name="getLocation" datasource="#application.dsn#">
					SELECT
						fldUserCompanyGroup_ID
					FROM
						tblUserCompanyGroups
					WHERE
						fldDescription LIKE <cfqueryparam value="#trim(strData.Location)#" cfsqltype="cf_sql_varchar" />
						AND fldCompanyID = <cfqueryparam value="#companyObj.getID()#" cfsqltype="cf_sql_integer" />
				</cfquery>
				<cfif getLocation.recordCount>
					<cfset node = request.CompanyNodeManager.GetCompanyNodeByID(getLocation.fldUserCompanyGroup_ID)>
				<cfelse>
					<cfset node = request.CompanyNodeManager.GetCompanyNodeByID(companyObj.getSSONodeID())>
				</cfif>
			<cfelse>
				<cfset node = request.CompanyNodeManager.GetCompanyNodeByID(companyObj.getSSONodeID())>
			</cfif>

			<cfif len(trim(strData.Roles))>
				<cfquery name="getTrainingrole" datasource="#application.dsn#">
					SELECT
						fldTrainingRole_ID
					FROM
						tbltrainingrole
					WHERE
						fldRole IN(<cfqueryparam value="#trim(strData.Roles)#" cfsqltype="cf_sql_varchar" list="yes"/>)
						AND fldCompanyID = <cfqueryparam value="#companyObj.getID()#" cfsqltype="cf_sql_integer" />
				</cfquery>
				<cfif getTrainingrole.recordCount>
					<cfset companyroles = valuelist(getTrainingrole.fldTrainingRole_ID)>
				</cfif>
			</cfif>

			<cfif len(trim(strData.Email))>
				<cfquery name="qGetDuplicateEmail" datasource="#application.dsn#">
					SELECT
						*
					FROM
						tblUser
					WHERE
						fldEmail1 LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(strData.Email)#">
						AND fldAccountActive IN (1,2)
				</cfquery>
				<cfif qGetDuplicateEmail.recordCount>
					<cfset strData.Email = ''>
				</cfif>
			</cfif>

			<cfif len(trim(strData.CustomDropDownField))>
				<cfquery name="qGetDropDownOptionID" datasource="#application.dsn#">
					SELECT
						*
					FROM
						tblcustomfieldoptions
					WHERE
						fldCompanyID = <cfqueryparam cfsqltype="cf_sql_integer" value="#companyObj.getID()#">
						AND fldActive = 1
						AND fldOptionText LIKE <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(strData.CustomDropDownField)#">
				</cfquery>
				<cfif qGetDropDownOptionID.recordCount>
					<cfset strData.CustomDropDownFieldID = qGetDropDownOptionID.fldCustomFieldOptions_ID>
				</cfif>
			</cfif>

			<cfif len(trim(strData.Country))>
				<cfquery name="getfldCountry" datasource="#application.dsn#">
					SELECT
						fldCountry_ID AS country_ID
					FROM
						tblcountry
					WHERE
						fldName = <cfqueryparam value="#trim(strData.Country)#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif getfldCountry.recordCount>
					<cfset strData.CountryID = getfldCountry.country_ID>
				</cfif>
			</cfif>

			<cfif len(trim(strData.StateProv))>
				<cfquery name="getfldStateID" datasource="#application.dsn#">
					SELECT
						fldStateProvince_ID AS stprv_ID
					FROM
						tblstateprovince
					WHERE
						fldName = <cfqueryparam value="#trim(strData.StateProv)#" cfsqltype="cf_sql_varchar">
						OR fldCode = <cfqueryparam value="#trim(strData.StateProv)#" cfsqltype="cf_sql_varchar">
				</cfquery>
				<cfif getfldStateID.recordCount>
					<cfset strData.StateProvID = getfldStateID.stprv_ID>
				</cfif>
			</cfif>

			<cfscript>
				newUserObj = request.UserManager.NewUser();
				creator = 0;
				newUserObj.setLanguagePref(1);
				newUserObj.setFirstName(strData.FirstName);
				newUserObj.setLastName(strData.LastName);
				newUserObj.setIDNumber(strData.EmployeeID);
				if(len(companyroles))
					newUserObj.setTrainingRoleID(companyroles);
				newUserObj.setEmployer(trim(strData.Employer));
				if(isDate(trim(strData.StartDate)))
					newUserObj.setStartDate(trim(strData.StartDate));
				newUserObj.setAddress1(trim(strData.Address));
				newUserObj.setZipPostalCode(trim(strData.PostalCode));
				newUserObj.setPhone1(trim(strData.WorkPhone));
				newUserObj.setPhone2(trim(strData.CellPhone));
				newUserObj.setPhone3(trim(strData.Phone));
				newUserObj.setSpecialField(trim(strData.CustomTextField));
				newUserObj.setEmail1(trim(strData.Email));
				if(structKeyExists(strData, 'CustomDropDownFieldID'))
				{
					newUserObj.setCustomField(trim(strData.CustomDropDownFieldID));
					newUserObj.setCustomFieldText(trim(strData.CustomDropDownField));
				}
				if(structKeyExists(strData, 'StateProvID') AND structKeyExists(strData, 'CountryID'))
				{
					newUserObj.setStateID(strData.StateProvID);
					newUserObj.setCountry(strData.CountryID);
				}
				else
				{
					newUserObj.setStateID(77);
					newUserObj.setCountry(3);
				}

				node.AddUser(User=newUserObj, Creator=creator, IsActive = 1, cadmin = 1, Roles = [3], SSOUser = 1);

				newUserObj = request.UserManager.GetUser(newUserObj.getID());
				userObj = newUserObj;
				isNewUser = 1;
			</cfscript>
		</cfif>
	</cfif>
	<cfif len(trim(strData.CourseID))>
		<cftry>
			<cfset courseObj = request.courseManager.GetCourseByID(val(strData.CourseID))>
			<cfcatch><cfset error["CourseID"] = 'CourseID is invalid. [#cfcatch.Message#]'></cfcatch>
		</cftry>
		<cfif StructIsEmpty(error)>
			<cfset courseList = ''>
			<cfif isNewUser EQ 0>
				<cfset Courses = userObj.GetCoursesNew()>
				<cfif ArrayLen(Courses.notstarted) GT 0>
					<cfset i = 0>
					<cfloop array="#Courses.notstarted#" index="course">
						<cfset courseList = ListAppend(courseList,course.courseid)>
					</cfloop>
				</cfif>
				<cfif ArrayLen(Courses.inprogress) GT 0>
					<cfset i = 0>
					<cfloop array="#Courses.inprogress#" index="course">
						<cfset courseList = ListAppend(courseList,course.courseid)>
					</cfloop>
				</cfif>
				<cfif ArrayLen(Courses.Repeatable) GT 0>
					<cfset i = 0>
					<cfloop array="#Courses.Repeatable#" index="course">
						<cfset courseList = ListAppend(courseList,course.courseid)>
					</cfloop>
				</cfif>
				<cfif ArrayLen(Courses.completed) GT 0>
					<cfset i = 0>
					<cfloop array="#Courses.completed#" index="course">
						<cfif NOT structKeyExists(course, 'dateexpiry')
							OR course.state NEQ 'Completed'
							OR NOT isDate(course.dateexpiry)
							OR (isDate(course.dateexpiry) AND course.dateexpiry GT now())>
							<cfif course.Passed EQ 1>
								<cfset courseList = ListAppend(courseList,course.courseid)>
							</cfif>
						</cfif>
					</cfloop>
				</cfif>
			</cfif>
			<cfif courseObj.getActive()>
				<cfif Not ListFind(courseList,courseObj.getID())>
					<cfset permissionID = request.PermissionManager.GrantPermissionToUserBySSO(
							CourseID = 	courseObj.getID(),
							User = userObj.getID(),
							GrantingUser = 0,
							PassingMarks = val(courseObj.getPassMarks()),
							NumberOfRepeats = val(courseObj.getECNumberOfRepeats())
						)>
				</cfif>
				<cfset userObj.initSession(userID = userObj.getID(), isSSOUser = 1)>
				<cfset session.loginUserTemporaryPassword = 0>
				<cflocation url="/v1/index.cfm?action=learner.home" addtoken="false">
			<cfelse>
				<cfset error["CourseID"] = 'CourseID is not Active.'>
			</cfif>
		</cfif>
	<cfelse>
		<cfset userObj.initSession(userID = userObj.getID(), isSSOUser = 1)>
		<cfset session.loginUserTemporaryPassword = 0>
		<cflocation url="/v1/index.cfm?action=learner.home" addtoken="false">
	</cfif>
</cfif>
<cfcatch>
	<cfset error["Exception"] = cfcatch>
</cfcatch>
</cftry>
<cfif Not StructIsEmpty(error)>
	<cfmail from="sso.error@bistrainer.com" to="errors@bistraining.ca,archana@techversantinfotech.com" subject="Error at SSO #getTickCount()#" type="html">
		Data Passed to SSO:<br />
		<cfdump var="#strData#"><br /><br />
		Exception:<br />
		<cfdump var="#error#">
	</cfmail>
	<cfoutput>
	<html><head></head>
	<body>
	<b>Error occurred while processing your request.</b>
	</body>
	</html>
	</cfoutput>
</cfif>

