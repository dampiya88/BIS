SET @query:= (SELECT CASE WHEN (SELECT 1 FROM tbladminactions WHERE fldaction = 'cv.assessmentforms')
THEN
  "SELECT('Aleady Exists') AS status;"
ELSE
  "INSERT INTO tbladminactions (fldaction, fldactive) VALUES ('cv.assessmentforms', 1)"
END);
PREPARE stmt_name FROM @query;
EXECUTE stmt_name;
	
SET @query:= (SELECT CASE WHEN (SELECT 1 FROM tbladminactions WHERE fldaction = 'trm.topiclinks')
THEN
  "SELECT('Aleady Exists') AS status;"
ELSE
  "INSERT INTO tbladminactions (fldaction, fldactive) VALUES ('trm.topiclinks', 1)"
END);
PREPARE stmt_name FROM @query;
EXECUTE stmt_name;

SET @query:= (SELECT CASE WHEN (SELECT 1 FROM tbladminactions WHERE fldaction = 'equipment.admin')
THEN
  "SELECT('Aleady Exists') AS status;"
ELSE
  "INSERT INTO tbladminactions (fldaction, fldactive) VALUES ('equipment.admin', 1)"
END);
PREPARE stmt_name FROM @query;
EXECUTE stmt_name;

SET @query:= (SELECT CASE WHEN (SELECT 1 FROM tbluserroleactionaccess WHERE fldadminactionid = (SELECT fldAdminAction_Id FROM tbladminactions WHERE fldaction = "cv.assessmentforms") LIMIT 1)
THEN
  "SELECT('Aleady Exists') AS status;"
ELSE
  "INSERT INTO tbluserroleactionaccess (
		fldadminactionId, fldsysuserroleID, fldactive)
		(SELECT fldadminaction_id,
				flduserrole_ID,
				1
			FROM tbladminactions
			LEFT JOIN tblsysuserrole ON flduserrole_ID IN (33,46,42,45,75,64,63,7,78,45) 
			WHERE fldaction = 'cv.assessmentforms')"
END);
PREPARE stmt_name FROM @query;
EXECUTE stmt_name;

SET @query:= (SELECT CASE WHEN (SELECT 1 FROM tbluserroleactionaccess WHERE fldadminactionid = (SELECT fldAdminAction_Id FROM tbladminactions WHERE fldaction = "trm.topiclinks") LIMIT 1)
THEN
  "SELECT('Aleady Exists') AS status;"
ELSE
  "INSERT INTO tbluserroleactionaccess (
		fldadminactionId, fldsysuserroleID, fldactive)
		(SELECT fldadminaction_id,
				flduserrole_ID,
				1
			FROM tbladminactions
			LEFT JOIN tblsysuserrole ON flduserrole_ID IN (45,7,46,42,33,49,68,69,81,82,78,63) 
			WHERE fldaction = 'trm.topiclinks')"
END);
PREPARE stmt_name FROM @query;
EXECUTE stmt_name;

SET @query:= (SELECT CASE WHEN (SELECT 1 FROM tbluserroleactionaccess WHERE fldadminactionid = (SELECT fldAdminAction_Id FROM tbladminactions WHERE fldaction = "equipment.admin") LIMIT 1)
THEN
  "SELECT('Aleady Exists') AS status;"
ELSE
  "INSERT INTO tbluserroleactionaccess (
		fldadminactionId, fldsysuserroleID, fldactive)
		(SELECT fldadminaction_id,
				flduserrole_ID,
				1
			FROM tbladminactions
			LEFT JOIN tblsysuserrole ON flduserrole_ID IN (33,46,42,7,63,45,78,49,60,62) 
			WHERE fldaction = 'equipment.admin')"
END);
PREPARE stmt_name FROM @query;
EXECUTE stmt_name;