USE Pharma_Intelligence;
GO

/*
    Populate a reusable calendar dimension for all project events.
    Range covers historical FDA records and future patent-expiry dates.
*/
DECLARE @StartDate date = '20000101';
DECLARE @EndDate date = '20401231';
DECLARE @CurrentDate date = @StartDate;

WHILE @CurrentDate <= @EndDate
BEGIN
    INSERT INTO DWH.DIM_DATE (
        DateID,
        FullDate,
        CalendarYear,
        CalendarQuarter,
        CalendarMonth,
        MonthName
    )
    SELECT
        CONVERT(int, CONVERT(char(8), @CurrentDate, 112)),
        @CurrentDate,
        DATEPART(year, @CurrentDate),
        DATEPART(quarter, @CurrentDate),
        DATEPART(month, @CurrentDate),
        DATENAME(month, @CurrentDate)
    WHERE NOT EXISTS (
        SELECT 1
        FROM DWH.DIM_DATE d
        WHERE d.FullDate = @CurrentDate
    );

    SET @CurrentDate = DATEADD(day, 1, @CurrentDate);
END;
GO

SELECT
    COUNT(*) AS DateRows,
    MIN(FullDate) AS FirstDate,
    MAX(FullDate) AS LastDate
FROM DWH.DIM_DATE;
GO
