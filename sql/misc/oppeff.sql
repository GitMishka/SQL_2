with DVA as (select 
Column3 as Community, 
(AL_PC_Census + ALZ_Census) * DAY(EOMONTH(GETDATE(), -2)) AS ActResidentDays,
(AL_PC_Census_Right + ALZ_Census_Right) * DAY(EOMONTH(GETDATE(), -2)) AS BudResidentDays,
(Total_Resident_Care + Raw_Food - Total_Ancillary_Revenue) as ActualSpend,
(Total_Resident_Care_Right + Raw_Food_Right - Total_Ancillary_Revenue_Right) as BudgetSpend
from dbo.STF),
 
DVAcalc as (select Community, ActualSpend/ActResidentDays as ActSpendPerResDay, BudgetSpend/BudResidentDays as BudSpendPerResDay from DVA),
 
DVAresult as (select Community, ((ActSpendPerResDay - BudSpendPerResDay)/BudSpendPerResDay) as DVA from DVAcalc)
 
SELECT 
    *,(((1 / (1 + EXP(-5 + 30 * r.DVA))) - (1 / (1 + EXP(6 + 10 * r.DVA)))) * 100) AS DVAscore
FROM 
    dbo.STF s left join DVAresult r on s.Column3 = r.Community;