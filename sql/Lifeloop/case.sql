SELECT type,
    CASE 
        WHEN type = 'physical' THEN 1
        WHEN type = 'intellectual' THEN 1
        WHEN type = 'spiritual' THEN 1
        ELSE NULL
    END AS daily_total,
    CASE 
        WHEN type = 'physical' THEN 7
        WHEN type = 'intellectual' THEN 7
        WHEN type = 'spiritual' THEN 7
        WHEN type = 'outings' THEN 2
        WHEN type = 'creative' THEN 2
        WHEN type = 'inmotion' THEN 1
        WHEN type = 'monthlytheme' THEN 1
        ELSE NULL 
    END AS weekly_total
 from SeniorBICustom_lifeloopactivities