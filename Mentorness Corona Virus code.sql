--Q1. Write a code to check for NULL values--
SELECT * 
FROM [dbo].[(2)Corona Virus Dataset]
WHERE [Province] IS NULL 
OR [Country_Region] IS NULL
OR [Latitude] IS NULL
OR [Longitude] IS NULL
OR [Date] IS NULL 
OR [Deaths] IS NULL
OR [Recovered] IS NULL;

/* Q2. If NULL values are present, update them with zeros for all columns. 
No NULL values where found from the first question, hence there was no need to update the table */

--Q3. Check the total number of rows
SELECT COUNT(*) AS 'Total_Rows'
FROM [dbo].[(2)Corona Virus Dataset];

--Q4. Check what is start_date and end_date
SELECT MIN([Date]) AS 'Start_date', MAX ([Date]) AS 'End_date'
FROM [dbo].[(2)Corona Virus Dataset];

--Q5. Number of Months present in the dataset
SELECT COUNT(DISTINCT MONTH([Date])) AS 'Number_of_Months'
FROM [dbo].[(2)Corona Virus Dataset];

/* The above query counts the number of distinct month present in the dataset without regarding the year. 
But this method will count June 2020 and June 2021 as 1 month. 
To consider the year, so that months from different years will be considered as distinct, use the query below*/

SELECT COUNT(DISTINCT CONCAT(YEAR([Date]), '-', MONTH([Date]))) AS 'Number_of_Months'
FROM [dbo].[(2)Corona Virus Dataset];

--Q6. Find the monthly average for confirmed, deaths, recovered

SELECT AVG([Confirmed]) AS 'Avg_confirmed', AVG([Deaths]) AS 'Avg_death', AVG([Recovered]) AS 'Avg_recovered', MONTH([Date]) AS 'Month_No'
FROM [dbo].[(2)Corona Virus Dataset]
GROUP BY MONTH([Date])
ORDER BY Month_No ASC;

--Q7. Find the most frequent values of confimed, deaths, and recovered each month
WITH MonthlyData AS (
    SELECT YEAR([Date]) AS Year,
    MONTH([Date]) AS Month,
        [Confirmed],
        [Deaths],
        [Recovered]
    FROM [dbo].[(2)Corona Virus Dataset]
),
ConfirmedMode AS (
    SELECT
        Year,
        Month,
        [Confirmed],
        COUNT(*) AS Frequency,
        ROW_NUMBER() OVER (PARTITION BY Year, Month ORDER BY COUNT(*) DESC) AS RowNum
    FROM MonthlyData
    GROUP BY Year, Month, [Confirmed]
),
DeathsMode AS (
    SELECT
        Year,
        Month,
        [Deaths],
        COUNT(*) AS Frequency,
        ROW_NUMBER() OVER (PARTITION BY Year, Month ORDER BY COUNT(*)DESC) AS RowNum
    FROM MonthlyData
    GROUP BY Year, Month, [Deaths]
),
RecoveredMode AS (
    SELECT
        Year,
        Month,
        [Recovered],
        COUNT(*) AS Frequency,
        ROW_NUMBER() OVER (PARTITION BY Year, Month ORDER BY COUNT(*) DESC) AS RowNum
    FROM MonthlyData
    GROUP BY Year, Month, [Recovered]
)
SELECT 
    c.Year,
    c.Month,
    c.confirmed AS MostFrequentConfirmed,
    d.deaths AS MostFrequentDeaths,
    r.recovered AS MostFrequentRecovered
FROM 
    ConfirmedMode AS c
    JOIN DeathsMode AS d ON c.Year = d.Year AND c.Month = d.Month AND c.RowNum = 1
    JOIN RecoveredMode AS r ON c.Year = r.Year AND c.Month = r.Month AND c.RowNum = 1
WHERE
    c.RowNum = 1
    AND d.RowNum = 1
    AND r.RowNum = 1
ORDER BY 
    c.Year, c.Month;

    /*The below query eliminates the year field and takes into consideration just the highest frequent values per month, regardless of the year
    Both queries (the above and below) retrun the same result set for the most frequent values for confirmed, deaths, and recovered fields*/
WITH MonthlyData AS (
    SELECT MONTH([Date]) AS Month,
        [Confirmed],
        [Deaths],
        [Recovered]
    FROM [dbo].[(2)Corona Virus Dataset]
),
ConfirmedMode AS (
    SELECT
        Month,
        [Confirmed],
        COUNT(*) AS Frequency,
        ROW_NUMBER() OVER (PARTITION BY Month ORDER BY COUNT(*) DESC) AS RowNum
    FROM MonthlyData
    GROUP BY Month, [Confirmed]
),
DeathsMode AS (
    SELECT
        Month,
        [Deaths],
        COUNT(*) AS Frequency,
        ROW_NUMBER() OVER (PARTITION BY Month ORDER BY COUNT(*)DESC) AS RowNum
    FROM MonthlyData
    GROUP BY Month, [Deaths]
),
RecoveredMode AS (
    SELECT
        Month,
        [Recovered],
        COUNT(*) AS Frequency,
        ROW_NUMBER() OVER (PARTITION BY Month ORDER BY COUNT(*) DESC) AS RowNum
    FROM MonthlyData
    GROUP BY Month, [Recovered]
)
SELECT 
    c.Month,
    c.confirmed AS MostFrequentConfirmed,
    d.deaths AS MostFrequentDeaths,
    r.recovered AS MostFrequentRecovered
FROM 
    ConfirmedMode AS c
    JOIN DeathsMode AS d ON c.Month = d.Month AND c.RowNum = 1
    JOIN RecoveredMode AS r ON c.Month = r.Month AND c.RowNum = 1
WHERE
    c.RowNum = 1
    AND d.RowNum = 1
    AND r.RowNum = 1
ORDER BY c.Month;

--Q8. Find the minimum value for confirmed, death, and recovered cases per year
SELECT YEAR([Date]) AS 'Year', MIN([Confirmed]) AS 'Min_confirmed' , MIN([Deaths]) AS 'Min_death', MIN([Recovered]) AS 'Min_Recovered'
FROM [dbo].[(2)Corona Virus Dataset]
GROUP BY YEAR([Date]);

--Q9. Find the maximum values of confirmed, deaths, and recovered cases per year
SELECT YEAR([Date]) AS 'Year', MAX([Confirmed]) AS 'Max_confirmed' , MAX([Deaths]) AS 'Max_death', MAX([Recovered]) AS 'Max_Recovered'
FROM [dbo].[(2)Corona Virus Dataset]
GROUP BY YEAR([Date]);

--Q10. The total number of cases confirmed, death, and recovered each month
SELECT MONTH([Date]) AS 'Month_No', SUM([Confirmed]) AS 'Total_confirmed', SUM([Deaths]) AS 'Total_death', SUM([Recovered]) AS 'Total_recovered'
FROM [dbo].[(2)Corona Virus Dataset]
GROUP BY MONTH([Date]) 
ORDER BY MONTH ([Date]);

--Q11. Check how corona virus spread out with respect to confirmed cases(total confirmed caeses, their avg, variance, and STDEV)
WITH MonthlyData AS (
    SELECT 
        DATEPART(YEAR, [Date]) AS Year,
        DATEPART(MONTH, [Date]) AS Month,
        SUM([Confirmed]) AS TotalConfirmedCases
    FROM [dbo].[(2)Corona Virus Dataset]
    GROUP BY DATEPART(YEAR, [Date]), DATEPART(MONTH, [Date])
),
MonthlyStats AS (
    SELECT
        Year,
        Month,
        TotalConfirmedCases,
        AVG(TotalConfirmedCases) OVER (PARTITION BY Month) AS AvgConfirmed,--calculates avg per month
        VAR(TotalConfirmedCases) OVER (PARTITION BY Month) AS VarConfirmed,--calculates variance per month
        STDEV(TotalConfirmedCases) OVER (PARTITION BY Month) AS StdevConfirmed --calculates stdev per month
    FROM MonthlyData
)
SELECT COUNT(*) OVER (PARTITION BY Month) AS DataPointsPerMonth, --Checks the number of values entered each month.Variance and Stdev fields require more than 1 value.
    Year,
    Month,
    TotalConfirmedCases,
    AvgConfirmed,
    COALESCE(VarConfirmed, 0) AS VarConfirmed, -- Replace NULL with 0
    COALESCE(ROUND(StdevConfirmed, 2), 0) AS Stdev_Confirmed -- Replaces NULL WITH 0
FROM MonthlyStats
ORDER BY Year, Month;

--Q12. Check the spread of corona virus in respect to death cases oer month 
WITH MonthlyData AS (
    SELECT 
        DATEPART(MONTH, [Date]) AS Month,
        SUM([Deaths]) AS TotalDeathCases
    FROM [dbo].[(2)Corona Virus Dataset]
    GROUP BY DATEPART(MONTH, [Date])
),
MonthlyStats AS (
    SELECT
        Month,
        TotalDeathCases,
        AVG(TotalDeathCases) OVER (PARTITION BY Month) AS AvgDeaths, --calculates avg per month
        VAR(TotalDeathCases) OVER (PARTITION BY Month) AS VarDeaths, --calculates variance per month 
        STDEV(TotalDeathCases) OVER (PARTITION BY Month) AS StdevDeaths --calculates stdev per month 
    FROM MonthlyData
)
SELECT COUNT(*) OVER (PARTITION BY Month) AS DataPointsPerMonth,
    Month,
    TotalDeathCases,
    AvgDeaths
    VarDeaths,
    COALESCE(ROUND(StdevDeaths, 2), 0) AS Stdev_Deaths--Repalces NULL with 0
FROM MonthlyStats
ORDER BY Month;

--  Q13. Check how corona virus spread in respect to recovered cases
WITH MonthlyData AS (
    SELECT 
        DATEPART(YEAR, [Date]) AS Year,
        DATEPART(MONTH, [Date]) AS Month,
        SUM([Recovered]) AS TotalRecoveredCases
    FROM [dbo].[(2)Corona Virus Dataset]
    GROUP BY DATEPART(YEAR, [Date]), DATEPART(MONTH, [Date])
),
MonthlyStats AS (
    SELECT
        Year,
        Month,
        TotalRecoveredCases,
        AVG(TotalRecoveredCases) OVER (PARTITION BY Month) AS AvgRecovered,--calculates the avg per month 
        VAR(TotalRecoveredCases) OVER (PARTITION BY Month) AS VarRecovered,--calculates the variances per month 
        STDEV(TotalRecoveredCases) OVER (PARTITION BY Month) AS StdevRecovered--calculates the stdev per month 
    FROM MonthlyData
)
SELECT COUNT(*) OVER (PARTITION BY Month) AS DataPointsPerMonth,
    Year,
    Month,
    TotalRecoveredCases,
    AvgRecovered,
    COALESCE(ROUND(VarRecovered, 2),0) AS Var_recovered, --Replaces NULL with 0
    COALESCE(ROUND(StdevRecovered, 2), 0) AS Stdev_recovered --Replaces NULL with 0
FROM MonthlyStats
ORDER BY Year, Month;

--  Q14. Country having the highest number of confirmed cases
SELECT TOP 1 [Country_Region], SUM([Confirmed]) AS HighestConfirmed
FROM [dbo].[(2)Corona Virus Dataset]
GROUP BY [Country_Region]
ORDER BY HighestConfirmed DESC;

--Q15. The country having the lowest number of death cases
SELECT TOP 1 [Country_Region], SUM([Deaths]) AS LowestDeath
FROM [dbo].[(2)Corona Virus Dataset]
GROUP BY [Country_Region]
ORDER BY LowestDeath ASC;

--Q16. Top 5 countries having the highest recovered cases
SELECT TOP 5 [Country_Region], SUM([Recovered]) AS HighestRecovered
FROM [dbo].[(2)Corona Virus Dataset]
GROUP BY [Country_Region]
ORDER BY HighestRecovered DESC;
