USE Pharma_Intelligence;
GO

/* Market intelligence is therapeutic-area-level, so it has no individual DrugID. */
ALTER TABLE DWH.FACT_DRUG_EVENTS
ALTER COLUMN DrugID int NULL;
GO
