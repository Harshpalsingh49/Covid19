
SELECT *
FROM Vaccine

SELECT *
FROM Deaths

-- Assumptions in this queries whenever we are using continent is not  null because of the data schema
--  in which whenever there is null value the continent values is in location

--lets change the type of total_deaths from Nvarchar to int 
ALTER TABLE DEATHS
ALTER COLUMN TOTAL_DEATHS INT NULL
-- Query to show total cases vs total death ratio 

SELECT date,location,SUM(total_cases) AS TOTAL_CASES
,SUM(total_deaths) AS TOTAL_DEATHS, SUM(total_deaths/total_cases)*100 AS Deathpercantage
--INTO  DeathRatiovscases
FROM Deaths
WHERE location = 'india' 
GROUP BY location,date
HAVING SUM(total_deaths/total_cases) IS NOT NULL
ORDER BY 2

-- Query to show total population vs infected %

SELECT DATE,location,total_cases,Population, (total_cases/population)*100 AS PercentPopulationinfected
FROM Deaths
WHERE population IS NOT NULL AND continent IS NOT null


--Highest Infected Countries 
DECLARE @HighestInfectionCount int;
SET @HighestInfectionCount = (SELECT MAX(total_cases) FROM Deaths);
SELECT location, MAX(total_cases) AS HighestInfectionCount, 
MAX((total_cases/population))*100 AS PercentPopulationinfected
--INTO HighestInfectedCountries
FROM Deaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL AND
population IS NOT NULL AND @HighestInfectionCount IS NOT NULL
GROUP BY location,population
ORDER BY PercentPopulationinfected DESC

---- Countries with Highest Death Count per Population

SELECT location,MAX(total_deaths) AS HighestdeathCount
--INTO countrywisedeathcount
FROM Deaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestdeathCount DESC


-- Showing contintents with the highest death count per population

SELECT continent,MAX(population) AS max_pop,MAX(total_deaths) AS HighestdeathCount,
(MAX(total_deaths)/MAX(population))*100 AS deathratio
--INTO Continentwisedeathcount
FROM Deaths
WHERE continent IS NOT  null
GROUP BY continent
ORDER BY HighestdeathCount DESC


SELECT * FROM top1000deaths
SELECT * FROM top1000vaccine
--TOP 1000  ROWS VIEW TO EASY ACCCESS THE SCHEMA AND LOAD THE DATA


---- GLOBAL NUMBERS
SELECT  ROUND(SUM(new_cases)/1000000000,2) AS total_cases_in_billions
,ROUND(SUM(CAST( new_deaths AS INT))/1000000,2) AS total_deaths_in_millions
,SUM(cast (new_deaths AS INT))/SUM(new_cases)*100 AS GlobalDeathPercantage
--INTO GLOBALNUMBERS
FROM Deaths

---- Percentage of Population that has recieved at least one Covid Vaccine
-- population vs vaccination ratio by location
WITH cte AS 
(
SELECT d.location,d.population,d.date, v.new_vaccinations,
SUM(CAST(v.new_vaccinations AS BIGINT)) OVER(PARTITION BY d.location ORDER BY d.location, D.date ) AS Rollingsumvaccination
FROM vaccine v
JOIN Deaths d
ON v.location =d.location AND v.date =d.date 
where d.continent is not null AND v.new_vaccinations IS NOT NULL
)
SELECT location, population, date, new_vaccinations, Rollingsumvaccination, (Rollingsumvaccination/population)*100 AS vaccinatedpercentage
--INTO vaccinationdata
FROM cte
ORDER BY 1,5

--SELECT * FROM vaccinationdata
-- Query to show the highest vaccinated location

--WITH cte AS 
SELECT d.location,d.population,SUM(CAST(v.new_vaccinations AS BIGINT)) AS total_vaccinations
,(SUM(CAST(v.new_vaccinations AS BIGINT))/d.population)*100 AS Vaccinatedpercnatage
--INTO TOP5VaccinateD_Locations
FROM Vaccine v
JOIN Deaths d
ON v.location =d.location AND v.date =d.date 
where d.continent is not null AND v.new_vaccinations IS NOT NULL
GROUP BY D.location,d.population
ORDER BY 4 desc
OFFSET 0 ROWS 
FETCH NEXT 5 ROWS ONLY;


