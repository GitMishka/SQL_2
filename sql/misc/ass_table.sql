-- Assuming AssessmentDate is the relevant date for filtering
select
  r.ResidentID,
  a.AssessmentID,
  at.AssessmentTypeID,
  r.PropertyID
from Assessment a
join AssessmentType at on at.AssessmentTypeID = a.AssessmentTypeID
join #Residents r on r.ResidentID = a.ResidentID
where
  a.AssessmentID in
    (
      select
        max(a.AssessmentID)
      from Assessment a
      join AssessmentType at on at.AssessmentTypeID = a.AssessmentTypeID
      join
      (
        select
          max(a.AssessmentDate) as MaxDate,
          at.AssessmentClass
        from Assessment a
        join AssessmentType at on at.AssessmentTypeID = a.AssessmentTypeID
        where
          a.ResidentID = r.ResidentID and
          a.AssessmentActiveFlag = 1 and
          a.AssessmentCompleteFlag = 1 and
          a.AssessmentDate >= DATEADD(MONTH, -3, GETDATE()) -- Adding the date filter here
        group by
          at.AssessmentClass
      ) m on m.MaxDate = a.AssessmentDate and m.AssessmentClass = at.AssessmentClass
      where
        a.ResidentID = r.ResidentID and
        a.AssessmentActiveFlag = 1 and
        a.AssessmentCompleteFlag = 1
      group by
        at.AssessmentClass
    )
