USE Pharma_Intelligence;
GO

CREATE TABLE STG.MAP_DRUG_ALIAS (
    DrugAliasID int IDENTITY(1,1) NOT NULL PRIMARY KEY,
    SourceSystem nvarchar(100) NOT NULL,
    SourceDrugName nvarchar(500) NOT NULL,
    DrugID int NOT NULL,
    AliasType nvarchar(50) NOT NULL,
    IsActive bit NOT NULL CONSTRAINT DF_MAP_DRUG_ALIAS_IsActive DEFAULT 1,
    CONSTRAINT UQ_MAP_DRUG_ALIAS UNIQUE (SourceSystem, SourceDrugName),
    CONSTRAINT FK_MAP_DRUG_ALIAS_DRUG FOREIGN KEY (DrugID)
        REFERENCES DWH.DIM_DRUG(DrugID)
);
GO
