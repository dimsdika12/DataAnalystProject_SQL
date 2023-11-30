-- Selects data for Southeast Asian countries
-- Defines a Common Table Expression (CTE) named SelectedColumns
-- This CTE selects specific columns from the coviddeath table
-- within the covid19_data_db database.
WITH SelectedColumns AS (
    SELECT location, date, new_cases, total_cases, new_deaths, total_deaths, population
    FROM covid19_data_db.dbo.coviddeath
    WHERE location in ('Brunei','Cambodia','Indonesia','Laos','Malaysia','Myanmar','Philippines','Singapore','Thailand','Timor','Vietnam')
)

-- Retrieves selected columns from the CTE and orders the result by the first and second columns (location and date)
SELECT * 
FROM SelectedColumns 
ORDER BY 1,2

-- Calculates death percentage based on total death and total cases
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)* 100 as DeathPercentage
FROM SelectedColumns
ORDER BY 1,2

-- Calculates case percentage based on total cases and population
SELECT location, date, total_cases, population, (total_cases/population)* 100 as CasesPercentage
FROM SelectedColumns
ORDER BY 1,2

-- Identifies countries with the highest infection rate compared to their population
-- I'll export the data from this query for visualization purposes.

SELECT location,population, MAX(total_cases) as InfectionCount, (MAX(total_cases)/population)*100 as InfectionRate 
FROM SelectedColumns
GROUP BY location,population
ORDER BY 4 DESC

-- Identifies countries with the highest death count compared to their total cases
-- I'll export the data from this query for visualization purposes.

SELECT location,MAX(total_cases) as CasesCount, MAX(total_deaths) as DeathsCount, (MAX(total_deaths)/MAX(total_cases))*100 as DeathsRate 
FROM SelectedColumns
GROUP BY location
ORDER BY 4 DESC

-- Calculates total daily cases and deaths
-- I'll export the data from this query for visualization purposes.

SELECT	location,date,SUM(new_cases) as total_cases_daily, 
		SUM(new_deaths) as total_deaths_daily
FROM SelectedColumns
GROUP BY location, date
HAVING SUM(new_cases) IS NOT NULL AND SUM(new_deaths) IS NOT NULL
ORDER BY 1,2

-- Modifies the column type from varchar to int in the covidvaccination table
ALTER TABLE covid19_data_db.dbo.covidvaccination 
ALTER COLUMN new_vaccinations INT

-- Joins the coviddeath and covidvaccination tables
WITH CovidVaccine AS (
    SELECT d.continent, d.location, d.date, d.population, v.new_vaccinations
    FROM covid19_data_db.dbo.coviddeath as d 
    JOIN covid19_data_db.dbo.covidvaccination as v
    ON d.location = v.location AND d.date = v.date
    WHERE d.location in ('Brunei','Cambodia','Indonesia','Laos','Malaysia','Myanmar','Philippines','Singapore','Thailand','Timor','Vietnam')
)

-- Retrieves data from the joined tables ordered by location and date
SELECT *
FROM CovidVaccine 
ORDER BY 2,3 

-- Shows Percentage of Population that has received Covid Vaccine
-- I'll export the data from this query for visualization purposes.
SELECT continent, location, date, population, new_vaccinations
, SUM(new_vaccinations) OVER (Partition by location Order by location, Date) as TotalPeopleVaccinated
FROM CovidVaccine
