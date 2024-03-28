<cfcomponent>
	<cffunction name="checkVoucherCode"
				access="remote"
				returntype="any"
				returnformat="plain"
				output="false"
				description="save notes for user.">

		<cfargument name="CourseVoucherCode" type="numeric" required="false" default="0" />

		<cfset var local = structNew()>
		<cfset local.isCourseDecommissioned = "">
		<cfset application.fwUtilService.ensureSessionLanguage()>

		<cfset local.result = request.CourseVoucherManager.GetCourseVoucherByCode(arguments.CourseVoucherCode) />
		<cfif local.result>
			<cfset local.IsAssessment = request.Competency.CheckAssessment(local.result)>

			<cfif local.IsAssessment EQ 1>
				<cfset local.voucherDetail = request.Competency.GetContentVoucherByID(local.result)>
				<cfset local.remainingInvites = local.voucherDetail.fldMaxInvites - local.voucherDetail.fldUsedInvites>
				<cfset local.IsValidCode = local.voucherDetail.fldValid>
				<cfset local.Expiry = local.voucherDetail.fldExpiryDate>
				<cfset local.LanguageID = local.voucherDetail.fldLanguage>
			<cfelse>
				<cfset local.voucherDetail = request.CourseVoucherManager.GetCourseVoucherByID(local.result)>
				<cfif local.voucherDetail.getBundleID() GT 0>
					<cfset local.objbundle = createObject("component", "#application.servicePath#.bundle")/>
					<cfset local.bundleDetails = local.objbundle.GetBundleDetailsSpecific(local.voucherDetail.getBundleID())>
					<cfset local.isCourseDecommissioned = local.bundleDetails.fldstatus>
				<cfelse>
					<cfset local.isCourseDecommissioned = local.voucherDetail.getCourse().getStatus()>
				</cfif>
				<cfset local.LanguageID = local.voucherDetail.getCourse().getLanguagePref()>
				<cfset local.IsValidCode = local.voucherDetail.getValid()>
				<cfset local.Expiry = local.voucherDetail.getExpiryDate()>
				<cfset local.remainingInvites = local.voucherDetail.getMaxInvites() - local.voucherDetail.getUsedInvites()>
			</cfif>
			<cfquery name="local.getLangName" datasource="#application.dsn#">
				SELECT fldLanguage FROM tblsyslanguage
				WHERE fldSysLanguage_ID = <cfqueryparam value="#local.LanguageID#" cfsqltype="cf_sql_integer">
			</cfquery>
			<cfset session.Language = local.LanguageID>
			<cfset session.voucherLanguage = 1>
			<cfset session.LanguageName = local.getLangName.fldLanguage>
			<cfif local.isCourseDecommissioned EQ "decommissioned" AND local.remainingInvites LTE 0>
				<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblCourseDecommissionSentence">
				<cfreturn Evaluate(local.varname)>
			<cfelseif local.remainingInvites LTE 0>
				<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblVoucherCodeExhausted" >
				<cfreturn Evaluate(local.varname)>
			<cfelseif local.IsValidCode NEQ 1>
				<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblInvalidVoucherCode" >
				<cfreturn Evaluate(local.varname)>
			<cfelseif DateCompare(local.Expiry, Now(), 'd') LT 0> 
				<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblVoucherCodeExpired" >
				<cfreturn Evaluate(local.varname)>
			<cfelse>
				<cfset session.VoucherCode = arguments.CourseVoucherCode>
				<cfreturn 'valid,#local.LanguageID#,#local.getLangName.fldLanguage#,#arguments.CourseVoucherCode#'>
			</cfif>
			<cfreturn local.Expiry>
		<cfelse>
			<cfif left(arguments.CourseVoucherCode,2) EQ '10'>
				<cfquery name="local.qGetUser" datasource="#application.dsn#">
					SELECT U.fldFirstName,U.fldLastName,U.fldUserName FROM tbluser U
					INNER JOIN tbluserinvitation UI ON U.fldUser_ID = UI.fldUserID
					WHERE UI.fldInviteCode = <cfqueryparam value="#arguments.CourseVoucherCode#" cfsqltype="cf_sql_bigint">
				</cfquery>
				<cfif local.qGetUser.recordCount GT 0>
					<cfset local.varnameText = "application.stLang.#session.LanguageName#.home.loginForm.lblExistInvitationText" >
					<cfset local.varname = replacenocase(Evaluate(local.varnameText), '{First Name}', local.qGetUser.fldFirstName, "all")>
					<cfset local.varname = replacenocase(local.varname, '{Last Name}', local.qGetUser.fldLastName, "all")>
					<cfset local.varname = replacenocase(local.varname, '{User Name}', local.qGetUser.fldUserName, "all")>
				<cfelse>
					<cfset local.varname = "application.stLang.#session.LanguageName#.home.loginForm.lblLoginFbInvalidInvitation" >
					<cfset local.varname = Evaluate(local.varname) />
				</cfif>
			<cfelseif left(arguments.CourseVoucherCode,1) EQ '2'>
				<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblInvalidVoucherCode" >
				<cfset local.varname = Evaluate(local.varname) />
			<cfelse>
				<cfset local.varname = "application.stLang.#session.LanguageName#.home.loginForm.lblInvalidActivationCode" >
				<cfset local.varname = Evaluate(local.varname) />
			</cfif>
			<cfreturn local.varname />
		</cfif>

	</cffunction>

	<cffunction name="checkClassroomVoucherCode"
				access="remote"
				returntype="any"
				returnformat="plain"
				output="false"
				description="check classroom vouchercode is valid">

		<cfargument name="CourseVoucherCode" type="numeric" required="false" default="0" />

		<cfset var local = structNew()>
		<cfset application.fwUtilService.ensureSessionLanguage()>

		<cfquery name="local.result" datasource="#application.dsn#">
			SELECT * FROM tblclassroomcoursevoucher WHERE fldVoucherCode = <cfqueryparam cfsqltype="cf_sql_bigint" value="#arguments.CourseVoucherCode#">
		</cfquery>
		<cfset local.LanguageID = 1>
		<cfquery name="local.getLangName" datasource="#application.dsn#">
			SELECT fldLanguage FROM tblsyslanguage
			WHERE fldSysLanguage_ID = <cfqueryparam value="#local.LanguageID#" cfsqltype="cf_sql_integer">
		</cfquery>
		<cfset session.Language = local.LanguageID>
		<cfset session.LanguageName = local.getLangName.fldLanguage>

		<cfif local.result.recordCount>
			<cfif local.result.fldValid NEQ 1>
				<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblInvalidVoucherCode" >
				<cfreturn Evaluate(local.varname)>
			<cfelseif DateCompare(local.result.fldExpiryDate, Now(), 'd') LT 0> 
				<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblVoucherCodeExpired" >
				<cfreturn Evaluate(local.varname)>
			<cfelseif (local.result.fldMaxInvites - local.result.fldUsedInvites) LTE 0>
				<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblVoucherCodeExhausted" >
				<cfreturn Evaluate(local.varname)>
			<cfelse>
				<cfset session.VoucherCode = arguments.CourseVoucherCode>
				<cfreturn 'valid,#local.LanguageID#,#local.getLangName.fldLanguage#,#arguments.CourseVoucherCode#'>
			</cfif>
		<cfelse>
			<cfreturn 'invalid'>
		</cfif>

	</cffunction>

	<cffunction name="checkInvitationCode"
				access="remote"
				returntype="any"
				returnformat="json"
				output="false"
				description="">

		<cfargument name="InvitationCode" type="numeric" required="true" />

		<cfset var local = structNew()>
		<cfset local.result = structNew()>
		<cfset local.result.status = 'Invalid'>
		<cfset local.result.invitationtype = 0>
		<cfset url.code = arguments.InvitationCode>
		<cfinclude template="usr/qryUserInvitationStatus.cfm">
		<cfif isDefined("qryUserInvitationStatus.recordcount")
				AND
				qryUserInvitationStatus.fldValid EQ 1
				AND
				(
					qryUserInvitationStatus.fldInvitationType EQ 1
					OR
					(
						qryUserInvitationStatus.fldInvitationType EQ 2
						AND
						(
							(qryUserInvitationStatus.fldUnlimitedInvites EQ 0 AND qryUserInvitationStatus.fldUsedInvites LT qryUserInvitationStatus.fldMaxInvites)
							OR
							qryUserInvitationStatus.fldUnlimitedInvites EQ 1
						)
					)
				)>
			<cfif qryUserInvitationStatus.fldInvitationType EQ 1>
				<cfset local.result.invitationtype = 1>
			</cfif>
			<cfset local.result.status = 'valid'>
		</cfif>
		<cfreturn local.result>
	</cffunction>

	<cffunction name="RedeemVoucherCode" access="public" returntype="any" returnformat="plain" output="false" description="save notes for user.">
		<cfargument name="CourseVoucherCode" type="numeric" required="false" default="0" />
		<cfargument name = "userid" type = "numeric" required = "0" default="0"/>
		<cfargument name = "frompurchase" type = "numeric" required = "0" default="0"/>
		<cfargument name="refreshindex" type="boolean" required="false" default="1">
		<cfreturn 'failed'>
	</cffunction>

	<cffunction name="RedeemClassroomVoucherCode" access="public" returntype="any" returnformat="plain" output="false" description="">
		<cfargument name="CourseVoucherCode" type="numeric" required="true">
		<cfargument name = "userid" type = "numeric" required = "0" default="#session.loginuserid#">
		<cfargument name="refreshindex" type="boolean" required="false" default="1">
		<cfargument name = "preventMultiReg" type = "numeric" required = "false" default="0">
		<cfargument name="returnStruct" required="false" type="numeric" default="0">

		<cfset application.fwUtilService.ensureSessionLanguage()>
		<cfset var local = structNew()>
		<cfset local.msgvar = "">
		<cfset local.multiRegEvents = []>

		<cfquery name="local.voucherDetail" datasource="#application.dsn#">
			SELECT
				CCV.*,
				TCD.fldPrerequisitesFlag,
				TCD.fldBlockParticipantRegistration,
				TCD.fldTrainingCourseID
			FROM
				tblclassroomcoursevoucher CCV
				INNER JOIN tblclassroomevents CE ON CE.fldClassroomEvents_ID = CCV.fldEventID
				INNER JOIN tbltrainingcoursedetails TCD ON TCD.fldTrainingCourseID = CE.fldTrainingCourseID
			WHERE
				fldVoucherCode = <cfqueryparam cfsqltype="CF_SQL_BIGINT" value="#arguments.CourseVoucherCode#">
		</cfquery>
		<cfif local.voucherDetail.recordCount>
			<cfset local.remainingInvites = local.voucherDetail.fldMaxInvites - local.voucherDetail.fldUsedInvites>
			<cfset local.isUserMetRequirements = true>
			<cfif val(local.voucherDetail.fldPrerequisitesFlag) && val(local.voucherDetail.fldBlockParticipantRegistration)>
				<cfset local.isUserMetRequirements = request.classroomEvent.checkPrerequisites(
					ClassroomEventID = local.voucherDetail.fldEventID,
					ClassroomCourseID = local.voucherDetail.fldTrainingCourseID,
					userId = arguments.userid
				).isUserMetRequirements/>
			</cfif>
			<cfif local.voucherDetail.fldValid NEQ 1>
				<cfset local.msgvar = evaluate("application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblInvalidVoucherCode")>
			<cfelseif DateCompare(local.voucherDetail.fldExpiryDate, Now(), 'd') LT 0> 
				<cfset local.msgvar = evaluate("application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblVoucherCodeExpired")>
			<cfelseif local.remainingInvites LTE 0>
				<cfset local.msgvar = evaluate("application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblVoucherCodeExhausted")>
			<cfelseif getClassroomVoucherUsedCount(arguments.userid, local.voucherDetail.fldClassroomCourseVoucher_ID) GT 0>
				<cfset local.msgvar = evaluate("application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblVoucherCodeAlreadyAdded")>
			<cfelseif request.classroomEvent.checkEventaParticipantDuplication(local.voucherDetail.fldEventID, arguments.userid) GT 0>
				<cfset local.msgvar= evaluate("application.stLang.#session.LanguageName#.Classroom.classroomevent.lblDuplicateParticipantSentence")>
			<cfelseif local.isUserMetRequirements EQ false>
				<cfset local.msgvar= evaluate("application.stLang.#session.LanguageName#.Classroom.classroomevent.lblPrerequisiteNotSatisfiedSentence")>
			<cfelse>
				<cfset local.isEventSharedWithSubCompany = 0>
				<cfset var overlappedCourse = request.classroomEvent.CheckOverlappedCourses(EventID = local.voucherDetail.fldEventID, UserID = arguments.userid)>
				<cfif NOT overlappedCourse>
					<cfif arguments.preventMultiReg EQ 3><!---if from register me button (store)--->
						<cfset local.multiRegEvents = application.classroomEvent.checkMultiRegistration(userid = arguments.userid, vouchercode = arguments.CourseVoucherCode)>
						<cfset local.msgvar = arrayLen(local.multiRegEvents) ? 'multiReg' : ''>
					</cfif>
					<cfif NOT arrayLen(local.multiRegEvents)>
						<cfset local.userid = arguments.userid>
						<cfset local.userCompanyID = application.usermanager.getUserBasicInfo(arguments.userid).fldUserCompanyID>
						<cfif local.userCompanyID NEQ local.voucherDetail.fldCompanyID>
							<cfset local.ghostuserid = getGhostAccountForAUser(userid=arguments.userid, companyid = local.voucherDetail.fldCompanyID)>
							<cfif local.ghostuserid>
								<cfset local.userid = local.ghostuserid>
							</cfif>
						</cfif>
						<cfquery name="local.qryGetEventCompanyID" datasource="#application.dsn#">
							SELECT
								fldCompanyID,
								IFNULL(fldCommunityCalendarCompanyID, 0) AS fldCommunityCalendarCompanyID
							FROM
								tblclassroomevents
							WHERE
								fldClassroomEvents_ID = <cfqueryparam value="#local.voucherDetail.fldEventID#" cfsqltype="cf_sql_integer">
						</cfquery>
						<!--- Checking wheather parent company has shared event with sub company ---->
						<cfif local.voucherDetail.fldCompanyID NEQ local.qryGetEventCompanyID.fldCompanyID>
							<cfquery name="local.checkEventSharedToSubCompany" datasource="#application.dsn#">
								SELECT
									CC.fldParentcompanyId
								FROM
									tblusercompany CC
									INNER JOIN tblusercompanydetails UCD ON UCD.fldUserCompanyID = CC.fldParentcompanyId
								WHERE
									CC.fldParentcompanyId IS NOT NULL
									AND UCD.fldUserCompanyID = <cfqueryparam value="#local.qryGetEventCompanyID.fldCompanyID#" cfsqltype="integer">
									AND CC.fldUserCompany_ID = <cfqueryparam value="#local.voucherDetail.fldCompanyID#" cfsqltype="integer">
									AND UCD.fldSharePublicEventToSubPortal = 1
							</cfquery>
							<cfif local.checkEventSharedToSubCompany.recordCount>
								<cfset local.isEventSharedWithSubCompany = 1>
							</cfif>
						</cfif>
						<cfif local.voucherDetail.fldCompanyID NEQ local.qryGetEventCompanyID.fldCompanyID AND local.userCompanyID NEQ local.qryGetEventCompanyID.fldCommunityCalendarCompanyID AND local.isEventSharedWithSubCompany NEQ 1>
							<cfset local.ghostuserid = getGhostAccountForAUser(userid=arguments.userid, companyid = local.qryGetEventCompanyID.fldCompanyID)>
							<cfif local.ghostuserid>
								<cfset local.userid = local.ghostuserid>
							<cfelse>
								<cfset local.userid = application.Util.createNetworkghostAccount(userid=arguments.userid, EventCompanyID=local.qryGetEventCompanyID.fldCompanyID, refreshindex=arguments.refreshindex)>
							</cfif>
						</cfif>
						<cftry>
							<cfset local.registrations = {}>
							<cfset local.registrations['eventId'] = local.voucherDetail.fldEventID>
							<cfset local.registrations['UserID'] = local.userid>
							<cfset local.registrations['NewVCode'] = local.voucherDetail.fldClassroomCourseVoucher_ID>
							<cfset local.registrations['preventMultiReg'] = arguments.preventMultiReg>
							<cfset local.result = request.classroomEvent.addManualRegistrationEvent(registrations = local.registrations)>
							<cfset local.msgvar = 'added'>
							<cfcatch>
								<cfset application.MailService.customErrorEmailHandler(subject = "Error at #cgi.http_host# - Error when adding participant", toAddresses = application.errormailaddreses, cfcatch = cfcatch, arguments = arguments, session = session)>
								<cfset local.msgvar = 'Participant not added, please try again.'>
							</cfcatch>
						</cftry>
					</cfif>
				<cfelse>
					<cfset local.msgvar = evaluate("application.stLang.#session.LanguageName#.Classroom.classroomevent.lblOverlappingCourseErrorSentence")>
				</cfif>
			</cfif>
		<cfelse>
			<cfset local.msgvar = evaluate("application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblInvalidVoucherCode") >
		</cfif>
		<cfif arguments.returnStruct EQ 1>
			<cfset local.result = {}>
			<cfset local.result['redeemstatus'] = local.msgvar>
			<cfset local.result['multiRegEvents'] = local.multiRegEvents>
			<cfreturn local.result>
		<cfelse>
			<cfreturn local.msgvar>
		</cfif>
	</cffunction>

	<cffunction name="RedeemVoucherCodePublic"
				access="public"
				returntype="any"
				output="false"
				description="save notes for user.">

		<cfargument name="CourseVoucherCode" type="numeric" required="true" />
		<cfargument name = "userid" type = "numeric" required = "0" default="#session.loginuserid#"/>
		<cfargument name = "languagePref" type = "numeric" required = "0" default="1"/>
		<cfargument name = "reAssignCompletedCode" type="numeric" required = "0" default="0"/>

		<cfset application.fwUtilService.ensureSessionLanguage()>
		<cfset var local = structNew()>
		<cfset local.isCompletedCode = 0 >
		<cfset local.result = request.CourseVoucherManager.GetCourseVoucherByCode(arguments.CourseVoucherCode) />
		<cfset local.languagePrefByCode = request.CourseVoucherManager.GetLanguagePrefByCode(arguments.CourseVoucherCode) />
		<cfif local.result>
			<cfset local.IsAssessment = request.Competency.CheckAssessment(local.result)>
			<!--- BEGIN:BIS - LMS - New Course Bundle option: BIS-3690 - TV0026 --->
			<cfset local.objbundle = createObject("component", "#application.servicePath#.bundle") />
			<cfset local.IsBundle = local.objbundle.CheckBundleVoucherCode(arguments.CourseVoucherCode)>
			<!--- END:BIS - LMS - New Course Bundle option: BIS-3690 - TV0026 --->
			<cfif local.IsBundle EQ -1>
				<cfreturn 'Error'>
			</cfif>
			<cfset local.UserBasicInfo =  application.UserManager.getUserBasicInfo(arguments.userid)>
			<cfset local.CompanyId = local.UserBasicInfo.fldUserCompanyID>
			<cfif local.IsAssessment EQ 1>
				<cfset local.voucherDetail = request.Competency.GetContentVoucherByID(local.result)>
				<!--- BEGIN: Check for ghost account for assigning courses from different company: 12 JAN 2016--->
				<cfset local.userid = arguments.userid>
				<cfif local.voucherDetail.fldCompanyID NEQ local.UserBasicInfo.fldUserCompanyID>
					<cfset local.ghostuserid = getGhostAccountForAUser(userid = arguments.userid, companyid = local.voucherDetail.fldCompanyID) >
					<cfif local.ghostuserid>
						<cfset local.userid = local.ghostuserid>
						<cfset local.CompanyId = local.voucherDetail.fldCompanyID>
					</cfif>
				</cfif>
				<!--- END: CHECK FOR GHOST ACCOUNTS: 12 JAN 2016 --->
				<cfset local.remainingInvites = local.voucherDetail.fldMaxInvites - local.voucherDetail.fldUsedInvites>
				<cfset local.IsValidCode = local.voucherDetail.fldValid>
				<cfset local.Expiry = local.voucherDetail.fldExpiryDate>
				<cfset local.IsPrePaid = local.voucherDetail.fldIsPrePaid>
				<cfset local.VoucherCode = local.voucherDetail.fldVoucherCode>
				<cfset local.ContactName = request.Competency.getCompanyNameById(local.voucherDetail.fldCompanyID).fldMainContactName>
				<cfset local.arrCourseName = DeSerializeJson(local.voucherDetail.fldFormFields)>
				<cfset local.ContentTitle = trim(local.voucherDetail.fldTitle)>
				<cfset local.isUsedCode = getAssessmentVoucherUsedCount(arguments.userid, arguments.CourseVoucherCode)>
				<cfif NOT len(trim(local.ContentTitle))>
					<cfloop array="#local.arrCourseName.fields#" index="local.n">
						<cfif local.n.field_options.uniqueid EQ 12>
							<cfset local.ContentTitle = local.n.label>
						</cfif>
					</cfloop>
				</cfif>
				<cfset local.LogoPath = application.MailService.generateCompanyLogo(companyId = local.voucherDetail.fldCompanyID)>
				<cfset local.CompanyName = request.Competency.getCompanyNameById(local.voucherDetail.fldCompanyID).fldName>
				<cfset local.EmailAdresses = request.Competency.getCompanyNameById(local.voucherDetail.fldCompanyID).fldEmailAddresses>
				<cfset local.CreatorName = local.voucherDetail.CreatorName>
				<cfset local.LocationName = local.voucherDetail.fldDescription>
				<cfset local.CreatorEmail = local.voucherDetail.CreatorEmail>
				<cfset local.isContentActive =  application.fwUtilService.fixedBooleanFormat(local.voucherDetail.formActive)>
				<cfset local.maxInvites = local.voucherDetail.fldMaxInvites>
			<cfelse>
				<cfset local.voucherDetail = request.CourseVoucherManager.GetCourseVoucherByID(local.result)>
				<!--- BEGIN: Check for ghost account for assigning courses from different company: 12 JAN 2016--->
				<cfset local.userid = arguments.userid>
				<cfif local.voucherDetail.getCompany().getID() NEQ local.UserBasicInfo.fldUserCompanyID>
					<cfset local.ghostuserid = getGhostAccountForAUser(userid = arguments.userid, companyid = local.voucherDetail.getCompany().getID()) >
					<cfif local.ghostuserid>
						<cfset local.userid = local.ghostuserid>
						<cfset local.CompanyId = local.voucherDetail.getCompany().getID()>
					</cfif>
				</cfif>
				<!--- END: CHECK FOR GHOST ACCOUNTS: 12 JAN 2016 --->
				<cfset local.remainingInvites = local.voucherDetail.getMaxInvites() - local.voucherDetail.getUsedInvites()>
				<cfset local.IsValidCode = local.voucherDetail.getValid()>
				<cfset local.Expiry = local.voucherDetail.getExpiryDate()>
				<cfset local.IsPrePaid = local.voucherDetail.getIsPrePaid()>
				<cfset local.VoucherCode = local.voucherDetail.getCode()>
				<cfset local.ContactName = local.voucherDetail.getCompany().getMainContactName()>
				<cfset local.ContentTitle = local.voucherDetail.getCourse().getTitle()>
				<cfset local.LogoPath = application.MailService.generateCompanyLogo(LogoPath = local.voucherDetail.getCompany().getCompanyEmailLogoPath())>
				<cfset local.CompanyName = local.voucherDetail.getCompany().getName()>
				<cfset local.EmailAdresses = local.voucherDetail.getCompany().getEmailAddresses()>
				<cfset local.CreatorName = local.voucherDetail.getCreator().getFirstName() & ' ' & local.voucherDetail.getCreator().getLastName()>
				<cfset local.LocationName = local.voucherDetail.getNodeName()>
				<cfset local.CreatorEmail = local.voucherDetail.getCreator().getEmail1()>
				<cfset local.voucherUsedCount = getVoucherUsedCount(fldUserID = local.userid,
					fldVoucherCode = arguments.CourseVoucherCode,
					reAssignCompletedCode = reAssignCompletedCode
				)>
				<cfset local.isUsedCode = local.voucherUsedCount.usedCount>
				<cfset local.isCompletedCode = local.VoucherUsedCount.CompletedCount>
				<cfset local.isContentActive = local.voucherDetail.getCourse().getActive()>
				<cfset local.maxInvites = local.voucherDetail.getMaxInvites()>
			</cfif>
			<cfset local.checkVoucherCompany = application.fwUtilService.checkcoursecodeaccess(local.CompanyId, arguments.CourseVoucherCode)>
			<cfif local.IsValidCode NEQ 1>
				<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblInvalidVoucherCode" >
				<cfreturn Evaluate(local.varname)>
			<cfelseif local.checkVoucherCompany EQ 0>
				<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblCourseCodeNotAvailableSentence">
				<cfreturn Evaluate(local.varname)>
			<cfelseif DateCompare(local.Expiry, Now(), 'd') LT 0> 
				<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblVoucherCodeExpired" >
				<cfreturn Evaluate(local.varname)>
			<cfelseif local.remainingInvites LTE 0>
				<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblVoucherCodeExhausted" >
				<cfreturn Evaluate(local.varname)>
			<cfelseif NOT local.isContentActive>
				<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblContentDeactivatedSentence" >
				<cfreturn Evaluate(local.varname)>
			<cfelseif local.isUsedCode GT 0>
				<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblVoucherCodeAlreadyAdded" >
				<cfreturn Evaluate(local.varname)>
			<cfelseif local.isCompletedCode GT 0>
				<cfreturn 'completed'>
			<cfelse>
				<cfif isDefined('session.loginuserlanguagepref')>
					<cfset local.UserLanguagePref = session.loginuserlanguagepref>
				<cfelseif isDefined('form.LanguagePref')>
					<cfset local.UserLanguagePref = form.LanguagePref>
				<cfelse>
					<cfset local.UserLanguagePref = arguments.languagePref>
				</cfif>
				<cfif local.IsAssessment EQ 0>
					<!---<cfset local.linkedCourseIDlist = request.CourseVoucherManager.GetLinkedCourseID(arguments.CourseVoucherCode, local.UserLanguagePref)>
					<cfif listlen(local.linkedCourseIDlist)>
						<cfloop list="#local.linkedCourseIDlist#" index="local.linkedCourseID">
							<cfset local.courseDetail = request.CourseManager.GetCourseByID(local.linkedCourseID)>
							<cfif val(local.courseDetail.getECNumberOfRepeats()) GT 0>
								<cfset local.numberOfRepeats = val(local.courseDetail.getECNumberOfRepeats())>
							<cfelse>
								<cfset local.numberOfRepeats = 1>
							</cfif>
								<cfset local.permissionID = application.PermissionManager.GrantPermissionToUser(
									CourseID = local.courseDetail.getID(),
									User = local.userid,
									GrantingUser = local.userid,
									PassingMarks = val(local.courseDetail.getPassMarks()),
									NumberOfRepeats = local.numberOfRepeats,
									AddedByMethod = 'Vourcher Code Linking Courses',
									LinkVoucherCodeID = local.voucherDetail.getID()
									)>
						</cfloop>
					</cfif>--->
					<cfif val(local.voucherDetail.getCourse().getECNumberOfRepeats()) GT 0>
						<cfset local.numberOfRepeats = val(local.voucherDetail.getCourse().getECNumberOfRepeats())>
					<cfelse>
						<cfset local.numberOfRepeats = 1>
					</cfif>
				</cfif>
				<cfif local.IsAssessment EQ 1>
					<cfset local.result = request.Competency.AddContentVoucher(
						ContentVoucherID=local.voucherDetail.fldUserCourseVoucher_ID,
						ContentVoucherCode=local.voucherDetail.fldVoucherCode,
						ContentID=local.voucherDetail.fldCourseID,
						UserId=local.userid,
						CompanyNodeID=local.voucherDetail.fldCompanyNodeID,
						refreshindex = 0
					) />
				<!--- BIS - LMS - New Course Bundle option: BIS-3690 - TV0026 --->
				<cfelseif local.IsBundle EQ 0>
					<!--- BEGIN : BIS-4048 : B1994 --->
					<cfset local.result = request.CourseVoucherManager.AddCourseVoucher(
						CourseVoucherID=local.voucherDetail.getID(),
						CourseVoucherCode=local.voucherDetail.getCode(),
						CourseID=local.voucherDetail.getCourse().getID(),
						userid=local.userid,
						passMarks=val(local.voucherDetail.getCourse().getPassMarks()),
						numberOfRepeats=local.numberOfRepeats,
						PoNumber=local.voucherDetail.getPoNumber(),
						vpupgrade = local.voucherDetail.getvpupgrade(),
						refreshindex = 0
					) />
					<!--- END : BIS-4048 : B1994 --->
				<!--- END:BIS - LMS - New Course Bundle option: BIS-3690 - TV0026 --->
				<cfelse>
					<cfset local.result = local.objbundle.redeemvoucherBybundle(
						vouchercodeid=local.voucherDetail.getID(),
						userid=local.userid
					)>
				</cfif>

				<cfset local.remainingInvites = local.remainingInvites - 1>
				<cfif local.IsAssessment EQ 0>
					<cfset local.vouchercomapnyId = local.voucherDetail.getCompany().getID()>
				<cfelse>
					<cfset local.vouchercomapnyId = local.voucherDetail.fldCompanyID>
				</cfif>
				<!--- BEGIN: Send Notification to company email address when remaining invites iss 20, 15, 10 , 0 --->
				<cfif local.IsPrePaid EQ 1 AND local.maxInvites GT 5 AND (local.remainingInvites EQ 20 OR local.remainingInvites EQ 15 OR local.remainingInvites EQ 10 OR local.remainingInvites EQ 0)>
					<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblRemainingCodeSubject" >
					<cfset local.subjectmail = evaluate(local.varname)>
					<cfset local.mailBodyText = local.remainingInvites GT 0 ? 'lblRemainingCodesNotification' : 'lblNoMoreInvitesNotificationSentence'>
					<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.#local.mailBodyText#">
					<cfset local.bodytext = evaluate(local.varname)>
					<cfset local.bodytext = replace(local.bodytext,'{remaining}', local.remainingInvites)>
					<cfset local.bodytext = replace(local.bodytext,'{coursecode}', local.VoucherCode)>
					<cfset local.bodytext = replace(local.bodytext,'{username}', local.ContactName)>
					<cfset local.bodytext = replace(local.bodytext,'{Coursename}', local.ContentTitle)>
					<cfsavecontent variable="local.emailtext">
						<cfoutput>
							<cfif len(trim(local.LogoPath))>
								#local.LogoPath#<br /><br />
								<br /><br /><br /><br />
							</cfif>
							#local.bodytext#<br><br>
							Thank You,<br>
							#local.CompanyName#
						</cfoutput>
					</cfsavecontent>
					<cfset request.mailservice.SendEmail(
						FromAddress = "helpdesk@bistrainer.com",
						ToAddresses = local.EmailAdresses,
						Subject = local.subjectmail,
						HtmlBody = local.emailtext,
						systemMapString = "Sent from: Admin (tab) &gt; Setup (icon) &gt; General Information (Section) &gt; email notifications (field)",
						companyId = local.vouchercomapnyId
						) />
				</cfif>
				
				<cfquery name="local.getCodeLimitNotification" datasource="#application.dsn#">
					SELECT fldCodeLimitNotificationFlag FROM tblusercompanydetails WHERE fldUserCompanyID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.vouchercomapnyId#">;
				</cfquery>
				<cfif local.remainingInvites LTE 0
					AND len(trim(local.creatorEmail)) GT 0
					AND val(local.getCodeLimitNotification.fldCodeLimitNotificationFlag)
					AND local.maxInvites GT 1>
					<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblRemainingCodeCompletedSubjectSentence" >
					<cfset local.subjectmail = evaluate(local.varname)>
					<cfset local.varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblRemainingCodesCompletedNotification" >
					<cfset local.bodytext = evaluate(local.varname)>
					<cfset local.bodytext = replace(local.bodytext,'{content-code}', local.VoucherCode)>
					<cfset local.bodytext = replace(local.bodytext,'{username}', local.CreatorName)>
					<cfset local.bodytext = replace(local.bodytext,'{location-name}', local.LocationName)>
					<cfset local.bodytext = replace(local.bodytext,'{Company-Name}', local.CompanyName)>
					<cfset local.bodytext = replace(local.bodytext,'{Coursename}', local.ContentTitle)>
					<cfsavecontent variable="local.emailtext">
						<cfoutput>
							<cfif len(trim(local.LogoPath))>
								<p>#local.LogoPath#</p><br /><br />
								<br /><br /><br /><br />
							</cfif>
							#local.bodytext#
						</cfoutput>
					</cfsavecontent>
					<cfset request.mailservice.SendEmail(
						"helpdesk@bistrainer.com",
						trim(local.CreatorEmail),
						local.subjectmail,
						local.emailtext,
						'',
						'',
						''
					) />
				</cfif>
				<cfreturn 'added'>
			</cfif>
		<cfelse>
			<cfset varname = "application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblInvalidVoucherCode" >
			<cfreturn Evaluate(local.varname) />
		</cfif>

	</cffunction>

	<cffunction name="RedeemClassroomVoucherCodePublic" access="public"returntype="any" output="false" description="save notes for user.">
		<cfargument name="CourseVoucherCode" type="numeric" required="true">
		<cfargument name = "userid" type = "numeric" required = "0" default="#session.loginuserid#">
		<cfargument name = "languagePref" type = "numeric" required = "0" default="1">
		<cfargument name = "attachedcourse" type = "any" required = "0" default="">
		<cfargument name="PurchaseOrder" type="string" required="false" hint="Purchase order from Add participant" default="">
		<cfargument name="CCAuth" type="string" required="false" hint="Credit Card Authorization from Add participant" default="">
		<cfargument name="PaidInCash" type="string" required="false" hint="Paid in Cash from Add participant" default="0">
		<cfargument name="BookedBy" type="string" required="false" hint="Booked By from Add participant" default="">
		<cfargument name="Notes" type="string" required="false" hint="Notes from Add participant" default="">
		<cfargument name="CardInfo" type="any" required="false" hint="Card details for payment" default="">
		<cfargument name="certificateNumber" required="false" type="string" default="">
		<cfargument name="AddInSameCompany" required="false" type="numeric" default="0">
		<cfargument name="ByUserID" required="false" type="numeric" default="0">
		<cfargument name="preventMultiReg" required="false" type="numeric" default="0">
		<cfargument name="returnStruct" required="false" type="numeric" default="0">
		<cfargument name="eventBookedByEmails" required="false" type="string" default="">
		<cfargument name = "userCetificateDetails" required = "false" type = "array" default = "#arrayNew(1)#">
		<cfargument name = "overridePrerequisite" type = "boolean" default = "false">

		<cfset application.fwUtilService.ensureSessionLanguage()>
		<cfset var local = structNew()>
		<cfset local.msgvar = "">
		<cfset local.multiRegEvents = []>
		<cfset local.loginuserid = val(arguments.ByUserID) ? val(arguments.ByUserID) : structKeyExists(session, 'loginuserid') ? val(session.loginuserid) : 0>
		<cfset local.isEventSharedWithSubCompany = 0>
		<cfset local.prerequisiteCourseList = []>

		<cfquery name="local.voucherDetail" datasource="#application.dsn#">
			SELECT
				CCV.*,
				TCD.fldPrerequisitesFlag,
				TCD.fldBlockParticipantRegistration,
				TCD.fldTrainingCourseID
			FROM
				tblclassroomcoursevoucher CCV
				INNER JOIN tblclassroomevents CE ON CE.fldClassroomEvents_ID = CCV.fldEventID
				INNER JOIN tbltrainingcoursedetails TCD ON TCD.fldTrainingCourseID = CE.fldTrainingCourseID
			WHERE
				fldVoucherCode = <cfqueryparam cfsqltype="numeric" value="#arguments.CourseVoucherCode#">;
		</cfquery>
		<cfquery name="local.getEventCompany" datasource="#application.dsn#">
			SELECT
				fldCompanyID,
				IFNULL(fldCommunityCalendarCompanyID, 0) AS fldCommunityCalendarCompanyID
			FROM
				tblclassroomevents
			WHERE
				fldClassroomEvents_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.voucherDetail.fldEventID#">
		</cfquery>

		<!--- Checking wheather parent company has shared event with sub company ---->
		<cfif local.voucherDetail.fldCompanyID NEQ local.getEventCompany.fldCompanyID>
			<cfquery name="local.checkEventSharedToSubCompany" datasource="#application.dsn#">
				SELECT
					CC.fldParentcompanyId
				FROM
					tblusercompany CC
					INNER JOIN tblusercompanydetails UCD ON UCD.fldUserCompanyID = CC.fldParentcompanyId
				WHERE
					CC.fldParentcompanyId IS NOT NULL
					AND UCD.fldUserCompanyID = <cfqueryparam value="#local.getEventCompany.fldCompanyID#" cfsqltype="integer">
					AND CC.fldUserCompany_ID = <cfqueryparam value="#local.voucherDetail.fldCompanyID#" cfsqltype="integer">
					AND UCD.fldSharePublicEventToSubPortal = 1
			</cfquery>
			<cfif local.checkEventSharedToSubCompany.recordCount>
				<cfset local.isEventSharedWithSubCompany = 1>
			</cfif>
		</cfif>

		<cfif local.voucherDetail.recordCount>
			<cfset local.isUserMetRequirements = true>
			<cfif val(local.voucherDetail.fldPrerequisitesFlag)
				AND val(local.voucherDetail.fldBlockParticipantRegistration)
				AND NOT arguments.overridePrerequisite
				AND val(arguments.returnStruct)
			>
				<cfset local.checkPrerequisitesDetails = request.classroomEvent.checkPrerequisites(
					ClassroomEventID = local.voucherDetail.fldEventID,
					ClassroomCourseID = local.voucherDetail.fldTrainingCourseID,
					userId = local.loginuserid
				)/>
				<cfset local.isUserMetRequirements = local.checkPrerequisitesDetails.isUserMetRequirements>
				<cfset local.prerequisiteCourseList = local.checkPrerequisitesDetails.courseNameList>
			</cfif>
			<cfset local.remainingInvites = local.voucherDetail.fldMaxInvites - local.voucherDetail.fldUsedInvites>
			<cfif local.voucherDetail.fldValid NEQ 1>
				<cfset local.msgvar = evaluate("application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblInvalidVoucherCode")>
			<cfelseif DateCompare(local.voucherDetail.fldExpiryDate, Now(), 'd') LT 0> 
				<cfset local.msgvar = evaluate("application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblVoucherCodeExpired")>
			<cfelseif local.remainingInvites LTE 0>
				<cfset local.msgvar = evaluate("application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblVoucherCodeExhausted")>
			<cfelseif getClassroomVoucherUsedCount(arguments.userid, local.voucherDetail.fldClassroomCourseVoucher_ID) GT 0>
				<cfset local.msgvar = evaluate("application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblVoucherCodeAlreadyAdded")>
			<cfelseif request.classroomEvent.checkEventaParticipantDuplication(local.voucherDetail.fldEventID, arguments.userid) GT 0>
				<cfset local.msgvar = evaluate("application.stLang.#session.LanguageName#.Classroom.classroomevent.lblDuplicateParticipantSentence")>
			<cfelse>
				<cfset var overlappedCourse = request.classroomEvent.CheckOverlappedCourses(EventID = local.voucherDetail.fldEventID, UserID = arguments.userid)>
				<cfif NOT overlappedCourse>
					<cfif arguments.preventMultiReg EQ 3><!---if from login button or enter--->
						<cfset local.multiRegEvents = application.classroomEvent.checkMultiRegistration(userid = arguments.userid, vouchercode = arguments.CourseVoucherCode)>
						<cfset local.msgvar = arrayLen(local.multiRegEvents) ? 'multiReg' : ''>
					</cfif>
					<cfif NOT arrayLen(local.multiRegEvents)>
						<cfset local.userid = arguments.userid>
						<cfset local.usercompanyid = application.usermanager.getUserBasicInfo(arguments.userid).fldUserCompanyID>
						<cfif local.usercompanyid NEQ local.voucherDetail.fldCompanyID AND arguments.AddInSameCompany EQ 0>
							<cfset local.ghostuserid = getGhostAccountForAUser(userid = arguments.userid, companyid = local.voucherDetail.fldCompanyID) >
							<cfif local.ghostuserid>
								<cfset local.userid = local.ghostuserid>
							</cfif>
						</cfif>
						<cfif local.voucherDetail.fldCompanyID NEQ local.getEventCompany.fldCompanyID AND local.usercompanyid NEQ local.getEventCompany.fldCommunityCalendarCompanyID AND local.isEventSharedWithSubCompany NEQ 1>
							<cfset local.ghostuserid = getGhostAccountForAUser(userid=arguments.userid, companyid = local.getEventCompany.fldCompanyID)>
							<cfif local.ghostuserid>
								<cfset local.userid = local.ghostuserid>
							<cfelse>
								<cfset local.userid = application.Util.createNetworkghostAccount(userid=arguments.userid, EventCompanyID=local.getEventCompany.fldCompanyID, refreshindex=0)>
							</cfif>
						</cfif>
						<cftry>
						<cfif local.isUserMetRequirements EQ true>
							<cfset local.result = request.CourseVoucherManager.AddCourseVoucherClassroomEvent(
								CourseVoucher = local.voucherDetail,
								userid = local.userid,
								attachedcourse= arguments.attachedcourse,
								PurchaseOrder = arguments.purchaseorder,
								CCAuth = arguments.ccauth,
								PaidInCash = val(arguments.paidincash),
								BookedBy = arguments.bookedby,
								Notes = arguments.notes,
								CardInfo = arguments.CardInfo,
								certificateNumber = arguments.certificateNumber,
								refreshindex = 0,
								ByUserID = local.loginuserid,
								preventMultiReg = arguments.preventMultiReg,
								eventBookedByEmails = arguments.eventBookedByEmails,
								userCetificateDetails = arguments.userCetificateDetails,
								overridePrerequisite = arguments.overridePrerequisite
							)>
							<cfset local.msgvar = 'added'>
						<cfelse>
							<cfset local.msgvar = 'prerequisiteNotsatisfied'>
						</cfif>
						<cfcatch>
							<cfset application.MailService.customErrorEmailHandler(subject = "Error at #cgi.http_host# - Error when adding participant", toAddresses = application.errormailaddreses, cfcatch = cfcatch, arguments = arguments)>
							<cfset local.msgvar = 'Participant not added, please try again.'>
						</cfcatch>
						</cftry>
					</cfif>
				<cfelse>
					<cfset local.msgvar = evaluate("application.stLang.#session.LanguageName#.Classroom.classroomevent.lblOverlappingCourseErrorSentence")>
				</cfif>
			</cfif>
		<cfelse>
			<cfset local.msgvar = evaluate("application.stLang.#session.LanguageName#.learner.VoucherInvitation.lblInvalidVoucherCode")>
		</cfif>
		<cfif arguments.returnStruct EQ 1>
			<cfset local.result = {}>
			<cfset local.result['redeemstatus'] = local.msgvar>
			<cfset local.result['multiRegEvents'] = local.multiRegEvents>
			<cfset local.result['prerequisiteCourseList'] = local.prerequisiteCourseList>
			<cfset local.result['isUserMetRequirements'] = local.isUserMetRequirements>
			<cfreturn local.result>
		<cfelse>
			<cfreturn local.msgvar>
		</cfif>
	</cffunction>

	<cffunction name="Authenticate" access="public" returntype="struct" returnformat="json" output="false" description="Attempt to authenticate given the provided username and password.">
		<cfargument name="UserName" type="string" required = "1" hint="The name of the user to authenticate.">
		<cfargument name="Password" type="string" required = "1" hint="The password to attempt to authenticate with.">
		<cfargument name="CourseVoucherCode" type="numeric" required = "1" hint="The course voucher code.">
		<cfargument name="ClassroomVoucher" type="numeric" required = "1" hint="ClassroomVoucher or not.">
		<cfset application.fwUtilService.ensureSessionLanguage()>
		<cfset var result = request.UserManager.AuthenticateUser(arguments.UserName, arguments.Password)>
		<cfset var language = request.LanguageBundleManager.GetLanguageBundleByID(1) />
		<cfif result.success>
			<cfif NOT arguments.ClassroomVoucher>
				<cfset result.Reason = RedeemVoucherCodePublic(CourseVoucherCode=arguments.CourseVoucherCode,userid=result.userid,languagePref = result.LanguagePref)>
				<cfset result['GhostReLogin'] = 0>
				<cfset local.voucherDetail = request.CourseVoucherManager.GetCourseVoucherByCode(arguments.CourseVoucherCode)>
				<cfset local.IsAssessment = request.Competency.CheckAssessment(local.voucherDetail)>
				<cfif local.IsAssessment EQ 1>
					<cfset local.voucherDetail = request.Competency.GetContentVoucherByID(local.voucherDetail)>
					<cfset local.VoucherCompanyID  = local.voucherDetail.fldCompanyID>
				<cfelse>
					<cfset local.voucherDetail = request.CourseVoucherManager.GetCourseVoucherByID(local.voucherDetail)>
					<cfset local.VoucherCompanyID  = local.voucherDetail.getCompany().getID()>
				</cfif>
				<cfif local.VoucherCompanyID NEQ result.UserCompanyID>
					<cfset local.ghostuserid = getGhostAccountForAUser(userid = result.userid, companyid = local.VoucherCompanyID)>
					<cfif local.ghostuserid>
						<cfquery name="local.qryGetGhostAccountDetails" datasource="#application.dsn#">
							SELECT
								U.fldUser_ID,
								U.fldUserCompanyID
							FROM
								tblUser U
								INNER JOIN tblUserCompany UC ON UC.fldUserCompany_ID = U.fldUserCompanyID AND UC.fldActive = 1
							WHERE
								U.fldAccountActive = 2
								AND	U.fldUser_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.ghostuserid#">
						</cfquery>
						<cfif local.qryGetGhostAccountDetails.recordCount>
							<cfset result['SwitchToUserID'] = local.ghostuserid>
							<cfset result['SwitchToCompanyID'] = local.qryGetGhostAccountDetails.fldUserCompanyID>
							<cfset result['GhostReLogin'] = 1>
						</cfif>
					</cfif>
				</cfif>
			<cfelse>
				<cfset result.Reason = RedeemClassroomVoucherCodePublic(CourseVoucherCode=arguments.CourseVoucherCode,userid=result.userid,languagePref = result.LanguagePref)>
			</cfif>
			<cfif result.Reason NEQ 'Added'>
				<cfset result.success = false>
			</cfif>
		<cfelse>
			<cfif result.Reason NEQ ''>
				<cfset result.Reason = language.GetReason(result.Reason) />
			</cfif>
		</cfif>
		<!--- Don't wanna send this along... --->
		<cfset StructDelete(result, "User") />

		<cfreturn result />
	</cffunction>

	<cffunction name="getVoucherUsedCount">
		<cfargument name="fldUserID">
		<cfargument name="fldVoucherCode">
		<cfargument name="reAssignCompletedCode" required="false" default="0">

		<cfset var local = structNew()>
		<cfset var qGetVoucherUsedCount = queryNew("")>
		<cfset local.usedcount = 0>
		<cfset local.result = {}>
		<!--- BEGIN: Ghost account - 25 Jan 2015 - TV0032 --->
		<cfset local.GhostUserDetails = request.UserManager.getGhostAccountProfiles(UserID = arguments.fldUserID)>
		<cfif local.GhostUserDetails.recordCount>
			<cfset local.TotalUserList = listAppend(valueList(local.GhostUserDetails.fldUser_ID), arguments.fldUserID)>
		<cfelse>
			<cfset local.TotalUserList = arguments.fldUserID>
		</cfif>
		<!--- END: Ghost account - 25 Jan 2015 - TV0032 --->

		<cfquery name="local.qGetVoucherNotStartedInProg" datasource="#application.dsn#">
			SELECT
				GROUP_CONCAT(
					CASE WHEN UCH.fldStatus IS NULL
					OR UCH.fldStatus = 'inprogress' THEN
						'inprogress'
					ELSE
						'completed'
					END 
				)AS status
			FROM
				tblsyscoursepermission SCP
				INNER JOIN tblusercoursevoucher UCV ON UCV.fldUserCourseVoucher_ID = SCP.fldCourseVoucherCodeID
				LEFT JOIN tblusercoursehistory UCH ON UCH.fldSysCoursePermissionID = SCP.fldSysCoursePermission_ID
				AND UCH.fldUserID = SCP.fldUserID
				AND UCH.fldSysCourseID = SCP.fldSysCourseID
			WHERE
				UCV.fldVoucherCode = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fldVoucherCode#">
				AND SCP.fldUserID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.TotalUserList#" list="true">)
				AND SCP.fldActive = 1
		</cfquery>
		<cfset local.usedcount = local.qGetVoucherNotStartedInProg.recordCount>
		<cfif val(local.usedcount)>
			<cfset local.result['usedCount'] = listFindNoCase(local.qGetVoucherNotStartedInProg.status, 'inprogress')>
			<cfset local.result['CompletedCount'] = NOT val(arguments.reAssignCompletedCode) ? listFindNoCase(local.qGetVoucherNotStartedInProg.status, 'completed') : 0>
		</cfif>
		<cfif NOT val(local.usedcount)>
			<cfquery name="local.qGetVoucherRepeated" datasource="#application.dsn#">
				SELECT
				COUNT(UCH.fldUserCourseHistory_ID) AS fldRepeatCount,
				SCP.fldNumberOfRepeates
				FROM
				tblsyscoursepermission SCP
				INNER JOIN tblusercoursevoucher UCV ON UCV.fldUserCourseVoucher_ID = SCP.fldCourseVoucherCodeID
				INNER JOIN tblusercoursehistory UCH ON UCH.fldSysCoursePermissionID = SCP.fldSysCoursePermission_ID
				AND UCH.fldStatus = 'completed'
				AND UCH.fldUserID = SCP.fldUserID
				AND UCH.fldSysCourseID = SCP.fldSysCourseID
				WHERE
				UCV.fldVoucherCode = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fldVoucherCode#">
				AND SCP.fldUserID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.TotalUserList#" list="true">)
				AND SCP.fldActive = 1
				AND (
					ROUND(UCH.fldScore) < CAST(SCP.fldPassMarks AS UNSIGNED INTEGER)
				)
				AND NOT EXISTS (
					SELECT
					1
					FROM
					tblUserCourseHistory AS History
					WHERE
					(History.fldUserID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.TotalUserList#" list="true">))
					AND (History.fldSysCourseID = SCP.fldSysCourseID)
					AND (
						History.fldSysCoursePermissionID = SCP.fldSysCoursePermission_ID
					)
					AND (
						((History.fldStatus = 'completed') AND (ROUND(History.fldScore) >= CAST(SCP.fldPassMarks AS UNSIGNED INTEGER)))
						OR
						((History.fldStatus = 'inprogress'))
					)
				)
				GROUP BY
				UCH.fldSysCourseID
				HAVING
				fldRepeatCount < SCP.fldNumberOfRepeates;
			</cfquery>
			<cfset local.result['usedCount'] = local.qGetVoucherRepeated.recordCount>
		</cfif>
		<cfreturn local.result>
	</cffunction>

	<cffunction name="getClassroomVoucherUsedCount">
		<cfargument name="fldUserID">
		<cfargument name="fldVoucherCodeID">

		<cfset var local = structNew()>
		<cfset var qGetVoucherUsedCount = queryNew("")>
		<!--- BEGIN: Ghost account - 25 Jan 2015 - TV0032 --->
		<cfset local.GhostUserDetails = request.UserManager.getGhostAccountProfiles(UserID = arguments.fldUserID)>
		<cfif local.GhostUserDetails.recordCount>
			<cfset local.TotalUserList = listAppend(valueList(local.GhostUserDetails.fldUser_ID), arguments.fldUserID)>
		<cfelse>
			<cfset local.TotalUserList = arguments.fldUserID>
		</cfif>
		<!--- END: Ghost account - 25 Jan 2015 - TV0032 --->
		<cfquery name="qGetVoucherUsedCount" datasource="#application.dsn#">
			SELECT
				COUNT(CEP.fldClassroomEventParticipant_ID) AS AddedCount
			FROM
				tblclassroomeventparticipant CEP
				INNER JOIN tblclassroomcoursevoucher CCV ON CCV.fldClassroomCourseVoucher_ID = CEP.fldVoucherCodeID
			WHERE
				CCV.fldClassroomCourseVoucher_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fldVoucherCodeID#">
				AND CEP.fldUserID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.TotalUserList#" list="true">)
				AND CEP.fldactive = 1
		</cfquery>
		<cfreturn qGetVoucherUsedCount.AddedCount>
	</cffunction>

	<cffunction name="CreateGhostAccount" access="public" returnformat="plain">
		<cfargument name="voucherCode" required="false" default="0">
		<cfargument name="userid" type="numeric" required="0" default="0"/>
		<cfargument name="NewCompanyID" type="numeric" required="0" default="0"/>
		<cfargument name="NewNodeID" type="numeric" required="0" default="0"/>
		<cfargument name="refreshindex" type="boolean" required="false" default="false"> <!--- OSSA- Calendar - Quick Upload Feature for completed Classroom Courses : BIS-3738; AP --->
		<cfargument name="companyRoleid" type="string" required="false" default="">
		<cfargument name="password" type="string" required="false" default="">
		<cfset var local = structNew()>

		<cfif val(request?.noSession) EQ 0 AND val(session?.loginUserID) AND arguments.userid EQ 0>
			<cfset arguments.userid = session.loginuserid>
		</cfif>

		<cftry>
			<cfset local.VoucherCompanyID = ''>
			<cfset local.VoucherNodeID = ''>
			<cfif val(arguments.NewCompanyID) GT 0 AND val(arguments.NewNodeID) GT 0>
				<cfset local.VoucherCompanyID = val(arguments.NewCompanyID)>
				<cfset local.VoucherNodeID = val(arguments.NewNodeID)>
			<cfelseif val(arguments.voucherCode) GT 0>
				<cfif left(arguments.voucherCode, 1) EQ 2>
					<cfset local.result = request.CourseVoucherManager.GetCourseVoucherByCode(arguments.voucherCode) />
					<cfif local.result>
						<cfset local.IsAssessment = request.Competency.CheckAssessment(local.result)>
						<cfif local.IsAssessment>
							<cfset local.voucherDetail = request.Competency.GetContentVoucherByID(local.result)>
							<cfset local.VoucherCompanyID = local.voucherDetail.fldCompanyID>
							<cfset local.VoucherNodeID = local.voucherDetail.fldCompanyNodeID>
						<cfelse>
							<cfset local.voucherDetail = request.CourseVoucherManager.GetCourseVoucherByID(result)>
							<cfset local.VoucherCompanyID = local.voucherDetail.getCompany().getID()>
							<cfset local.VoucherNodeID = local.voucherDetail.getNode()>
						</cfif>
					</cfif>
				<cfelseif left(arguments.voucherCode, 2) EQ 30>
					<cfset local.voucherDetail = request.ClassroomEvent.getEventVouchers(EventVoucherCode = arguments.voucherCode)>
					<cfset local.VoucherCompanyID = local.voucherDetail.fldCompanyID>
					<cfset local.VoucherNodeID = local.voucherDetail.fldCompanyNodeID>
				</cfif>
			</cfif>

			<cfif val(local.VoucherCompanyID) AND val(local.VoucherNodeID)>
				<cfif NOT getGhostAccountForAUser(UserID = arguments.userid, CompanyID = local.VoucherCompanyID)>
					<cfquery name="local.getDeletedUsers" datasource="#application.dsn#">
						SELECT fldUser_ID
						FROM tblUser
						WHERE fldGhostParentID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.userid#">
						AND fldUserCompanyID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.VoucherCompanyID#">
						AND fldAccountActive = 0;
					</cfquery>
					<!--- Check if any deleted shared account exists, and reactivate it if exists --->
					<cfif local.getDeletedUsers.recordCount>
						<cfset application.ManageUsers.ReactiavteAUser(user = local.getDeletedUsers.fldUser_ID)>
						<cfset local.returnStr = local.getDeletedUsers.fldUser_ID>
					<cfelse>
						<cfset var ParentUserQry = application.UserManager.getUserBasicInfo(arguments.userID)>
						<cfset local.returnStr = application.ManageUsers.AddNewGhostUser(
																			DbSourse = application.dsn,
																			LanguagePref = len(ParentUserQry.fldLanguagePref) ? ParentUserQry.fldLanguagePref : 1,
																			UserCompany = val(local.VoucherCompanyID),
																			UserCompanyGroup = val(local.VoucherNodeID),
																			FirstName = ParentUserQry.fldFirstName,
																			MiddleName = ParentUserQry.fldMiddleName,
																			LastName = ParentUserQry.fldLastName,
																			Address = ParentUserQry.fldAddress1,
																			City = ParentUserQry.fldCity,
																			ZipPostalCode = ParentUserQry.fldZipPostalCode,
																			Phone1 = ParentUserQry.fldPhone1,
																			Phone2 = ParentUserQry.fldPhone2,
																			Email = ParentUserQry.fldEmail1,
																			SendEmail = ParentUserQry.fldSendEmail,
																			StateID = ParentUserQry.fldStateID,
																			Country = ParentUserQry.fldCountry,
																			VerifiedEmail = ParentUserQry.fldVerifiedEmail,
																			NoEmail = ParentUserQry.fldNoEmail,
																			BirthDateDemographics = ParentUserQry.fldBirthDateDemographics,
																			GhostParentID = ParentUserQry.fldUser_ID,
																			refreshindex=arguments.refreshindex,<!--- OSSA- Calendar - Quick Upload Feature for completed Classroom Courses : BIS-3738; AP --->
																			Phone3 = ParentUserQry.fldPhone3,
																			Email2 = ParentUserQry.fldEmail2,
																			VerifiedEmail2 = val(ParentUserQry.fldVerifiedEmail2),
																			NoEmail2 = ParentUserQry.fldNoEmail2,
																			CollectorNumber = ParentUserQry.fldAirmilesCollectorNumber,
																			CompanyRoleid = arguments.companyRoleid,
																			Password = arguments.password
																		)>
					</cfif>
					<cfif val(local.returnStr)>
						<cfset request.MailService.SendWelcomeEmail(userID=local.returnStr)>
						<cfif val(arguments.NewNodeID) OR val(local.VoucherNodeID)>
							<cfquery name="local.getMembershipDetails" datasource="#application.dsn#" >
								SELECT
									fldDescription
								FROM
									tblusercompanygroups
								WHERE
									fldUserCompanyGroup_ID = <cfqueryparam value="#val(arguments.NewNodeID) != 0 ? arguments.NewNodeID : local.VoucherNodeID#" cfsqltype="integer" maxlength="11">
							</cfquery>
							<cfif local.getMembershipDetails.recordCount>
								<cfset application.companyNodeManager.NewUserEmail(UserId=local.returnStr,
									Location=local.getMembershipDetails.fldDescription,
									via="as a linked account"
								)>
							</cfif>
						</cfif>
						<cfset application.ManageCompany.verifySharedUserCellphone(userId = local.returnStr,
							newGhostAccount = 1
						)>
					</cfif>
					<cfreturn local.returnStr>
				</cfif>
				<cfreturn 1>
			<cfelse>
				<cfreturn 0>
			</cfif>

			<cfcatch>
				<cfset application.MailService.customErrorEmailHandler(subject = "Error at #cgi.http_host# - While creating ghost account", toAddresses = application.errormailaddreses, cfcatch = cfcatch, arguments = arguments)>
				<cfreturn 0>
			</cfcatch>
		</cftry>
	</cffunction>

	<cffunction name="addGhostDenyNote" access="public" returnformat="plain">
		<cfargument name="voucherCode" required="true">
		<cfargument name="userid" type="numeric" required="0" default="0"/>

		<cfset var local = structNew()>

		<cfif val(request?.noSession) EQ 0 AND val(session?.loginUserID) AND arguments.userid EQ 0>
			<cfset arguments.userid = session.loginuserid>
		</cfif>

		<cfset local.VoucherCompanyName = ''>

		<cfif left(arguments.voucherCode, 1) EQ 2>
			<cfset local.result = request.CourseVoucherManager.GetCourseVoucherByCode(arguments.voucherCode) />
			<cfif local.result>
				<cfset local.voucherDetail = request.CourseVoucherManager.GetCourseVoucherByID(result)>
				<cfset local.VoucherCompanyName = local.voucherDetail.getCompany().getName()>
				<cfset local.CourseName = voucherDetail.getCourse().getTitle()>
			</cfif>
		<cfelseif left(arguments.voucherCode, 2) EQ 30>
			<cfset local.voucherDetail = request.ClassroomEvent.getEventVouchers(EventVoucherCode = arguments.voucherCode)>
			<cfset local.VoucherCompanyName = local.voucherDetail.fldName>
			<cfset local.CourseName = local.voucherDetail.fldCourseName>
		</cfif>

		<cfif len(local.VoucherCompanyName)>
			<cfset var Notes = '#local.VoucherCompanyName# was denied access to the training records for #local.CourseName#.'>
			<cfquery name="qryCreateGhostAccount" datasource="#application.dsn#">
				Insert into tblsysusernotes
				(
					fldUserID,
					fldNotes,
					fldActive,
					fldAddedBy,
					fldDateAdded
				)
				values
				(
					<cfqueryparam value="#arguments.UserID#" cfsqltype="CF_SQL_INTEGER" />,
					<cfqueryparam value="#Notes#" cfsqltype="cf_sql_varchar" />,
					1,
					<cfif val(request?.noSession) EQ 0 AND isDefined('session.loginuserid')>
						<cfqueryparam value="#session.loginuserid#" cfsqltype="CF_SQL_INTEGER"/>,
					<cfelse>
						<cfqueryparam value="#arguments.UserID#" cfsqltype="CF_SQL_INTEGER"/>,
					</cfif>
					now()
				)

			</cfquery>
		</cfif>
		<cfreturn 1>
	</cffunction>

	<cffunction name="CheckForGhost" access="public" returnformat="JSON" returntype="Any">
		<cfargument name="UserName" required="true">
		<cfargument name="Password" required="true">
		<cfargument name="CourseVoucherCode" required="true">
		<cfargument name="ClassroomVoucher" required="false" default="0">

		<cfset var language = request.LanguageBundleManager.GetLanguageBundleByID(1)>
		<cfset var result = structNew()>
		<cfif len(arguments.UserName) AND len(arguments.Password)>
			<cfset result = request.UserManager.AuthenticateUser(arguments.UserName, arguments.Password)>
		<cfelseif  val(request?.noSession) EQ 0 AND structKeyExists(session, "loginuserid") AND val(session.loginuserid)>
			<cfset result = request.UserManager.AuthenticateUserByID(userID=session.loginuserid)>
			<cfset result.success = true>
		</cfif>
		<cfif val(request?.noSession) EQ 0>
			<cfparam name="session.LanguageName" default="english">
			<cfset local.LanguageName = session.LanguageName>
		<cfelse>
			<cfset local.LanguageName = "english">
		</cfif>
		<cfset result['NeedGhost'] = 0>
		<cfif isDefined('result.success') AND result.success>
			<cfif val(arguments.ClassroomVoucher) EQ 1 OR left(arguments.CourseVoucherCode, 2) EQ 30>
				<cfset local.voucherDetail = request.ClassroomEvent.getEventVouchers(EventVoucherCode = arguments.CourseVoucherCode)>
				<cfif local.voucherDetail.recordCount>
					<cfset local.VoucherCompanyName = local.voucherDetail.fldName>
					<cfset local.VoucherCompanyID = local.voucherDetail.fldCompanyID>
				<cfelse>
					<cfset result.success = false>
					<cfset local.varname = "application.stLang.#local.LanguageName#.home.loginForm.lblInvalidActivationCode" >
					<cfset result.Reason = Evaluate(local.varname)>
				</cfif>
			<cfelse>
				<cfset local.voucherid = request.CourseVoucherManager.GetCourseVoucherByCode(arguments.CourseVoucherCode)>
				<cfif local.voucherid>
					<cfset local.IsAssessment = request.Competency.CheckAssessment(local.voucherid)>
					<cfif local.IsAssessment EQ 1>
						<cfset local.voucherDetail = request.Competency.GetContentVoucherByID(local.voucherid)>
						<cfset local.VoucherCompanyName = request.Competency.getCompanyNameById(local.voucherDetail.fldCompanyID).fldName>
						<cfset local.VoucherCompanyID = local.voucherDetail.fldCompanyID>
					<cfelse>
						<cfset local.voucherDetail = request.CourseVoucherManager.GetCourseVoucherByID(local.voucherid)>
						<cfset local.VoucherCompanyName = local.voucherDetail.getCompany().getName()>
						<cfset local.VoucherCompanyID = local.voucherDetail.getCompany().getID()>
					</cfif>
				<cfelse>
					<cfset result.success = false>
					<cfset local.varname = "application.stLang.#local.LanguageName#.home.loginForm.lblInvalidActivationCode" >
					<cfset result.Reason = Evaluate(local.varname)>
				</cfif>
			</cfif>

			<cfif result.success AND result.userCompanyID NEQ local.VoucherCompanyID>
				<cfif getGhostAccountForAUser(UserID = result.userID, CompanyID = local.VoucherCompanyID) EQ 0>
					<cfset result['NeedGhost'] = 1>
					<cfif findnocase('action=bisadmin.ViewManagerProfile', cgi.HTTP_REFERER)>
						<cfset local.lblGhostPopupSentence = "application.stLang.#local.LanguageName#.bisadmin.ViewManagerProfile.lblGhostPopupSentence">
					<cfelseif findnocase('action=learner.home', cgi.HTTP_REFERER)>
						<cfset local.lblGhostPopupSentence = "application.stLang.#local.LanguageName#.learner.home.lblGhostPopupSentence">
					<cfelseif findnocase('action=home.loginForm', cgi.HTTP_REFERER)>
						<cfset local.lblGhostPopupSentence = "application.stLang.#local.LanguageName#.home.loginForm.lblGhostPopupSentence">
					<cfelse>
						<cfset local.lblGhostPopupSentence = "application.stLang.#local.LanguageName#.home.loginForm.lblGhostPopupSentence">
					</cfif>
					<cfset local.lblGhostPopupSentence = evaluate(local.lblGhostPopupSentence)>
					<cfset local.lblGhostPopupSentence = replacenocase(local.lblGhostPopupSentence, '{voucher-company}', local.VoucherCompanyName, 'all')>
					<cfset local.lblGhostPopupSentence = replacenocase(local.lblGhostPopupSentence, '{user-company}', result.userCompanyName, 'all')>
					<cfset result['GhostMessage'] = local.lblGhostPopupSentence>
					<cfset result['UserID'] = result.userID>
				</cfif>
			</cfif>
		<cfelse>
			<cfif isDefined('result.Reason') AND result.Reason NEQ ''>
				<cfset result.Reason = language.GetReason(result.Reason)>
			</cfif>
		</cfif>
		<!--- Don't wanna send this along... --->
		<cfset StructDelete(result, "User")>

		<cfreturn result>
	</cffunction>

	<cffunction name="generateCompareStringForName" access="public" returntype="string" output="true" description="">
		<cfargument name="value" type="string" required="true">
		<!---
			!!!IMPORTANT!!!
			If you are going to change this, ask yourself if the change is neccessary.
			If yes, then make sure you are changing DB function fnGenerateCompareStringForName as well
		--->
		<cfreturn REreplace(arguments.value, "[ '-]", '', 'all')>
	</cffunction>

	<cffunction name="checkForGhostByEmail" access="remote" returnformat="JSON" returntype="Struct">
		<cfargument name="Email" required="true">
		<cfargument name="LastName" required="false" default="">
		<cfargument name="CompanyID" required="true">
		<cfargument name="CurrentUserID" required="false" default="0">
		<cfargument name="revealEncEmail" required="false" default="true" hint="control returning encypted user input">
		<cfargument name="verificationEmailData" required="false" default="{}" hint="">
		<cfargument name="sendGhostVerificationEmail" type="boolean" required="false" default="1">
		<cfset var local= structNew()>
		<cfset local["returnStruct"] = structNew()>
		<cfif len(trim(arguments.Email)) EQ 0>
			<cfset local["returnStruct"] = {"Flag":0, "EmailEnc":'', "DifferentLastname": 0, "ghostParentID": 0}>
			<cfreturn local["returnStruct"]>
		</cfif>
		<cfif arguments.revealEncEmail>
			<cfset local["returnStruct"]["EmailEnc"] = encrypt(arguments.Email, 'password', 'BLOWFISH', 'Hex')>
		</cfif>
		<cfset local["returnStruct"]["DifferentLastname"] = 0>

		<cfquery name="local.qryGetOwnCompanyDuplicate" datasource="#application.dsn#">
			SELECT
				fldUser_ID
			FROM
				tblUser
			WHERE
				fldEmail1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.Email)#">
				AND fldUserCompanyID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CompanyID#">
				/* AND fldGhostParentID IS NULL */
				AND fldDuplicateEmail = 0
				AND fldAccountActive IN (1,2)
				<cfif val(arguments.CurrentUserID) GT 0>
					AND fldUser_ID <> <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CurrentUserID#">
				</cfif>
		</cfquery>

		<cfif local.qryGetOwnCompanyDuplicate.recordCount><!--- User with same email exists in the same company. So restrict creation with that email --->
			<cfset local["returnStruct"]["Flag"] = 1>
			<cfreturn local["returnStruct"]>
		</cfif>
		<cfquery name="local.qGetGhostParentID" datasource="#application.dsn#">
			SELECT
				fldGhostParentID
			FROM
				tblUser
			WHERE
				fldUser_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CurrentUserID#">
		</cfquery>
		<cfquery name="local.qryGetOtherCompanyDuplicate" datasource="#application.dsn#">
			SELECT
				fldUser_ID,
				fldLastName,
				fldEmail1,
				fldAccountActive
			FROM
				tblUser
			WHERE
				fldEmail1 = <cfqueryparam cfsqltype="cf_sql_varchar" value="#trim(arguments.Email)#">
				AND fldUserCompanyID <> <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CompanyID#">
				AND fldGhostParentID IS NULL
				AND fldDuplicateEmail = 0
				AND fldAccountActive IN (1,2)
				<cfif val(arguments.CurrentUserID) GT 0>
					AND fldUser_ID <> <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CurrentUserID#">
				</cfif>
				<cfif val(local.qGetGhostParentID.fldGhostParentID)>
					AND fldUser_ID <> <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qGetGhostParentID.fldGhostParentID#">
				</cfif>
		</cfquery>

		<cfif local.qryGetOtherCompanyDuplicate.recordCount
			AND generateCompareStringForName(local.qryGetOtherCompanyDuplicate.fldLastName) EQ generateCompareStringForName(application.fwUtilService.sanitiseLastname(arguments.LastName))
		><!--- User with same email exists in the other company. So ask for create ghost account --->
			<cfif local.qryGetOtherCompanyDuplicate.fldAccountActive EQ 2>
				<cfif IsStruct(arguments.verificationEmailData) AND NOT structIsEmpty(arguments.verificationEmailData)>
					<cfset arguments.verificationEmailData['email'] = local["returnStruct"]["EmailEnc"]>
					<cfparam name="arguments.verificationEmailData.sendSecurityCode" default="1">
					<cfif arguments.sendGhostVerificationEmail EQ 1>
						<cfset local.objLearner = createObject("component", "#application.servicePath#.learner").init(application.fwDummy)>
						<cfset local.objLearner.sendGhostVerificationByEmail(arguments.verificationEmailData)>
					</cfif>
				</cfif>
				<cfset local["returnStruct"]["DBLastName"] = local.qryGetOtherCompanyDuplicate.fldLastName>
				<cfset local["returnStruct"]["ghostParentID"] = local.qryGetOtherCompanyDuplicate.fldUser_ID>
				<cfset local["returnStruct"]["Flag"] = -1>
			<cfelse>
				<cfquery datasource="#application.dsn#">
					UPDATE tblUser SET fldEmail1 = NULL WHERE fldUser_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qryGetOtherCompanyDuplicate.fldUser_ID#">;
					UPDATE tblUser SET fldEmail1 = NULL WHERE fldGhostParentID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qryGetOtherCompanyDuplicate.fldUser_ID#">;
				</cfquery>
				<cfset request.UserManager.saveUserNotes(local.qryGetOtherCompanyDuplicate.fldUser_ID, trim(local.qryGetOtherCompanyDuplicate.fldEmail1) & ' email address was removed from this inactive account as a new account is created with the same email.') />
				<cfset local["returnStruct"]["Flag"] = 0>
			</cfif>
			<cfreturn local["returnStruct"]>
		<cfelseif local.qryGetOtherCompanyDuplicate.recordCount>
			<cfset local["returnStruct"]["Flag"] = 1>
			<cfset local["returnStruct"]["DifferentLastname"] = 1>
			<cfreturn local["returnStruct"]>
		</cfif>

		<cfset local["returnStruct"]["Flag"] = 0>
		<cfreturn local["returnStruct"]>
	</cffunction>

	<cffunction name="getGhostAccountForAUser" access="public" returnformat="plain" returntype="Numeric">
		<cfargument name="UserID" required="true" hint="User ID of the current user.">
		<cfargument name="CompanyID" required="true" hint="Company which we need to check ghost exists or not.">
		<cfargument name="allNotDeleted" required="false" hint="Include account active 1,2 in the check.">
		<cfset var local = structNew()>

		<cfquery name="local.qryGetUser" datasource="#application.dsn#">
			SELECT fldUser_ID, fldGhostParentID FROM tblUser WHERE fldUser_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.UserID#">
		</cfquery>

		<cfquery name="local.qryGetGhostAccount" datasource="#application.dsn#">
			<cfif val(local.qryGetUser.fldGhostParentID) EQ 0>
				SELECT
					U.fldUser_ID
				FROM
					tblUser U
				WHERE
					U.fldGhostParentID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.UserID#">
					AND
					U.fldUserCompanyID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CompanyID#">
					<cfif structKeyExists(arguments, 'allNotDeleted') AND val(arguments.allNotDeleted)>
						AND U.fldAccountActive IN (1,2)
					<cfelse>
						AND U.fldAccountActive = 2
					</cfif>
			<cfelse>
				SELECT
					U.fldUser_ID
				FROM
					tblUser U
				WHERE
					(
						U.fldUser_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qryGetUser.fldGhostParentID#">
						OR
						U.fldGhostParentID = <cfqueryparam cfsqltype="cf_sql_integer" value="#local.qryGetUser.fldGhostParentID#">
					)
					AND
					U.fldUserCompanyID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.CompanyID#">
					<cfif structKeyExists(arguments, 'allNotDeleted') AND val(arguments.allNotDeleted)>
						AND U.fldAccountActive IN (1,2)
					<cfelse>
						AND U.fldAccountActive = 2
					</cfif>
			</cfif>
		</cfquery>

		<cfreturn val(local.qryGetGhostAccount.fldUser_ID)>
	</cffunction>

	<cffunction name="checkSecurityCode" access="remote" returnformat="plain">
		<cfargument name="securtiyCode" type="string" required="false" default="">
		<cfargument name="companyID" type="string" required="false" default="">

		<cfset local.PurgeCode = application.sysPurgeSecurityCode>
		<cfif val(arguments.companyID) AND isNumeric(arguments.companyID) AND len(trim(arguments.securtiyCode))>
			<cfquery name="local.qrycheckPurgeCode" datasource="#application.dsn#">
				SELECT
					UCD.fldPurgeCode,
					<cfif listFindNoCase(request.cadminrole,'clientsenioradmin') OR listFindNoCase(request.cadminrole,'superadmin') OR listFindNoCase(request.cadminrole,'bisadmin')>
						(	SELECT 
								fldPurgeCode 
							FROM 
								tblusercompanydetails 
							WHERE 
								fldUserCompanyID = <cfqueryparam value="#session.loginUsercompanyID#" cfsqltype="integer">
						) AS seniorClientAdminPurgeCode
					<cfelse>
						NULL AS seniorClientAdminPurgeCode
					</cfif>
				FROM
					tblusercompanydetails UCD
					INNER JOIN tblusercompany UC ON UC.fldUserCompany_ID = UCD.fldUserCompanyID
				WHERE
					UCD.fldUserCompanyID = <cfqueryparam value="#arguments.companyID#" cfsqltype="integer">
					AND UC.fldActive = 1
			</cfquery>
			<cfif len(trim(local.qrycheckPurgeCode.fldPurgeCode))>
				<cfset local.PurgeCode = local.qrycheckPurgeCode.fldPurgeCode>
			</cfif>
		</cfif>
		<!--- Validate with global purge code only for BIS Admins --->
		<cfset local.bisAdminCode = listFindNoCase(request.cadminrole,'superadmin') OR listFindNoCase(request.cadminrole,'bisadmin') ? application.sysPurgeSecurityCode : ''>
		<cfset local.clientSeniorAdminCode = listFindNoCase(request.cadminrole,'clientsenioradmin') OR listFindNoCase(request.cadminrole,'superadmin') OR listFindNoCase(request.cadminrole,'bisadmin') ? local.qrycheckPurgeCode.seniorClientAdminPurgeCode : ''>
		<cfreturn (len(trim(arguments.securtiyCode)) AND (arguments.securtiyCode EQ local.PurgeCode OR arguments.securtiyCode EQ local.bisAdminCode OR arguments.securtiyCode EQ local.clientSeniorAdminCode)) ? 1 : 0>
	</cffunction>

	<!--- BEGIN : RRK :: BIS - LMS - Refunds for Online Courses (Non-billable) : BIS-3161 --->
	<cffunction name="roundDownPrice" access="public" returntype="numeric">
		<cfargument name="value" required="true">
		<cfargument name="format" required="false" default="_.__">
		<cfreturn NumberFormat(Int(arguments.value*100)/100, arguments.format)>
	</cffunction>
	<!--- END : RRK :: BIS - LMS - Refunds for Online Courses (Non-billable) : BIS-3161 --->

	<!--- BEGIN: Actsafe - LMS - Add client's Terms & Conditions to the Terms and Conditions Page above the BIS terms and conditions BIS-3718 7/31/2017 TV0119 --->
	<cffunction name="CustomizableLanguageEntry" access="public" returntype="any">
		<cfargument name="LanguageID" required="false" type="numeric" default = 0>
		<cfargument name="Action" required="true" type="string">
		<cfargument name="LabelName" required="true" type="string">
		<cfargument name="NonCustomizableLanguageContent" required="false" default="0">
		<!---BEGIN: Language changes in notification Expire Course center :B1994--->
		<cfargument name="notificationTypeID" required="false" default="0">
		<!---END: Language changes in notification Expire Course center :B1994--->
		<cfargument name="noDefaultContent" required="false" default="0">
		<cfargument name="nonCustomizableLangAction" required="false" default="">
		<cfquery name="local.getLanguageContent" datasource="#application.dsn#">
			SELECT
				CASE WHEN IFNULL(fldLabelValue, '') <> ''
				THEN
					fldLabelValue
				ELSE
					fldLabelText
				END AS LanguageContent,
				fldSysLanguageID
			FROM
				tblsyslanguagecontent
			WHERE
				<cfif arguments.NonCustomizableLanguageContent eq 1><!---BIS-3290 - BIS-Admin-Add optional feature icons in the Admin tab (non-billable): TV0193--->
					fldAction = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Action#">
				<cfelse>
					fldCustomizableLanguageContent = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.Action#">
				</cfif>
				<cfif val(arguments.LanguageID)>
					AND fldSysLanguageID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.LanguageID#">
				</cfif>
				AND fldLabelName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LabelName#">
		</cfquery>
		<cfif (local.getLanguageContent.recordCount GT 0 
			AND len(trim(local.getLanguageContent.LanguageContent))
			) OR arguments.noDefaultContent><!--- 7,8,9 Dont have default language entry  --->
			<cfif val(arguments.LanguageID)>
				<cfreturn local.getLanguageContent.LanguageContent>
			<cfelse>
				<cfreturn local.getLanguageContent>
			</cfif>
		<cfelse>
			<cfquery name="local.getLanguageName" datasource="#application.dsn#">
				SELECT 
					fldLanguage
				FROM
					tblsyslanguage
				WHERE
					fldSysLanguage_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.LanguageID#">
			</cfquery>
			<cfif len(trim(arguments.nonCustomizableLangAction))>
				<cfset local.action = arguments.nonCustomizableLangAction>
			<cfelseif arguments.notificationTypeID EQ 10>
				<cfset local.action = 'bisadmin.AddManager'>
			<cfelseif arguments.notificationTypeID EQ 3>
				<cfset local.action = 'bisadmin.CourseNotificationEmail'>
			<cfelseif arguments.labelName EQ "lblEventChatroomInstructionsSentence">
				<cfset local.action = "classroom.course">
			<cfelse>
				<cfset local.action = 'mailContent'>
			</cfif>
			<cftry>
				<cfset local.contents = evaluate("application.stLang.#local.getLanguageName.fldLanguage#.#local.action#.#arguments.LabelName#")>
				<cfcatch>
					<cfreturn ''>
				</cfcatch>
			</cftry>
			<cfreturn local.contents>
		</cfif>
		<!---END: Language changes in notification Expire Course center :B1994--->
	</cffunction>
	<!--- END: Actsafe - LMS - Add client's Terms & Conditions to the Terms and Conditions Page above the BIS terms and conditions BIS-3718 7/31/2017 TV0119 --->
	<cffunction name="getCustomOrDefaultLanguageEntry" access="public" returntype="string">
		<cfargument name="customAction" required="true" type="string">
		<cfargument name="defaultAction" required="true" type="string">
		<cfargument name="LabelName" required="true" type="string">
		
		<cfquery name="local.getLanguageContent" datasource="#application.dsn#">
			SELECT
				fldSysLanguageID,
				CASE WHEN IFNULL(fldLabelValue, '') <> ''
				THEN
					fldLabelValue
				ELSE
					fldLabelText
				END AS LanguageContent,
				fldAction,
				fldCustomizableLanguageContent
			FROM
				tblsyslanguagecontent
			WHERE
				fldLabelName = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.LabelName#">
				AND (
					fldCustomizableLanguageContent = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.customAction#">
					<cfif len(trim(arguments.defaultAction))>
						OR fldAction = <cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.defaultAction#">
					</cfif>
				)
		</cfquery>
		<cfset local.resultArr= []>
		<cfset local.defaultStr = {}>
		<cfset local.customStr = {}>
		<cfset local.resultStruct = {}>
		<cfloop query="local.getLanguageContent">
			<cfif len(trim(local.getLanguageContent.fldAction))>
				<cfset local.defaultStr[local.getLanguageContent.fldSysLanguageID] = local.getLanguageContent.LanguageContent>
			<cfelse>
				<cfset local.customStr[local.getLanguageContent.fldSysLanguageID] = local.getLanguageContent.LanguageContent>
			</cfif>
		</cfloop>
		<cfset local.resultStruct["defaults"] = local.defaultStr>
		<cfset local.resultStruct["custom"] = local.customStr>
		<cfset ArrayAppend(local.resultArr, local.resultStruct)>
		<cfreturn serializeJSON(local.resultArr)>
	</cffunction>

	<cffunction name="getCustomOrDefaultLanguageEntryofLabels" access="public" returntype="string" hint="To Get Custom OR Default Language Entries of Multiple Labels">
		<cfargument name="customAction" required="true" type="string">
		<cfargument name="defaultAction" required="true" type="string">
		<cfargument name="labels" required="true" type="array">
		<cfset local.labelStruct = {}>
		<cfloop array="#arguments.labels#" item="local.item">
			<cfset local.labelStruct[local.item] = deserializeJSON(getCustomOrDefaultLanguageEntry(customAction=arguments.customAction, defaultAction=arguments.defaultAction, LabelName=local.item))>
		</cfloop>
		<cfreturn serializeJSON(local.labelStruct)>
	</cffunction>
	<cffunction name="getAssessmentVoucherUsedCount">
		<cfargument name="fldUserID">
		<cfargument name="fldVoucherCode">

		<cfset local.GhostUserDetails = request.UserManager.getGhostAccountProfiles(UserID = arguments.fldUserID)>
		<cfif local.GhostUserDetails.recordCount>
			<cfset local.TotalUserList = listAppend(valueList(local.GhostUserDetails.fldUser_ID), arguments.fldUserID)>
		<cfelse>
			<cfset local.TotalUserList = arguments.fldUserID>
		</cfif>

		<cfquery name="local.qGetVoucherNotStartedInProg" datasource="#application.dsn#">
			SELECT
				1
			FROM
				tblassessmentformpermission AFP
				INNER JOIN tblusercoursevoucher UCV ON UCV.fldUserCourseVoucher_ID = AFP.fldContentCode
				LEFT JOIN tblassessmentformhistory AFH ON AFH.fldSysCoursePermissionID = AFP.fldAssessmentFormPermission_ID
				AND AFH.fldUserID = AFP.fldUserID
				AND AFH.fldAssessmentFormID = AFP.fldAssessmentFormPermissionFormID
			WHERE
				UCV.fldVoucherCode = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.fldVoucherCode#">
				AND AFP.fldUserID IN (<cfqueryparam cfsqltype="cf_sql_integer" value="#local.TotalUserList#" list="true">)
				AND AFP.fldActive = 1
				AND (
					AFH.fldStatus IS NULL
					OR AFH.fldStatus = 'inprogress'
				)
		</cfquery>
		<cfreturn local.qGetVoucherNotStartedInProg.recordCount>
	</cffunction>

	<cffunction name="initApplication">
		<cfif application.appMode EQ 'Production'>
			<cfset local.IpArray = application.fwUtilService.getCFServerIP()>
			<cfloop array="#local.IpArray#" index="local.IpNumber">
				<cfhttp method="Get" url="http://#local.IpNumber#/index.cfm?action=home.loginForm&reinitapp=1">
			</cfloop>
		<cfelse>
			<cfhttp method="Get" url="http://#cgi.HTTP_HOST#/index.cfm?action=home.loginForm&reinitapp=1">
		</cfif>
	</cffunction>

	<cffunction name="getGhostParentID" access="public" output="true" returntype="any">
		<cfargument name="userid">
		<cfquery name="local.getParentuser" datasource="#application.dsn#">
			SELECT fnGetGhostParentID(<cfqueryparam value="#arguments.userid#" cfsqltype="cf_sql_integer">) AS parentID
		</cfquery>
		<cfreturn local.getParentuser.parentID>
	</cffunction>
	<cffunction name="createNetworkghostAccount" access="public" description="to create a ghost account for the network purchase case.">
		<cfargument name="userid" type="numeric">
		<cfargument name="EventCompanyID" type="numeric">
		<cfargument name="refreshindex" type="boolean" required="false" default="true">

		<cfset local.NewGhostParentUsersID = getGhostParentID(arguments.userid)>
		<cfquery name="local.qryGetCompanyNodeID" datasource="#application.dsn#">
			SELECT fldClassroomNodeID
			FROM tblUserCompany
			WHERE
				fldUserCompany_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.EventCompanyID#">
		</cfquery>
		<cfset local.userobj = request.UserManager.getUser(arguments.userid)>
		<cfset local.returnStr = application.ManageUsers.AddNewGhostUser(
			DbSourse 			= application.dsn,
			LanguagePref 		= len(local.userobj.getLanguagePref()) ? local.userobj.getLanguagePref() : 1,
			UserCompany 		= arguments.EventCompanyID,
			UserCompanyGroup 	= local.qryGetCompanyNodeID.fldClassroomNodeID,
			FirstName 			= local.userobj.getFirstName(),
			MiddleName 			= local.userobj.getMiddleName(),
			LastName 			= local.userobj.getLastName(),
			Address 			= local.userobj.getAddress1(),
			City 				= local.userobj.getCity(),
			ZipPostalCode 		= local.userobj.getZipPostalCode(),
			Phone1 				= local.userobj.getPhone1(),
			Phone2 				= local.userobj.getPhone2(),
			Email 				= local.userobj.getEmail1(),
			SendEmail 			= local.userobj.getSendEmail(),
			StateID 			= local.userobj.getStateID(),
			Country 			= local.userobj.getCountry(),
			VerifiedEmail 		= local.userobj.getVerifiedEmail(),
			NoEmail 			= val(local.userobj.getNoEmail()),
			BirthDateDemographics = local.userobj.getBirthDateDemographics(),
			GhostParentID 		= local.NewGhostParentUsersID,
			Phone3 				= local.userobj.getPhone3(),
			Email2 				= local.userobj.getEmail2(),
			VerifiedEmail2 		= val(local.userobj.getVerifiedEmail2()),
			NoEmail2 			= val(local.userobj.getNoEmail2()),
			refreshindex = arguments.refreshindex,
			CollectorNumber 	= local.userobj.getCollectorNumber()
		)>
		<cfreturn local.returnStr>
	</cffunction>

	<cffunction name="recordTemplatePathUsage" access="public" returntype="void">
		<cfargument name="template" type="string" required="true">
		<cfif val(application?.trackLegacyCFMTemplateUsage) EQ 1>
			<cfquery datasource="#application.dsn#">
				UPDATE tblCFTemplateTracking
				SET
					fldAccessCount = fldAccessCount+1,
					fldLastAccessOn = NOW(),
					fldAccessedBy = <cfqueryparam value="#val(session?.loginUserID)#" null="#val(session?.loginUserID) EQ 0#" cfsqltype="integer">,
					fldLastAccessedFrom = <cfqueryparam value="#left(cgi.HTTP_URL, 1024)#" cfsqltype="varchar">
				WHERE
					fldTemplatePath = <cfqueryparam cfsqltype="varchar" value="#arguments.template#">
			</cfquery>
		</cfif>
	</cffunction>
</cfcomponent>