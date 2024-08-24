SELECT 
    -- Basic Customer Information
    FirstName,
    MiddleInitial,
    LastName,
    Salutation,
    DOB,
        Email,
    CellPhone,
    -- Isolated URL
    CASE 
        WHEN CHARINDEX('https://', notes) > 0 AND CHARINDEX(';', notes, CHARINDEX('https://', notes)) > CHARINDEX('https://', notes)
        THEN SUBSTRING(
            notes,
            CHARINDEX('https://', notes), 
            CHARINDEX(';', notes, CHARINDEX('https://', notes)) - CHARINDEX('https://', notes)
        )
        ELSE NULL
    END AS IsolatedURL,
    -- Contact Information

    HomePhone,
    OfficePhone,
    Fax,
    Address1,
    Address2,
    Address3,
    City,
    State,
    Zip,

    -- Prospect Information
    ProspectFirstName,
    ProspectMiddleInitial,
    ProspectLastName,
    Relationship,
    PrefMoveInDate,
    PreferredBedrooms,

    -- Activity and Status
    SourceName,
    ExtReference,
    InitialActivityType,
    Notes,
    LeadStatus,
    sCallStatus,
    dtCreated,

    -- Additional Details
    CareLevel,
    Agent,
    sGender,
    sPrefMethodOfContact,
    sMotivations,
    sValues,
    sFears,
    sChallenges,
    sInterests,
    sCareNeeds,

     UserDefinedLabel1,
    UserField01,
    UserDefinedLabel2,
    UserField02,
    UserDefinedLabel3,
    UserField03,
    UserDefinedLabel4,
    UserField04,
    UserDefinedLabel5,
    UserField05,
    UserDefinedLabel6,
    UserField06,

    -- Success and Status Indicators
    bSuccess,
    DOBSecure,
    bOKToMail,
    bOKToMassMail,
    bOKToEmail,

    -- Miscellaneous
    SecSourceName,
    sCountry,
    sOtherPropertyCodes,
    UpdateFlag,
    AppointmentEndDate,
    ContactExtReference,
    hProspect,
    sFinancialSituation,
    sDesiredRent,
    sCurrentResidence,
    PropertyCode,
    DupProspect,
    Message

FROM 
    SeniorProspectLeadsImportLog
ORDER BY 
    dtCreated DESC;
