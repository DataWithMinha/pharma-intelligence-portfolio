USE Pharma_Intelligence;
GO

-- Mirrors Products_filtered_final25_v2.csv exactly. Values remain text in RAW.
IF OBJECT_ID(N'RAW.RAW_FDA_PRODUCTS', N'U') IS NULL
BEGIN
    CREATE TABLE RAW.RAW_FDA_PRODUCTS (
        Ingredient nvarchar(max) NULL,
        DF_Route nvarchar(max) NULL,
        TradeName nvarchar(max) NULL,
        Applicant nvarchar(max) NULL,
        Strength nvarchar(max) NULL,
        ApplType nvarchar(max) NULL,
        ApplNo nvarchar(max) NULL,
        ProductNo nvarchar(max) NULL,
        TECode nvarchar(max) NULL,
        ApprovalDate nvarchar(max) NULL,
        RLD nvarchar(max) NULL,
        RS nvarchar(max) NULL,
        ProductType nvarchar(max) NULL,
        ApplicantFullName nvarchar(max) NULL
    );
END;
GO
