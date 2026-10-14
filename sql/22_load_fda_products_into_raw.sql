USE Pharma_Intelligence;
GO

BULK INSERT RAW.RAW_FDA_PRODUCTS
FROM 'C:\Users\minha\Downloads\PHARMA INTEL\Products_filtered_final25_v2.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '0x0a',
    CODEPAGE = '65001',
    TABLOCK
);
GO

SELECT COUNT(*) AS RawFdaProductRows
FROM RAW.RAW_FDA_PRODUCTS;
GO
