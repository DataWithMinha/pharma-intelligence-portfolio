USE Pharma_Intelligence;
GO

INSERT INTO DWH.DIM_EVENT_TYPE (EventTypeID, EventTypeName, Description)
VALUES
    (1, N'Clinical Trial', N'Clinical development study or milestone'),
    (2, N'Regulatory', N'Regulatory submission, designation, or decision'),
    (3, N'Patent', N'Patent filing, grant, expiry, or exclusivity event'),
    (4, N'Market', N'Market size, growth, or competitive-intelligence observation');
GO

INSERT INTO DWH.DIM_THERAPEUTIC_AREA (TherapeuticAreaName, GrowthTier)
VALUES
    (N'Oncology', N'High growth'),
    (N'Immunology', N'High growth'),
    (N'Cardiology', N'Established'),
    (N'Neurology', N'High growth'),
    (N'Endocrinology', N'Established');
GO

INSERT INTO DWH.DIM_COMPANY (CompanyName)
VALUES
    (N'AstraZeneca'), (N'Novartis'), (N'Roche Genentech'), (N'Pfizer'),
    (N'Bristol Myers Squibb'), (N'AbbVie'), (N'Eli Lilly'), (N'Amgen'),
    (N'Bayer'), (N'UCB'), (N'Eisai'), (N'Merck'), (N'Takeda'),
    (N'Boehringer Ingelheim'), (N'Johnson and Johnson'), (N'Sanofi');
GO

INSERT INTO DWH.DIM_DRUG (DrugName, GenericName, TherapeuticAreaID, PrimaryCompanyID)
SELECT v.DrugName, v.GenericName, ta.TherapeuticAreaID, c.CompanyID
FROM (VALUES
    (N'Tagrisso', N'Osimertinib', N'Oncology', N'AstraZeneca'),
    (N'Tarceva', N'Erlotinib', N'Oncology', N'Roche Genentech'),
    (N'Gleevec', N'Imatinib', N'Oncology', N'Novartis'),
    (N'Ibrance', N'Palbociclib', N'Oncology', N'Pfizer'),
    (N'Lynparza', N'Olaparib', N'Oncology', N'AstraZeneca'),
    (N'Xeljanz', N'Tofacitinib', N'Immunology', N'Pfizer'),
    (N'Olumiant', N'Baricitinib', N'Immunology', N'Eli Lilly'),
    (N'Otezla', N'Apremilast', N'Immunology', N'Amgen'),
    (N'Sotyktu', N'Deucravacitinib', N'Immunology', N'Bristol Myers Squibb'),
    (N'Rinvoq', N'Upadacitinib', N'Immunology', N'AbbVie'),
    (N'Lipitor', N'Atorvastatin', N'Cardiology', N'Pfizer'),
    (N'Entresto', N'Sacubitril valsartan', N'Cardiology', N'Novartis'),
    (N'Xarelto', N'Rivaroxaban', N'Cardiology', N'Bayer'),
    (N'Brilinta', N'Ticagrelor', N'Cardiology', N'AstraZeneca'),
    (N'Eliquis', N'Apixaban', N'Cardiology', N'Bristol Myers Squibb'),
    (N'Keppra', N'Levetiracetam', N'Neurology', N'UCB'),
    (N'Aricept', N'Donepezil', N'Neurology', N'Eisai'),
    (N'Maxalt', N'Rizatriptan', N'Neurology', N'Merck'),
    (N'Nurtec ODT', N'Rimegepant', N'Neurology', N'Pfizer'),
    (N'Vyvanse', N'Lisdexamfetamine', N'Neurology', N'Takeda'),
    (N'Farxiga', N'Dapagliflozin', N'Endocrinology', N'AstraZeneca'),
    (N'Januvia', N'Sitagliptin', N'Endocrinology', N'Merck'),
    (N'Jardiance', N'Empagliflozin', N'Endocrinology', N'Boehringer Ingelheim'),
    (N'Invokana', N'Canagliflozin', N'Endocrinology', N'Johnson and Johnson'),
    (N'Amaryl', N'Glimepiride', N'Endocrinology', N'Sanofi')
) v(DrugName, GenericName, TherapeuticAreaName, CompanyName)
JOIN DWH.DIM_THERAPEUTIC_AREA ta ON ta.TherapeuticAreaName = v.TherapeuticAreaName
JOIN DWH.DIM_COMPANY c ON c.CompanyName = v.CompanyName;
GO
