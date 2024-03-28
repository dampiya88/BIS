<cfset application.util.recordTemplatePathUsage(template=getCurrentTemplatePath())>
<cfoutput>
<html>
	<head>
    <style>
      h1{
        font-family: sans-serif;
        font-size: 25px;
        width: 100%;
        text-align: center;
      }
    </style>
	</head>
  <body>
    <h1>There was an error while loding content. Please restart your course to continue.</h1>
  </body>
</html>
</cfoutput>