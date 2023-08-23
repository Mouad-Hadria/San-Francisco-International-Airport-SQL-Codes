------------------------------------------------------------------------------- DATA CLEANING & PREPARATION -------------------------------------------------------------------------------

---- Copying the Table

SELECT *
INTO Air_Traffic
FROM PortfolioProjects.dbo.Air_Traffic_Passenger_Statistic$;


---- Excluding the unusable records

DELETE FROM PortfolioProjects.dbo.Air_Traffic
where [Operating Airline] = 'Philippine Airline, Inc. (INACTIVE - DO NOT USE)' or [Published Airline] = 'Philippine Airline, Inc. (INACTIVE - DO NOT USE)'

---- Identifying the missing records of the Continental Airlines and United Airlines due to the merger.

-- Continental Airlines

UPDATE PortfolioProjects.dbo.Air_Traffic
SET [Operating Airline] =
    CASE
        WHEN ([Operating Airline] = 'United Airlines - Pre 07/01/2013' AND [Activity Period]<=201202) THEN 'Continental airlines'
        ELSE [Operating Airline]
    END,
    [Published Airline] =
    CASE
        WHEN ([Published Airline] = 'United Airlines - Pre 07/01/2013' AND [Activity Period]<=201202) THEN 'Continental airlines'
        ELSE [Published Airline]
    END

-- United Airlines

UPDATE PortfolioProjects.dbo.Air_Traffic
SET [Operating Airline] =
    CASE
        WHEN [Operating Airline] = 'United Airlines - Pre 07/01/2013' THEN 'United Airlines'
        ELSE [Operating Airline]
    END,
    [Published Airline] =
    CASE
        WHEN [Published Airline] = 'United Airlines - Pre 07/01/2013' THEN 'United Airlines'
        ELSE [Published Airline]
    END

-- Updating the airline IATA code

UPDATE PortfolioProjects.dbo.Air_Traffic
SET [Operating Airline IATA Code] =
    CASE
        WHEN [Operating Airline] = 'Continental airlines' THEN 'CO'
        ELSE [Operating Airline IATA Code]
    END,
    [Published Airline IATA Code] =
    CASE
        WHEN [Published Airline] = 'Continental airlines' THEN 'CO'
        ELSE [Published Airline IATA Code]
    END

---- Considering that the official legal name of Interjet Airlines is 'ABC Aerolineas S.A. de C.V. dba Interjet', for simplicity, we will refer to it as 'Interjet Airlines'

-- Updating the airline name

UPDATE PortfolioProjects.dbo.Air_Traffic
SET [Operating Airline] =
    CASE
        WHEN [Operating Airline] = 'ABC Aerolineas S.A. de C.V. dba Interjet' THEN 'Interjet Airlines'
        ELSE [Operating Airline]
    END,
    [Published Airline] =
    CASE
        WHEN [Published Airline] = 'ABC Aerolineas S.A. de C.V. dba Interjet' THEN 'Interjet Airlines'
        ELSE [Published Airline]
    END

---- Transforming 'Northwest Airlines (became Delta)' To 'Northwest Airlines'

-- Updating the airline name

UPDATE PortfolioProjects.dbo.Air_Traffic
SET [Operating Airline] =
    CASE
        WHEN [Operating Airline] = 'Northwest Airlines (became Delta)' THEN 'Northwest Airlines'
        ELSE [Operating Airline]
    END,
    [Published Airline] =
    CASE
        WHEN [Published Airline] = 'Northwest Airlines (became Delta)' THEN 'Northwest Airlines'
        ELSE [Published Airline]
    END

---- Standardizing the reporting date

ALTER TABLE PortfolioProjects.dbo.Air_Traffic
ADD [Activity Period Converted] varchar(12)


UPDATE PortfolioProjects.dbo.Air_Traffic
SET PortfolioProjects.dbo.Air_Traffic.[Activity Period Converted] =

CONCAT(left([Activity Period],4),'/', RIGHT([Activity Period],2))

-- Extracting the year information

ALTER TABLE PortfolioProjects.dbo.Air_Traffic
ADD Year INTEGER

UPDATE PortfolioProjects.dbo.Air_Traffic
SET Year =
LEFT([Activity Period],4) FROM PortfolioProjects.dbo.Air_Traffic

-- Extracting the month information

ALTER TABLE PortfolioProjects.dbo.Air_Traffic
ADD Month INTEGER

UPDATE PortfolioProjects.dbo.Air_Traffic
SET Month =
RIGHT([Activity Period],2) FROM PortfolioProjects.dbo.Air_Traffic







