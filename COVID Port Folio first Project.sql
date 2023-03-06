----SELECT * 
----FROM Portfolioproject..CovidVaccinations
--  WHERE continent IS NOT null
----ORDER BY 3, 4

--SELECT * 
--FROM Portfolioproject..CovidDeaths
--ORDER BY 3, 4


-- Selecting Data 

SELECT Location, Date, total_cases, new_cases, total_deaths, population 
FROM Portfolioproject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 1, 2

-- Total Cases vs Total Deaths - Percentage of Infected people that died

SELECT Location, Date, total_cases, total_deaths, ((Total_deaths / total_cases) * 100) AS DeathPercentage
FROM Portfolioproject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 1, 2


-- Total Cases Vs Population - Percentage of pop that got covid

SELECT Location, Date, total_cases, population, ((Total_cases / population) * 100) AS InfectedPercentage
FROM Portfolioproject..CovidDeaths
WHERE continent IS NOT null
ORDER BY 1, 2

-- Countries with highest infection rate / Population

SELECT Location, population, MAX(total_cases) AS HighesInfectionCount, ((MAX(Total_cases) / population) * 100) AS InfectedPercentage
FROM Portfolioproject..CovidDeaths
WHERE continent IS NOT null
GROUP BY location, population
ORDER BY InfectedPercentage DESC

-- Countries with highest death count / Pop

SELECT Location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Portfolioproject..CovidDeaths
WHERE continent IS NOT null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- By Continent - highest death count
--THIS IS THE CORRECT ONE, IM USING THE ONE BELOW FOR CONSISTENCY

--SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
--FROM Portfolioproject..CovidDeaths
--WHERE continent IS null
--GROUP BY location
--ORDER BY TotalDeathCount DESC


SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM Portfolioproject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Entire World GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, 
SUM(cast(new_deaths as int))/ SUM(new_cases)*100 AS DeathPercentage
FROM Portfolioproject..CovidDeaths
WHERE continent IS NOT null
--GROUP BY DATE
ORDER BY 1, 2


-- TOTAL POPULATION VS VACCINATIONS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS RollingSumVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN  PortfolioProject..CovidVaccinations AS vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- USING A CTE TO BETTER QUERY THE ABOVE 

WITH PopvsVac (continent, location, date, population, new_vaccinations, RollingSumVaccinated) 
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS RollingSumVaccinated 
--, (RollingSumVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingSumVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE

DROP TABLE IF EXISTS #percentPopVaccinated
CREATE TABLE #percentPopVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingSumVaccinated numeric
)

INSERT INTO #percentPopVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS RollingSumVaccinated 
--, (RollingSumVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *, (RollingSumVaccinated/population)*100
FROM #percentPopVaccinated

-- CREATE A VIEW

CREATE VIEW percentPopVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,
	dea.date) AS RollingSumVaccinated 
--, (RollingSumVaccinated/population)*100
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
      ON dea.location = vac.location
	  AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


CREATE VIEW globalNumbers AS
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, 
SUM(cast(new_deaths as int))/ SUM(new_cases)*100 AS DeathPercentage
FROM Portfolioproject..CovidDeaths
WHERE continent IS NOT null
--GROUP BY DATE
--ORDER BY 1, 2