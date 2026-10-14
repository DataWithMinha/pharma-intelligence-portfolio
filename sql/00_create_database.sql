USE master;
GO

IF DB_ID(N'Pharma_Intelligence') IS NULL
BEGIN
    CREATE DATABASE Pharma_Intelligence;
END;
GO
