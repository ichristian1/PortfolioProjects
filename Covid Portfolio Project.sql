

SELECT *
FROM [Portfolio Project]..CovidVaccinations
Where continent is not null
order by 3,4

--SELECT *
--FROM [Portfolio Project]..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using 

select location, date, total_cases , new_cases, total_deaths, population
From [Portfolio Project]..CovidDeaths
ORDER BY 1,2



-- Looking at Total Cases vs Total Deaths
-- the the liklihood of dying if you contract coid in your country 

select location, date, total_cases , total_deaths, (total_deaths/total_cases)*100 as DeathsPercentage
From [Portfolio Project]..CovidDeaths
Where  location like '%states%'
ORDER BY 1,2


-- Looking at the total cases vs the Population 
-- Shows what percentage of population got covid 

select location, date, population, total_cases , (total_cases/population)*100 as PercentPopulationInfected 
From [Portfolio Project]..CovidDeaths
Where  location like '%states%'
ORDER BY 1,2


-- Looking at contries with highest infection Rate compare to population 

SELECT location, 
       population,  
       MAX(total_cases) AS HighestInfectionCount,  
       MAX((total_cases / population) * 100) AS PercentagePopulationInfected  
FROM [Portfolio Project]..CovidDeaths  
--WHERE location LIKE '%states%'  
GROUP BY location, population   
ORDER BY MAX((total_cases / population) * 100) DESC;



-- Showing Countries with the Highest Death Count Per Population 
 
 SELECT location,   
       MAX(cast(total_deaths as int)) AS TotalDeathCount  
FROM [Portfolio Project]..CovidDeaths  
--WHERE location LIKE '%states%'
Where continent is not null
GROUP BY location   
ORDER BY TotalDeathCount DESC;

-- Showing Coninent  with the Highest Death Count Per Population

 SELECT continent,   
       MAX(cast(total_deaths as int)) AS TotalDeathCount  
FROM [Portfolio Project]..CovidDeaths  
--WHERE location LIKE '%states%'
Where continent is not null
GROUP BY continent   
ORDER BY TotalDeathCount DESC;

-- Global Numbers

SELECT SUM(new_cases), SUM(cast(new_deaths as int)), SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM [Portfolio Project]..CovidDeaths
--WHERE location LIKE '%states%'  
WHERE continent IS NOT NULL  
--GROUP BY date  
ORDER BY 1,2;


-- Looking at total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
       SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated 
	   ,(RollingPeopleVaccinated/population)*100
FROM [Portfolio Project]..CovidDeaths dea  
JOIN [Portfolio Project]..CovidVaccinations vac  
    ON dea.location = vac.location  
    AND dea.date = vac.date  
WHERE dea.continent IS NOT NULL  
ORDER BY 2,3;

 

 -- USE CTE 

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)  
AS  
(  
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
           SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated  
    FROM [Portfolio Project]..CovidDeaths dea  
    JOIN [Portfolio Project]..CovidVaccinations vac  
        ON dea.location = vac.location  
        AND dea.date = vac.date  
    WHERE dea.continent IS NOT NULL  
)  

SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentagePeopleVaccinated  
FROM PopvsVac;


--Temp Table 

-- Create Temporary Table  
CREATE TABLE #PercentPopulationVaccinated  
(  
    Continent NVARCHAR(255),  
    Location NVARCHAR(255),  
    Date DATETIME,  
    Population NUMERIC,  
    New_vaccinations NUMERIC,  
    RollingPeopleVaccinated NUMERIC  
);  

-- Insert Data into Temporary Table  
INSERT INTO #PercentPopulationVaccinated  
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
       SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated  
FROM [Portfolio Project]..CovidDeaths dea  
JOIN [Portfolio Project]..CovidVaccinations vac  
    ON dea.location = vac.location  
    AND dea.date = vac.date  
WHERE dea.continent IS NOT NULL;  

-- Retrieve Data with Percentage Calculation  
SELECT *, (RollingPeopleVaccinated / Population) * 100 AS PercentagePeopleVaccinated  
FROM #PercentPopulationVaccinated;


-- Creating View to store data for later visulazations 

CREATE VIEW PercentPopulationVaccinated AS  
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,  
       SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.date) AS RollingPeopleVaccinated  
FROM [Portfolio Project]..CovidDeaths dea  
JOIN [Portfolio Project]..CovidVaccinations vac  
    ON dea.location = vac.location  
    AND dea.date = vac.date  
WHERE dea.continent IS NOT NULL;


Select *
From  PercentPopulationVaccinated