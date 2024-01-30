  --SELECT DISTINCT lp.hmy                  hmy,       
  --                lp.ListOptionCode       sCode,       
  --                lp.ListOptionName  sName      
  select distinct *
  FROM listoption lp       
 -- WHERE lp.listname = 'CareLevel'    
 where ListName ='MoveOutReason'
 order by ListOptionName