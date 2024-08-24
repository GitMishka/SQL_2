WITH cat AS (
    SELECT 
        CASE
            WHEN "subgroup1" = 'Alzheimer' THEN 'ALZ'
            WHEN "subgroup1" = 'Personal Care' THEN 'AL'
            WHEN "subgroup1" = 'Assisted Living' THEN 'AL'
            ELSE 'Combo'
        END AS category, 
        *
    FROM attributes
    WHERE spropname LIKE '%Morning Pointe%' 
    AND spropname NOT IN ('Morning Pointe Foundation', 'Morning Pointe of Owensboro')
)
SELECT 
    CASE 
        WHEN "category" = 'ALZ' THEN "hprop" * .5
        WHEN "category" = 'Combo' THEN "hprop" * .10
        WHEN "category" = 'AL' THEN "hprop" * .13
        ELSE "hprop"
    END AS adjusted_hprop, 
    *
FROM cat;
