SUM(
    0.5 *
    (
        1 / (1 + EXP(0.4 * (
            CASE 
                WHEN "PropType" = 'Alzheimer' THEN 
                    CASE 
                        WHEN FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) <> 0 
                        THEN COUNT(DISTINCT IncidentId) / FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) * 1000.0 - 19 
                        ELSE 0.0 
                    END
                WHEN "PropType" = 'Personal Care' THEN 
                    CASE 
                        WHEN FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) <> 0 
                        THEN COUNT(DISTINCT IncidentId) / FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) * 1000.0 - 14 
                        ELSE 0.0 
                    END
                WHEN "PropType" = 'Assisted Living' THEN 
                    CASE 
                        WHEN FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) <> 0 
                        THEN COUNT(DISTINCT IncidentId) / FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) * 1000.0 - 14 
                        ELSE 0.0 
                    END
                ELSE 
                    CASE 
                        WHEN FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) <> 0 
                        THEN COUNT(DISTINCT IncidentId) / FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) * 1000.0 - 15 
                        ELSE 0.0 
                    END
            END
        ))) +
        1 / (1 + EXP(0.4 * (
            CASE 
                WHEN "PropType" = 'Alzheimer' THEN 
                    CASE 
                        WHEN FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) <> 0 
                        THEN COUNT(DISTINCT IncidentId) / FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) * 1000.0 - 9 
                        ELSE 0.0 
                    END
                WHEN "PropType" = 'Personal Care' THEN 
                    CASE 
                        WHEN FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) <> 0 
                        THEN COUNT(DISTINCT IncidentId) / FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) * 1000.0 - 6 
                        ELSE 0.0 
                    END
                WHEN "PropType" = 'Assisted Living' THEN 
                    CASE 
                        WHEN FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) <> 0 
                        THEN COUNT(DISTINCT IncidentId) / FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) * 1000.0 - 6 
                        ELSE 0.0 
                    END
                ELSE 
                    CASE 
                        WHEN FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) <> 0 
                        THEN COUNT(DISTINCT IncidentId) / FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) * 1000.0 - 7.5 
                        ELSE 0.0 
                    END
            END
        ))) +
        CASE 
            WHEN "PropType" = 'Alzheimer' THEN 0.05 
            WHEN "PropType" = 'Personal Care' THEN 0.15 
            WHEN "PropType" = 'Assisted Living' THEN 0.15 
            ELSE 0.1 
        END * (1 / (1 + EXP(0.4 * (
            CASE 
                WHEN FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) <> 0 
                THEN COUNT(DISTINCT IncidentId) / FLOOR(SUM(DISTINCT RegTotalResidents) / 10000.0) * 1000.0 
                ELSE 0.0 
            END
        ))))
    )
)