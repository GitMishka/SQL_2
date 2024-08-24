
SELECT
    hprospect,
    hproperty,
    CASE WHEN ActivityID = 52 THEN dtDate ELSE NULL END AS Activity_52,
    CASE WHEN ActivityID = 77 THEN dtDate ELSE NULL END AS Activity_77,
    CASE WHEN ActivityID = 14 THEN dtDate ELSE NULL END AS Activity_14,
    CASE WHEN ActivityID = 5 THEN dtDate ELSE NULL END AS Activity_5,
    CASE WHEN ActivityID = 81 THEN dtDate ELSE NULL END AS Activity_81,
    CASE WHEN ActivityID = 45 THEN dtDate ELSE NULL END AS Activity_45,
    CASE WHEN ActivityID = 76 THEN dtDate ELSE NULL END AS Activity_76
FROM seniorprospecthistory;
SELECT
    hprospect,
    hproperty,
    CASE 
        WHEN ActivityID = 154 THEN dtDate 
        ELSE NULL 
    END AS WebLead,
    CASE 
        WHEN ActivityID IN (1, 84) THEN dtDate 
        ELSE NULL 
    END AS FirstTour,
    CASE 
        WHEN ActivityID = 52 THEN dtDate 
        ELSE NULL 
    END AS ProspectCallIn,
    CASE 
        WHEN ActivityID NOT IN (154, 1, 84, 52) THEN dtDate 
        ELSE NULL 
    END AS AllOther
FROM seniorprospecthistory 