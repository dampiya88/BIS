<cfset application.util.recordTemplatePathUsage(template=getCurrentTemplatePath())>
<cftry>
  <cfmail from="scormwrapper@bistrainer.com" to="sachin@bistraining.ca" subject="Scorm Wrapper Data" type="html">
    <cfdump var="#url#">
    <Cfdump var="#cgi#">
    <cfdump var="#GetHttpRequestData()#">
  </cfmail>
  <cfoutput>
    <div style="float: left;width: 100%;text-align: center;padding: 0px 30px;font-size: 25px;">Loading Course...</div>
  </cfoutput>
  <cfset error = StructNew()>
  <cfset repostCompletedResult = 0>
  <cfif structKeyExists(url, 'key') AND structKeyExists(url, 'employeeid') AND structKeyExists(url, 'username')>
    <cfif len(trim(url.key))>
      <cfset keyString = toString(toBinary(url.key))>
      <cfset keyData = decrypt(keyString, 'Sc0rmWr@pP3r')>
      <cfif listLen(keyData, '~~') EQ 2>
        <cfset keyArray = listToArray(keyData, '~~')>
        <cfset courseid = keyArray[1]> 
        <cfset companyidentifier = keyArray[2]>
        <cfset employeeid = url.employeeid>
        <cfif Find(",",url.username)>
          <cfset FirstName = Trim(ListFirst(url.username, ','))>
          <cfset LastName = Trim(ListLast(url.username, ','))>
        <cfelse>
          <cfset FirstName = Trim(ListFirst(url.username, ' '))>
          <cfset LastName = Trim(ListLast(url.username, ' '))>
        </cfif>
        <cfset refererURL = cgi.http_referer>
        <cfif len(trim(refererURL))>
          <cfset refererURL = replace(refererURL, '//','~~','all')>
          <cfset httpPart = ListFirst(refererURL, '~~')>
          <cfset hostName = ListFirst(ListLast(refererURL, "~~"),"/")>
          <cfset originURL = httpPart & "//" & hostName>
        <cfelse>
          <cfset originURL = ''>
        </cfif>
        <cfif len(trim(companyidentifier)) NEQ 0>
          <cfset companyObj = request.CompanyManager.GetCompanyByUniqueIdentifier(companyidentifier)>
          <cfif companyObj.getID() EQ 2354 and len(trim(originURL)) EQ 0>
            <cfset originURL = 'https://matrixservice.csod.com'>
          </cfif>
          <cfif companyObj.getID() EQ 0>
          <cfset error["CompanyIdentifier"] = "CompanyIdentifier is invalid.">
          <cfelseif companyObj.getSSONodeID() EQ 0>
            <cfset error["CompanyIdentifier"] = "SSO Node is not defined for the Company.">
          </cfif>
        <cfelse>
          <cfset error["CompanyIdentifier"] = "CompanyIdentifier is not provided.">
        </cfif>
        <cfif StructIsEmpty(error)>
          <cfif len(trim(employeeid)) NEQ 0>
            <cfset userObj = request.UserManager.GetUserByEmployeeID(employeeid,companyObj.getID())>
            <cfif userObj.getID() NEQ 0 AND userObj.getAccountState() EQ 'Pending'>
              <cfset userObj.setAccountState("Active")>
              <cfset userObj.Save()>
            <cfelseif userObj.getID() NEQ 0 AND userObj.getAccountState() NEQ 'Active'>
              <cfset error["EmployeeID"] = "Employee is not active.">
            <cfelseif userObj.getID() NEQ 0 AND userObj.getCompany().getID() NEQ companyObj.getID()>
              <cfset error["EmployeeID"] = "Employee does not belong to the company.">
            </cfif>
          <cfelse>
            <cfset error["EmployeeID"] = "EmployeeID is not provided.">
          </cfif>
        </cfif>
        <cfif StructIsEmpty(error)>
          <cfif len(trim(FirstName)) EQ 0>
              <cfset error["FirstName"] = "FirstName is not provided.">
          </cfif>
          <cfif len(trim(LastName)) EQ 0>
              <cfset error["LastName"] = "LastName is not provided.">
          </cfif>
        </cfif>
        <cfif len(trim(CourseID))>
          <cftry>
            <cfset homeService = createObject("component", "#application.servicePath#.home")>
            <cfset availableinpool = homeService.checkCourseinPool(companyId = companyObj.getID(),courseId = CourseID).availableInPool>
            <cfif availableinpool>
              <cfset courseObj = request.courseManager.GetCourseByID(val(CourseID))>
            <cfelse>
              <cfset error["CourseID"] = 'CourseID is not available in the pool.'>
            </cfif>
            <cfcatch>
              <cfset error["CourseID"] = 'CourseID is invalid. [#cfcatch.Message#]'>
            </cfcatch>
          </cftry>
        </cfif>
        <cfif StructIsEmpty(error)>
          <cfset isNewUser = 0>
          <cfif userObj.getID() EQ 0>
            <cfscript>
              node = request.CompanyNodeManager.GetCompanyNodeByID(companyObj.getSSONodeID());
              newUserObj = request.UserManager.NewUser();
              creator = 0;

              newUserObj.setLanguagePref(1);
              newUserObj.setFirstName(FirstName);
              newUserObj.setLastName(LastName);
              newUserObj.setIDNumber(EmployeeID);
              newUserObj.setStateID(77);
              newUserObj.setCountry(3);
              node.AddUser(User=newUserObj, Creator=creator, IsActive = 1, cadmin = 1, SSOUser = 1);

              newUserObj = request.UserManager.GetUser(newUserObj.getID());
              userObj = newUserObj;
              isNewUser = 1;
            </cfscript>
          </cfif>
          <cfif len(trim(CourseID))>
            <cfif StructIsEmpty(error)>
              <cfset courseList = ''>
              <cfset completedCourse = {}>
              <!--- Try to post results again for completed courses - Kinross --->
              <cfif companyidentifier EQ 'B6722B70-C294-B7B1-AAD5A28AD9BFFF2A' OR companyidentifier EQ 'E2C947C2-C29B-A351-E8EEC9EE61394737'>
                <cfset repostCompletedResult = 1>
              </cfif>
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
                <cfif ArrayLen(Courses.repeatable) GT 0>
                    <cfset i = 0>
                    <cfloop array="#Courses.repeatable#" index="course">
                        <cfset courseList = ListAppend(courseList,course.courseid)>
                    </cfloop>
                </cfif>
                <cfif repostCompletedResult EQ 1>
                  <cfif ArrayLen(Courses.completed) GT 0>
                    <cfset i = 0>
                    <cfloop array="#Courses.completed#" index="course">
                      <cfif companyidentifier EQ 'B6722B70-C294-B7B1-AAD5A28AD9BFFF2A'>
                        <cfset courseList = ListAppend(courseList,course.courseid)>
                        <cfif course.courseid EQ courseObj.getID() AND course.Archive EQ 0>
                          <cfset completedCourse = {}>
                          <cfset completedCourse["error"] = 0>
                          <cfset completedCourse["action"] = "complete">
                          <cfset completedCourse["score"] = Round(course.Score)>
                          <cfif Round(course.Score) GTE course.passmarks>
                            <cfset completedCourse["pass"] = 1>
                          <cfelse>
                            <cfset completedCourse["pass"] = 0>
                          </cfif>
                          <cfset completedCourse["message"] = "Course completed successfully!">
                        </cfif>
                      <cfelse>
                        <!--- Allow second attempt of course if course is expired or failed or archived --->
                        <cfif course.courseid EQ courseObj.getID() AND course.Archive EQ 0 AND Round(course.Score) GTE course.passmarks>
                          <cfset AlreadyCompleted = 1>
                          <cfif structKeyExists(course, 'dateexpiry') AND isDate(course.dateexpiry)>
                            <cfif course.dateexpiry GT dateAdd('d', course.aboutToExpireDays, now())>
                              <cfset AlreadyCompleted = 1>
                            <cfelse>
                              <cfset AlreadyCompleted = 0>
                            </cfif>
                          </cfif>
                          <cfif AlreadyCompleted EQ 1>
                            <cfset courseList = ListAppend(courseList,course.courseid)>
                            <cfset completedCourse = {}>
                            <cfset completedCourse["error"] = 0>
                            <cfset completedCourse["action"] = "complete">
                            <cfset completedCourse["score"] = Round(course.Score)>
                            <cfif Round(course.Score) GTE course.passmarks>
                              <cfset completedCourse["pass"] = 1>
                            <cfelse>
                              <cfset completedCourse["pass"] = 0>
                            </cfif>
                            <cfset completedCourse["message"] = "Course completed successfully!">
                          </cfif>
                        </cfif>
                      </cfif>
                    </cfloop>
                  </cfif>
                </cfif>
              </cfif>
              <cfif courseObj.getActive()>
                <cfif Not ListFind(courseList,courseObj.getID())>
                  <cfset permissionID = request.PermissionManager.GrantPermissionToUserBySSO(
                    CourseID =  courseObj.getID(),
                    User = userObj.getID(),
                    GrantingUser = 0,
                    PassingMarks = val(courseObj.getPassMarks()),
                    NumberOfRepeats = val(courseObj.getECNumberOfRepeats()),
                    addedByMethod = "Permission By SCORM Wrapper"
                  )>
                </cfif>
                <cfif Not StructIsEmpty(completedCourse)>
                  <cfoutput>
                    <script type="text/javascript">
                      var swData = {
                        'error': 0,
                        'action': '#completedCourse.action#',
                        'score': #completedCourse.score#,
                        'pass': #completedCourse.pass#,
                        'message': '#completedCourse.message#'
                      };
                      parent.postMessage(swData, "#originURL#");
                    </script>
                  </cfoutput>
                  <cfabort>
                </cfif>
                <cfset session.scormWrapper = 1>
                <cfset session.originurl = originURL>
                <cfset session.logonURL = "https://#cgi.http_host#/scormwrapper_error.cfm">
                <cfset userObj.initSession(userId= userObj.getId(), isScormWrapper = 1)>
                <cflocation url="https://#cgi.http_host#/v1/index.cfm?action=learner.launchcourse&id=#courseObj.getID()#" addtoken="yes">
              <cfelse>
                  <cfset error["CourseID"] = 'CourseID is not Active.'>
              </cfif>
            </cfif>
          <cfelse>
            <cfset error['CourseID'] = "Course ID was not provided">
          </cfif>
        </cfif>
      </cfif>
    </cfif> 
  </cfif>
  <cfcatch>
    <cfset error = cfcatch>
  </cfcatch>
</cftry>
<cfoutput>
  <cfif StructIsEmpty(error)>
    <h1>Error while loading content.</h1>
  <cfelse>
    <cfloop collection="#error#" item="item">
      <p>#item# : #error[item]#</p>
    </cfloop>
  </cfif>
</cfoutput>
<cfmail from="scormwrapper@bistrainer.com" to="sachin@bistraining.ca" subject="Scorm Wrapper Issue" type="html">
  <cfdump var="#error#">
  <cfdump var="#url#">
</cfmail>