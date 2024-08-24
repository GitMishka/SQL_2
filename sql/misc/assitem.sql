-- Adjust this query to include a join to the AssessmentItem table
SELECT
  PropName,
  fr.resident,
  unit,
  fr.residentid,
  privacylevel,
  CASE 
    WHEN Reccom = '' AND actual = '' THEN t1.assessmenttypeName
    ELSE fr.assessmenttype
  END assessmenttype,
  CASE 
    WHEN Reccom = '' AND actual = '' THEN t1.assessmentdate
    ELSE fr.assessmentdate
  END assessmentdate,
  CASE 
    WHEN Reccom = '' AND actual = '' THEN t1.ServiceClassName
    ELSE classname
  END classname,
  CASE 
    WHEN Reccom = '' AND actual = '' THEN t1.ServiceClassID
    ELSE fr.classid
  END classid,
  CASE 
    WHEN Reccom = '' THEN '*None Recommended'
    ELSE Reccom
  END Reccom,
  CASE 
    WHEN actual = '' THEN '*None'
    ELSE actual
  END actual,
  ActualCarelevel,
  istatus,
  orderby,
  Discrepancy,
  CASE 
    WHEN Reccom = '' AND actual = '' THEN t1.AssessmentID
    ELSE fr.AssessmentID
  END AssessmentID,
  RecommScore,
  ai.AssessmentItemDescription -- Here we include the description from the AssessmentItem table
FROM #FinalResult fr
LEFT JOIN #temp1 t1 ON t1.residentid = fr.residentid
LEFT JOIN AssessmentItem ai ON ai.AssessmentItemID = t1.AssessmentItemID -- Adjust this join appropriately
ORDER BY 
  CASE WHEN '#OrderBy#' = 'Last Name' THEN fr.resident ELSE unit END, 
  residentid, 
  classid
