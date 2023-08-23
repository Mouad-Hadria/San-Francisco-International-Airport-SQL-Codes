------------------------------------------------------------------------------- DATA EXPLORATION -------------------------------------------------------------------------------

---- Passenger Count Across the Years

SELECT Year,Sum([Passenger Count]) as 'Count of Passengers' FROM PortfolioProjects.dbo.Air_Traffic
where [Activity Type Code] <> 'Thru / transit' group by year order by 1

---- Allocation of Passengers across Terminals and Gates

DECLARE @total float
SELECT @total = SUM([Passenger count]) 
FROM PortfolioProjects.dbo.Air_traffic where [Activity Type Code] <> 'Thru / transit'

SELECT Terminal,[Boarding Area],SUM([passenger count]) as 'Count of Passengers',
CAST( SUM([passenger count])*100/@total as NUMERIC(36,12)) as 'Percentage' FROM PortfolioProjects.dbo.Air_traffic
where [Activity Type Code] <> 'Thru / transit'
Group by Terminal,[Boarding Area]  order by 1 desc ,3 desc

---- The Progression of Domestic and International Passengers

-- Creating Year Quarters

ALTER TABLE PortfolioProjects.dbo.Air_Traffic
ADD Quarter varchar(6)

UPDATE PortfolioProjects.dbo.Air_Traffic
SET Quarter =
CASE
WHEN Month <=3 then 'Q1'
WHEN Month <=6 then 'Q2'
WHEN Month <=9 then 'Q3'
ELSE 'Q4'
END
FROM PortfolioProjects.dbo.Air_Traffic

--
SELECT year,Quarter,[GEO Summary],SUM([Passenger Count]) as 'Count of Passengers' FROM PortfolioProjects.dbo.Air_Traffic
where [Activity Type Code] <> 'Thru / transit'
Group by year,Quarter,[GEO Summary] order by 1,2,3


---- Percentage Breakdown of Domestic and International Passengers

DECLARE @Total_passengers float;
SELECT  @Total_passengers = sum([Passenger Count])
FROM PortfolioProjects.dbo.Air_Traffic where [Activity Type Code] <> 'Thru / transit'

SELECT [GEO Summary],sum([Passenger Count]) as 'Count of passengers', sum([Passenger Count])*100/@Total_passengers as 'Percentage'
FROM PortfolioProjects.dbo.Air_Traffic
where [Activity Type Code] <> 'Thru / transit'
group by [GEO Summary]

---- Number of Passengers Traveling Under CodeShare Agreements at San Francisco International Airport

-- Identifying the codeShare records

ALTER TABLE PortfolioProjects.dbo.Air_Traffic
ADD Codeshare varchar(6)

UPDATE PortfolioProjects.dbo.Air_Traffic
SET Codeshare =
CASE
      WHEN [Operating Airline] = [Published Airline] then 'No'
      ELSE 'Yes'
END
--

DECLARE @Total_passengers float;
SELECT  @Total_passengers = sum([Passenger Count])
FROM PortfolioProjects.dbo.Air_Traffic where [Activity Type Code] <> 'Thru / transit'

SELECT Codeshare,sum([Passenger Count]) as 'Count of passengers', sum([Passenger Count])*100/@Total_passengers as 'Percentage'
FROM PortfolioProjects.dbo.Air_Traffic
where [Activity Type Code] <> 'Thru / transit'
group by Codeshare

---- Analyzing the Specifics of Passengers Traveling under CodeShare Agreements

WITH CTE AS (
    SELECT
        [Published Airline] AS Pub_airlines,
        SUM(CASE WHEN Codeshare = 'Yes' THEN [Passenger Count] ELSE 0 END) AS CSA_Passengers,
        SUM(CASE WHEN Codeshare = 'No' THEN [Passenger Count] ELSE 0 END) AS N_CSA_Passengers
    FROM PortfolioProjects.dbo.Air_Traffic
    WHERE [Activity Type Code] <> 'Thru / Transit'
    GROUP BY [Published Airline]
)

SELECT
    Pub_airlines,
    N_CSA_Passengers AS 'N_CSA passengers',
    CSA_Passengers AS 'CSA passengers'
FROM CTE WHERE N_CSA_Passengers <> 0 AND CSA_Passengers <>0 order by 1

---- Count of Airlines Operating Flights at San Francisco Airport

SELECT COUNT(distinct([Operating Airline])) FROM PortfolioProjects.dbo.Air_Traffic

---- Analyzing the Performance of United Airlines Pre and Post Merger with Continental Airlines

--  Stored procedure to calculate the number of passengers

CREATE PROCEDURE sp_SumPassengerCount
     @airline VARCHAR(50),
	 @activity_period INT,
	 @after_before VARCHAR(7)
AS
BEGIN

    IF @after_before='after' 
	BEGIN
         SELECT SUM([Passenger Count]) FROM PortfolioProjects.dbo.Air_Traffic
	     WHERE ([Published Airline] =@airline OR [Operating Airline]=@airline)
         AND [Activity Period]>=@activity_period
         AND [Activity Type Code]<>'Thru / transit'
	END
	ELSE
	BEGIN
         SELECT SUM([Passenger Count]) FROM PortfolioProjects.dbo.Air_Traffic
	     WHERE ([Published Airline] =@airline OR [Operating Airline]=@airline)
         AND [Activity Period]<=@activity_period
         AND [Activity Type Code]<>'Thru / transit'
	END


END

--  Stored procedure to calculate the yearly average of passengers

CREATE PROCEDURE sp_AnnualAveragePassengerCount
     @airline VARCHAR(50),
	 @start_year INT,
	 @end_year INT
AS
BEGIN

    WITH cte AS
	     (
		   SELECT Year,SUM([Passenger Count]) as 'Total passengers' FROM PortfolioProjects.dbo.Air_Traffic
		   where ([Operating Airline]=@airline OR [Published Airline]=@airline)
		      AND [Year] BETWEEN @start_year AND @end_year
			  AND [Activity Type Code]<> 'Thru / transit'
		   Group by Year

		   )
	 SELECT avg([Total passengers]) FROM cte
END

-- Number of Passengers of United Airlines Prior to the Merger

EXEC sp_SumPassengerCount @airline = 'United airlines',@activity_period=201202,@after_before='before'

-- The Annual Average of United Airlines Passengers Prior to the Merger

EXEC sp_AnnualAveragePassengerCount @airline='United airlines',@start_year=2006,@end_year=2011

-- Number of Passengers of Continental Airlines Prior to the Merger

EXEC sp_SumPassengerCount @airline = 'Continental airlines',@activity_period=201202,@after_before='before'

-- The anual avergae of Continental airlines passengers before merging

EXEC sp_AnnualAveragePassengerCount @airline='Continental airlines',@start_year=2006,@end_year=2011

-- The Annual Average of United Airlines Passengers After the Merger (And before COVID-19 Pandemic)

EXEC sp_AnnualAveragePassengerCount @airline='United airlines',@start_year=2013,@end_year=2019

-- The Total Passengers After the Merger

EXEC sp_SumPassengerCount @airline = 'United airlines',@activity_period=201203,@after_before='after'

---- Examining the Performance of Delta Airlines Before the Merger with Northwest Airlines

-- Pre-Merger Passenger Count of Northwest Airlines

EXEC sp_SumPassengerCount @airline = 'Northwest Airlines',@activity_period=201001,@after_before='before'

-- Pre-Merger Annual Average Passenger Count of Northwest Airlines

EXEC sp_AnnualAveragePassengerCount @airline='Northwest Airlines',@start_year=2006,@end_year=2009

-- Pre-Merger Passenger Count of Delta Air Lines

EXEC sp_SumPassengerCount @airline = 'Delta air lines',@activity_period=201001,@after_before='before'

-- Pre-Merger Annual Average Passenger Count of Delta Air Lines

EXEC sp_AnnualAveragePassengerCount @airline='Delta air lines',@start_year=2006,@end_year=2009

-- Annual Average of Delta air lines Post-Merger

EXEC sp_AnnualAveragePassengerCount @airline='Delta air lines',@start_year=2011,@end_year=2019

-- Post-Merger Total Passenger Count of Delta Air Lines

EXEC sp_SumPassengerCount @airline = 'Delta air lines',@activity_period=201002,@after_before='after'