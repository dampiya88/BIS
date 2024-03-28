<cfset application.util.recordTemplatePathUsage(template=getCurrentTemplatePath())>
<cfoutput>
	<cffile action="read" file="E:/websites/bistrainer.ca/COPSampleSAMLResponseBase64Encoded.txt"  variable ='SAMLRequestFromFile'>
	<cfparam name="url.data" default="#SAMLRequestFromFile#">
	<cfparam name="session.languagename" default="english">
	<cfparam name="variables.xmlResponse" default="">
	<cfif StructKeyExists(form,"data") AND len(trim(form.data))>
		<cfset SAMLRequest = form.data>
	<cfelseif StructKeyExists(url,"data") AND len(trim(url.data))>
		<cfset SAMLRequest = url.data>
	</cfif>
	<cfset currentDateTime = now()>
	<cfset certSwitchTime = "{ts '2023-01-11 19:00:00'}">
	<cfset isValidsignature = "NO">
	<cfset strData = structnew()>
	<cftry>
		<cfscript>
			/* Get the public Key from the certificate file provided */
			FStream=CreateObject("Java", "java.io.FileInputStream");
			File=CreateObject("Java", "java.io.File");
			PublicKey=CreateObject("Java", "java.security.PublicKey");
			X509Certificate=CreateObject("Java", "java.security.cert.X509Certificate");
			CertificateFactory=CreateObject("Java", "java.security.cert.CertificateFactory");
			/* Temporary to switch certificate on 11th January 2023 and 7pm MST to new certificate */
			if(Datecompare(currentDateTime,certSwitchTime) GT 0){
				fin = FStream.init("E:/websites/bistrainer.ca/COPPublicKey_Expires_2024_01_25.cer");
			} else {
				fin = FStream.init("E:/websites/bistrainer.ca/COPPublicKey_Expires_2023_01_25.cer");
			}
			f = CertificateFactory.getInstance("X.509");
			certificate = f.generateCertificate(fin);
			pk = certificate.getPublicKey();

			/*Decode the SAML response and get the key from response*/
			xmlResponse=CharsetEncode(BinaryDecode(SAMLRequest,"Base64"),"utf-8");
			docElement= XmlParse(variables.xmlResponse).getDocumentElement();
			docElement.setIdAttribute("ID",true);
			SignatureConstants=CreateObject("Java", "org.apache.xml.security.utils.Constants");
			SignatureSpecNS=SignatureConstants.SignatureSpecNS;
			xmlSignatureClass = CreateObject("Java","org.apache.xml.security.signature.XMLSignature");
			Init = CreateObject("Java", "org.apache.xml.security.Init").Init().init();
			xmlSignature = xmlSignatureClass.init(docElement.getElementsByTagNameNS(SignatureSpecNS,"Signature").item(0),"");
			keyInfo = xmlSignature.getKeyInfo();
			/*X509CertificateResolverCN = "org.apache.xml.security.keys.keyresolver.implementations.X509CertificateResolver";
			keyResolver = CreateObject("Java", X509CertificateResolverCN).init();
			keyInfo.registerInternalKeyResolver(keyResolver);
			x509cert = keyInfo.getX509Certificate();
			publicKey = x509cert.getPublicKey();*/
			/* compare the key from the certificate with the SAML response*/
			isValidsignature = xmlSignature.checkSignatureValue(pk);
		</cfscript>
		<cfset attributesarray = XmlSearch(variables.xmlResponse,'samlp:Response/saml:Assertion/saml:AttributeStatement/saml:Attribute')>
		<cfloop array="#attributesarray#" index="attr">
			<cfswitch expression="#attr.XmlAttributes.Name#">
				<cfcase value="CompanyIdentifier">
					<cfset strData.CompanyIdentifier = attr.XmlChildren[1].XmlText>
				</cfcase>
				<cfcase value="EmployeeID">
					<cfset strData.EmployeeID = attr.XmlChildren[1].XmlText>
				</cfcase>
				<cfcase value="CourseID">
					<cfset strData.ExternalCourseID = attr.XmlChildren[1].XmlText>
				</cfcase>
				<cfcase value="FirstName">
					<cfset strData.FirstName = attr.XmlChildren[1].XmlText>
				</cfcase>
				<cfcase value="LastName">
					<cfset strData.LastName = attr.XmlChildren[1].XmlText>
				</cfcase>
				<cfcase value="CostCenter">
					<cfset strData.CostCenter = attr.XmlChildren[1].XmlText>
				</cfcase>
			</cfswitch>
		</cfloop>
		<cfif isValidsignature>
			<cftry>
				<cfparam name="strData.CompanyIdentifier" default="">
				<cfparam name="strData.EmployeeID" default="">
				<cfparam name="strData.CourseID" default="">
				<cfparam name="strData.FirstName" default="">
				<cfparam name="strData.LastName" default="">
				<cfparam name="strData.CostCenter" default="">

				<cfmail from="saml@bistrainer.com" subject="Conocophillips SAML Response" to="rejith@bistraining.ca" type="html">
					<cfdump var="#strData#">
					<cfdump var="#url#">
					<cfdump var="#form#">
					<cfdump var="#cgi#">
				</cfmail>

				<cfset error = StructNew()>
				<cfquery name="getCourseID" datasource="#application.dsn#">
					SELECT
						ECID.fldSysCourseID
					FROM
						tblExternalCourseIDs ECID
						INNER JOIN tblUserCompany UC ON ECID.fldCompanyID = UC.fldUserCompany_ID
					WHERE
						ECID.fldExternalID =  <cfqueryparam value="#strData.ExternalCourseID#" cfsqltype="cf_sql_varchar" />
						AND UC.fldCompanyUniqueIdentifier = <cfqueryparam value="#strData.CompanyIdentifier#" cfsqltype="cf_sql_varchar" />
						AND ECID.fldActive = 1
				</cfquery>
				<cfif getCourseID.recordCount>
					<cfset strData.CourseID = getCourseID.fldSysCourseID>
				</cfif>
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
					<!---
          <cfif NOT (structKeyExists(url,"skipOldBrowserCheck") AND url.skipOldBrowserCheck EQ 1)>
						<cfset browserDetails = createObject("component", "#application.servicePath#.auth").detectBrowser()>
						<cfset ObjHomefw = createObject("component", "#application.servicePath#.home")>
						<cfif browserDetails.name EQ "IE" AND browserDetails.version LTE 11 
							AND ObjHomefw.unsupportedBrowserCompanyToggle(companyObj.getID()).fldNotificationForOldBrowsers EQ 1>
							<cfset urlToRedirect = URLEncodedFormat(CGI.HTTP_URL)>
							<cflocation url="/v1/index.cfm?action=home.unsupportedBrowser&redirect=#urlToRedirect#&companyId=#application.fwDummy.uEncrypt(companyObj.getID())#">
						</cfif>
					</cfif>
          --->
					<cfif len(trim(strData.EmployeeID)) NEQ 0>
						<cfset userObj = request.UserManager.GetUserByEmployeeID(strData.EmployeeID,companyObj.getID())>
						<cfif userObj.getID() NEQ 0 AND userObj.getAccountState() EQ 'Pending'>
							<cfset userObj.setAccountState("Active")>
							<cfset userObj.Save()>
						<cfelseif userObj.getID() NEQ 0 AND userObj.getAccountState() NEQ 'Active'>
							<cfset error["EmployeeID"] = "Employee is not active.">
						<cfelseif userObj.getID() NEQ 0 AND userObj.getCompany().getID() NEQ companyObj.getID()>
							<cfset error["EmployeeID"] = "Employee does not belong to the company.">
						</cfif>
					<cfelse>
						<cfif url.version NEQ 1.1>
							<cfset error["EmployeeID"] = "EmployeeID is not provided.">
						<cfelse>
							<cfset error["PersonalIdentifier"] = "Personal Identifier is not provided.">
						</cfif>
					</cfif>
				</cfif>
				<cfif StructIsEmpty(error)>
					<cfif len(trim(strData.FirstName)) EQ 0>
						<cfset error["FirstName"] = "FirstName is not provided.">
					</cfif>
					<cfif len(trim(strData.LastName)) EQ 0>
						<cfset error["LastName"] = "LastName is not provided.">
					</cfif>
				</cfif>
				<cfif StructIsEmpty(error)>
					<cfset isNewUser = 0>
					<cfif userObj.getID() EQ 0>
						<cfscript>
							node = request.CompanyNodeManager.GetCompanyNodeByID(companyObj.getSSONodeID());
							newUserObj = request.UserManager.NewUser();
							creator = 0;

							newUserObj.setLanguagePref(1);
							newUserObj.setFirstName(strData.FirstName);
							newUserObj.setLastName(strData.LastName);
							newUserObj.setIDNumber(strData.EmployeeID);
							newUserObj.setStateID(77);
							newUserObj.setCountry(3);
							newUserObj.setSpecialField(strData.CostCenter);
							node.AddUser(User=newUserObj, Creator=creator, IsActive = 1, cadmin = 1, SSOUser = 1);

							newUserObj = request.UserManager.GetUser(newUserObj.getID());
							userObj = newUserObj;
							isNewUser = 1;
						</cfscript>
					<cfelse>
						<cfquery name="updateCostCenter" datasource="#application.dsn#">
							UPDATE
								tblUser
							SET
								fldspecialField = <cfqueryparam value="#trim(strData.CostCenter)#" cfsqltype="cf_sql_varchar" null="#yesnoformat(NOT len(strData.CostCenter))#">
							WHERE
								fldUser_ID = <cfqueryparam value="#userObj.getID()#" cfsqltype="cf_sql_integer">
						</cfquery>
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
											OR (
												isDate(course.dateexpiry)
												AND course.dateexpiry GT DateAdd('d', course.aboutToExpireDays, now())
											)>
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
								<cflocation url="/v1/index.cfm?action=home.launchCourse&id=#courseObj.getID()#" addtoken="false">
								<cfabort>
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
		<cfelse>
			<cfset error["Signature"] = 'Signature is invalid.'>
		</cfif>
	<cfcatch>
		<cfset error["XMLResponse"] = "Invalid SAML request.">
	</cfcatch>
	</cftry>
	<cfif Not StructIsEmpty(error)>
		<cfmail from="sso.error@bistrainer.com" to="#application.errormailaddreses#" subject="Error at SSO #getTickCount()#" type="html">
				Data Passed to SSO:<br />
					<cfdump var="#strData#"><br /><br />
					Exception:<br />
			<cfdump var="#error#">
		</cfmail>
		<cfdump var="#error#">
	</cfif>
</cfoutput>