
------------------------------------------------------------------------------- VIEWS -------------------------------------------------------------------------------
---- Creating Views to store the data

-- View 1 :

DROP VIEW IF EXISTS Total_passengers_over_years;  
Go
Create View Total_passengers_over_years AS

SELECT Year,Sum([Passenger Count]) as 'Count of Passengers' FROM PortfolioProjects.dbo.Air_Traffic
where [Activity Type Code] <> 'Thru / transit' group by year

-- View 2 :

DROP VIEW IF EXISTS domestic_International_passengers;  
Go

Create View domestic_International_passengers AS
SELECT year,Quarter,[GEO Summary],SUM([Passenger Count]) as 'Passenger Count' FROM PortfolioProjects.dbo.Air_Traffic
where [Activity Type Code] <> 'Thru / transit'
Group by year,Quarter,[GEO Summary]

-- View 3 :

DROP VIEW IF EXISTS Passengers_of_the_CodeShare_agreement;  
Go

Create View Passengers_of_the_CodeShare_agreement AS
SELECT Codeshare,sum([Passenger Count]) as 'Count of passengers'
FROM PortfolioProjects.dbo.Air_Traffic
where [Activity Type Code] <> 'Thru / transit'
group by Codeshare

-- View 4 :

DROP VIEW IF EXISTS CodeShare_details
Go

Create View CodeShare_details AS

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
FROM CTE WHERE N_CSA_Passengers <> 0 AND CSA_Passengers <>0

-- View 5 :

DROP VIEW IF EXISTS Top12_airlines_in_San_Francisco_International_Airport
Go

Create View Top12_airlines_in_San_Francisco_International_Airport AS

WITH CTE
AS (
SELECT [Operating Airline] , [Passenger Count] FROM PortfolioProjects.dbo.Air_Traffic where [Activity Type Code] in ('Enplaned','Deplaned')
   )

SELECT TOP 12 [Operating Airline],SUM([Passenger Count]) as 'Count of passengers' FROM CTE group by [Operating Airline] order by 2 desc

-- View 6 :

DROP VIEW IF EXISTS United_Airlines_and_Continetal_Airlines_Before_03_2012
Go

Create View United_Airlines_and_Continetal_Airlines_Before_03_2012 AS

WITH    CTE0 AS
        (
        SELECT 'United Ailrines' as 'Airlines',year,SUM([Passenger Count]) as 'Total passengers' FROM PortfolioProjects.dbo.Air_Traffic
where ([Operating Airline] ='United Airlines' or [Published Airline]='United Airlines') AND [Activity Period]<=201202 AND [Activity Type Code] <> 'Thru / transit'
GROUP BY year
        ),
        CTE1 AS
        (
        SELECT 'Continental Airlines' as 'Airlines',year,SUM([Passenger Count]) as 'Total passengers' FROM PortfolioProjects.dbo.Air_Traffic
where ([Operating Airline] ='Continental airlines' or [Published Airline]='Continental airlines') AND [Activity Period]<=201202 AND [Activity Type Code] <> 'Thru / transit'
GROUP BY year
        )
SELECT  *
FROM    CTE0
UNION ALL
SELECT  *
FROM    CTE1

-- View 7 :

DROP VIEW IF EXISTS United_airlines_After_02_2012
Go

Create View United_airlines_After_02_2012 AS

SELECT 'United Airline' as 'Airline',year,SUM([Passenger Count]) as 'Total passengers' FROM PortfolioProjects.dbo.Air_Traffic
where ([Operating Airline] ='United Airlines' or [Published Airline]='United Airlines') AND [Activity Period]>=201203 AND [Activity Type Code] <> 'Thru / transit'
GROUP BY year


-- View 8 :

DROP VIEW IF EXISTS Delta_Airlines_and_Northwest_airlines_Before_02_2010
Go

Create View Delta_Airlines_and_Northwest_airlines_Before_02_2010 AS

WITH    CTE0 AS
        (
SELECT 'Northwest Airlines' as 'Airline',year,SUM([Passenger Count]) as 'Total passengers' FROM PortfolioProjects.dbo.Air_Traffic
where ([Operating Airline] ='Northwest Airlines' or [Published Airline]='Northwest Airlines') AND [Activity Period]<=201001 AND [Activity Type Code] <> 'Thru / transit'
GROUP BY year
        ),
        CTE1 AS
        (
SELECT 'Delta air lines' as 'Airline' ,year,SUM([Passenger Count]) as 'Total passengers' FROM PortfolioProjects.dbo.Air_Traffic
where ([Operating Airline] ='Delta air lines' or [Published Airline]='Delta air lines') AND [Activity Period]<=201001 AND [Activity Type Code] <> 'Thru / transit'
GROUP BY year
        )
SELECT  *
FROM    CTE0
UNION ALL
SELECT  *
FROM    CTE1

-- View 9 :

DROP VIEW IF EXISTS [Delta Air lines after 01-2010]
Go

Create View [Delta Air lines after 01-2010] AS

SELECT 'Delta air lines' as 'Airline',year,SUM([Passenger Count]) as 'Total passengers' FROM PortfolioProjects.dbo.Air_Traffic
where ([Operating Airline] ='Delta air lines' or [Published Airline]='Delta air lines') AND [Activity Period]>201001 AND [Activity Type Code] <> 'Thru / transit'
GROUP BY year