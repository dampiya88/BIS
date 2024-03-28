<cfset application.util.recordTemplatePathUsage(template=getCurrentTemplatePath())>


<!--- START: Get google analytic code for the company --->
<cfset variables.GAcategory = 0>
<cfif ((IsDefined('url.category') AND val(url.category) GT 0 AND isValid("integer",url.category)) OR (structKeyExists(session, 'loginusercompanyid') AND session.loginusercompanyid GT 0))>
	<cfquery name="qCompanyGoogleAnalyticCode" datasource="#application.dsn#">
		SELECT
			'' AS fldCommonGoogleAnalyticCode,
			'' AS fldCommonGoogleTagManagerCode,
			'' AS fldCommonGoogleTagHeaderCode
		FROM
			tblusercompany
		WHERE
			<cfif IsDefined('url.category') AND val(url.category) GT 0>
				<cfset variables.GAcategory = url.category>
				fldCWCategoryID = <cfqueryparam cfsqltype="cf_sql_integer" value="#url.category#">
			<cfelseif structKeyExists(session, 'loginusercompanyid') AND session.loginusercompanyid GT 0>
				fldUserCOmpany_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#session.loginusercompanyid#">
			<cfelse>
				0=1
			</cfif>
	</cfquery>
</cfif>
<!--- END: Get google analytic code for the company --->

<cfparam name="cookie.PrivateSiteCurrencyType" default="1">
<cfif IsDefined('FORM.ProdID')>
	<cfset request.Product_ID = FORM.ProdID>
<cfelseif IsDefined ('URL.ProdID') AND isValid("integer",url.ProdID)>
	<cfset request.Product_ID = URL.ProdID>
<cfelseif IsDefined ('FORM.ProdID')>
	<cfset request.Product_ID = FORM.ProdID>
<cfelseif IsDefined ('URL.SKU_ProductID')>
	<cfset request.Product_ID = URL.SKU_ProductID>
<cfelse>
	<cfset request.Product_ID = 0>
</cfif>

<cfif val(request.Product_ID) GT 0 AND isNumeric(request.Product_ID) AND val(variables.GAcategory) GT 0>
	<cfquery name="rsGetProduct" datasource="#application.dsn#">
		SELECT
			P.fldProduct_ID AS product_ID,
			P.fldName AS product_Name,
			P.fldDescription AS product_Description,
			'' AS product_lightbox,
			bisproducts.fldproductsample,
			PCR.fldGoogleAnalyticCode AS product_googleAnalyticCode
		FROM
			tblproduct P
			INNER JOIN tblsku SKU ON SKU.fldProductID = P.fldProduct_ID
			INNER JOIN tblskuprice PP ON PP.fldSKUID = SKU.fldSKU_ID AND PP.fldCurrencyID = <cfqueryparam value="#cookie.PrivateSiteCurrencyType#" cfsqltype="CF_SQL_INTEGER"> AND PP.fldActive = 1
			LEFT JOIN tblproducts bisproducts ON bisproducts.fldecproductid = P.fldProduct_ID
			LEFT JOIN tblproductcompanyrelation PCR ON P.fldProduct_ID = PCR.fldProductID AND PCR.fldProductCompanyID = <cfqueryparam value="#variables.GAcategory#" cfsqltype="CF_SQL_INTEGER"> AND PCR.fldActive = 1
		WHERE
			P.fldProduct_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#request.Product_ID#">
			AND P.fldActive = 1
			AND P.fldShowOnWeb = 1
			/*AND SKU.SKU_ShowWeb = 1*/
	</cfquery>
</cfif>