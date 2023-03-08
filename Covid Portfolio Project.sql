
SELECT * 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

-- Select Data that we are going to be using

SELECT location, date, total_cases, new_cases, new_deaths,total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases,total_deaths, ((total_deaths/total_cases)*100)/10 as DeathsPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- Looking at the Total Cases vs Population
SELECT location, date, total_cases/10 as Total_Cases,population/10 as Population
, (total_cases/Population)*100 as PercentPopulationofInfected
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'Argent%'
WHERE continent is not null
ORDER BY 1,2


--Looking at Countries with Highest Infection Rate compared to Population 
SELECT location,population/10 as Population, MAX(total_cases) as HighestInfectionRate,
MAX((total_cases/Population))*100 as PercentPopulationofInfected
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location,population
ORDER BY PercentPopulationofInfected desc


--Showing Countries with Highest Deaths count per Population 
SELECT location, MAX(total_deaths/10) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


-- LET'S BREAK THINGS DOWN BY CONTINENT 
-- Showing continents with highest death count per population
--Incorrect
SELECT continent, MAX(total_deaths/10) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc
--Correct 
SELECT location, MAX(total_deaths/10) as TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount desc

-- I want to know what countries are in continent
SELECT continent, location
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location, continent
ORDER BY continent

--Global Numbers 
SELECT date, SUM(new_cases/10) AS InfectedPopulation, SUM(new_deaths/10) AS Newdeaths
	, SUM(new_deaths/10) /SUM(new_cases/10) *100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY date 
ORDER BY 1,2

-- Looking at Tables Data
SELECT * 
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date

-- Looking at Total Population vs Vaccinations 

SELECT dea.continent, dea.location, dea.date, dea.population/10 as Population, vac.New_vaccinations
	, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	-- No se puede mostrar asi el resultado
	--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--Diferentes opciones para hacerlo

-- USE CTE Total Population vs Vaccinations 
WITH PopvsVac(Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population/10 as Population, vac.New_vaccinations
	, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/Population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
)

SELECT *,(RollingPeopleVaccinated/Population)*100 AS PopulationvsVaccinated
FROM PopvsVac
ORDER BY 2,3



-- USE TEMP TABLE Total Population vs Vaccinations 

DROP TABLE IF EXISTS  #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated (
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric, 
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
	)

INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population/10 as Population, vac.New_vaccinations
	, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3


SELECT *,(RollingPeopleVaccinated/Population)*100 AS PopulationvsVaccinated
FROM #PercentPopulationVaccinated 


-- CREATING VIEW TO STORE DATA FOR LATER VISUALIZATIONS

CREATE VIEW PercentPopulationVaccinated AS 
SELECT dea.continent, dea.location, dea.date, dea.population/10 as Population, vac.New_vaccinations
	, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location 
	ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location 
	and dea.date = vac.date
WHERE dea.continent is not null

SELECT * 
FROM PercentPopulationVaccinated