-- Assuming RecurringChargeFromDate is the relevant date for filtering
INSERT INTO #ResidentRecurringCharge (UnitCode, RecurringChargeID, ChargeTypeCode, ChargeTypeDescription, RecurringChargeFromDate, RecurringChargeToDate, RecurringChargeAmount, Billing, PayorID, PayorName, PrivacyLevelCode, ContractTypeCode, RecurringChargeLowIncomeFlag, RateTypeCode, EFTChecked, RecurringChargeEFTFlag, CCChecked, RecurringChargeCCFlag, ccDisabled)
EXEC SeniorRecurringChargeSelect @ResidentID, 'Current'
WHERE RecurringChargeFromDate >= DATEADD(MONTH, -3, GETDATE())
