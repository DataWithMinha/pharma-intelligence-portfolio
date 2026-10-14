USE Pharma_Intelligence;
GO

/* Map source names to the master portfolio drug. Combination products that are
   not the portfolio drug itself are deliberately not included. */
INSERT INTO STG.MAP_DRUG_ALIAS (SourceSystem, SourceDrugName, DrugID, AliasType)
SELECT v.SourceSystem, v.SourceDrugName, d.DrugID, v.AliasType
FROM (VALUES
    (N'ClinicalTrials.gov', N'kappra', N'Keppra', N'Source-name correction'),
    (N'ClinicalTrials.gov', N'nurtec_odt', N'Nurtec ODT', N'Filename alias'),

    (N'FDA', N'APIXABAN', N'Eliquis', N'Generic name'),
    (N'FDA', N'APREMILAST', N'Otezla', N'Generic name'),
    (N'FDA', N'ATORVASTATIN CALCIUM', N'Lipitor', N'Generic name'),
    (N'FDA', N'BARICITINIB', N'Olumiant', N'Generic name'),
    (N'FDA', N'DAPAGLIFLOZIN', N'Farxiga', N'Generic name'),
    (N'FDA', N'DONEPEZIL HYDROCHLORIDE', N'Aricept', N'Generic name'),
    (N'FDA', N'ELIQUIS SPRINKLE', N'Eliquis', N'Brand variant'),
    (N'FDA', N'EMPAGLIFLOZIN', N'Jardiance', N'Generic name'),
    (N'FDA', N'ENTRESTO SPRINKLE', N'Entresto', N'Brand variant'),
    (N'FDA', N'ERLOTINIB HYDROCHLORIDE', N'Tarceva', N'Generic name'),
    (N'FDA', N'IMATINIB MESYLATE', N'Gleevec', N'Generic name'),
    (N'FDA', N'LEVETIRACETAM', N'Keppra', N'Generic name'),
    (N'FDA', N'LEVETIRACETAM IN SODIUM CHLORIDE', N'Keppra', N'Formulation variant'),
    (N'FDA', N'LISDEXAMFETAMINE DIMESYLATE', N'Vyvanse', N'Generic name'),
    (N'FDA', N'OTEZLA XR', N'Otezla', N'Brand variant'),
    (N'FDA', N'RINVOQ LQ', N'Rinvoq', N'Brand variant'),
    (N'FDA', N'RIVAROXABAN', N'Xarelto', N'Generic name'),
    (N'FDA', N'RIZATRIPTAN BENZOATE', N'Maxalt', N'Generic name'),
    (N'FDA', N'SACUBITRIL AND VALSARTAN', N'Entresto', N'Generic name'),
    (N'FDA', N'SITAGLIPTIN PHOSPHATE', N'Januvia', N'Generic name'),
    (N'FDA', N'TICAGRELOR', N'Brilinta', N'Generic name'),
    (N'FDA', N'TOFACITINIB CITRATE', N'Xeljanz', N'Generic name'),
    (N'FDA', N'XELJANZ XR', N'Xeljanz', N'Brand variant')
) v(SourceSystem, SourceDrugName, MasterDrugName, AliasType)
JOIN DWH.DIM_DRUG d ON d.DrugName = v.MasterDrugName
WHERE NOT EXISTS (
    SELECT 1
    FROM STG.MAP_DRUG_ALIAS a
    WHERE a.SourceSystem = v.SourceSystem
      AND a.SourceDrugName = v.SourceDrugName
);
GO
