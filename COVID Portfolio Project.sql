SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Selecting the relevant data

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Looking at the Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract the COVID in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 AS MortalityRate
FROM PortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

-- What percentage of population got COVID?

SELECT location, date, total_cases, population, (total_cases/population) * 100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
-- WHERE location like '%states%'
ORDER BY 1,2



-- What country has the highest infection rate?

SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX ((total_cases/population)) * 100 AS MaxInfectionRate
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY 4 DESC



-- What are the death count in different countries?

SELECT location, MAX(cast(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY 2 DESC



-- What are the death count in different continents?

SELECT continent, MAX(cast(total_deaths AS int)) AS HighestDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY 2 DESC


-- GLOBAL NUMBERS

SELECT SUM (new_cases) AS Total_Global_Cases, SUM (cast (new_deaths AS int)) AS Total_Global_Deaths,  SUM(cast (new_deaths AS int))/SUM (new_cases) * 100 AS MortalityRate --, SUM (cast (total_deaths AS int)), (total_deaths/total_cases) * 100 AS MortalityRate
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2




-- What is the vaccination rate?

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations, 
SUM (CONVERT (int, Vacc.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS TotalVaccinationsonRollingbasis
--, (TotalVaccinationsonRollingbasis / Deaths.population) * 100 AS VaccinationRate
FROM PortfolioProject..CovidDeaths AS Deaths
JOIN PortfolioProject..CovidVaccinations AS Vacc
	ON Deaths.location = Vacc.location
	AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE

WITH PopvsVac (continent, location, date, population, new_vaccinations, TotalVaccinationsonRollingbasis)
AS 
(
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations, 
SUM (CONVERT (int, Vacc.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS TotalVaccinationsonRollingbasis
--, (TotalVaccinationsonRollingbasis / population) * 100 AS VaccinationRate
FROM PortfolioProject..CovidDeaths AS Deaths
JOIN PortfolioProject..CovidVaccinations AS Vacc
	ON Deaths.location = Vacc.location
	AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (TotalVaccinationsonRollingbasis / population) * 100 AS VaccinationRate
FROM PopvsVac


-- Using Temp Table

DROP TABLE IF EXISTS #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
TotalVaccinationsonRollingbasis numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations, 
SUM (CONVERT (int, Vacc.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS TotalVaccinationsonRollingbasis
--, (TotalVaccinationsonRollingbasis / population) * 100 AS VaccinationRate
FROM PortfolioProject..CovidDeaths AS Deaths
JOIN PortfolioProject..CovidVaccinations AS Vacc
	ON Deaths.location = Vacc.location
	AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (TotalVaccinationsonRollingbasis / population) * 100 AS VaccinationRate
FROM #PercentPopulationVaccinated





-- Creating View to store data for later visualisation

CREATE VIEW PercentPopulationVaccinated AS 
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations, 
SUM (CONVERT (int, Vacc.new_vaccinations)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS TotalVaccinationsonRollingbasis
--, (TotalVaccinationsonRollingbasis / population) * 100 AS VaccinationRate
FROM PortfolioProject..CovidDeaths AS Deaths
JOIN PortfolioProject..CovidVaccinations AS Vacc
	ON Deaths.location = Vacc.location
	AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL
--ORDER BY 2,3



SELECT *
FROM PercentPopulationVaccinated