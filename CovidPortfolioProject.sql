/*
Queries used for Tableau Project 
*/

-- 1. 
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as SIGNED)) as total_deaths, 
SUM(CAST(new_deaths as SIGNED))/SUM(new_cases) * 100 as DeathPercentage
From portfolio.coviddeaths
-- Where location like '%states%' 
Where continent is not null 
-- Group by date 
order by 1,2;

-- 2. 
-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(CAST(total_deaths as SIGNED)) as TotalDeathCount 
From portfolio.coviddeaths
-- Where location like '%states%'
Where continent is null 
and location not in ('World','Eurpoean Union', 'International')
Group by location 
Order by TotalDeathCount desc;

-- 3. 

Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected 
From portfolio.coviddeaths
-- Where location like '%states%'
group by Location,Population 
order by PercentPopulationInfected desc;

-- 4. 

Select location, Population,date, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected 
From portfolio.coviddeaths
-- Where location like '%states%'
group by Location,Population, date
order by PercentPopulationInfected desc;


---------------------------------------------------------------------
-- Queries I orginally created: 

Select * 
From portfolio.coviddeaths
Where continent is not null 
order by 3,4;
-- Select * 
-- From portfolio.covidvaccinations
-- order by 3,4;

-- Select Data that we are going to be using 
Select location, date, total_cases, new_cases, total_deaths, population
From portfolio.coviddeaths
Where continent is not null 
order by 1,2;

-- Looking at Total Cases vs Total Deaths 
-- Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolio.coviddeaths
Where location like '%states%' and continent is not null 
order by 1,2;

-- Looking at Total Cases vs Population 
-- Shows what percentage of population got Covid 
Select location, date, Population, total_cases, (total_cases/Population)*100 as PercentPopulationInfected 
From portfolio.coviddeaths
Where continent is not null 
-- Where location like '%states%'
order by 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population 
Select location, Population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/Population))*100 as PercentPopulationInfected 
From portfolio.coviddeaths
-- Where location like '%states%'
Where continent is not null 
group by Location,Population 
order by PercentPopulationInfected desc;

-- LET'S BREAK THINGS DOWN BY CONTINENT 

-- Showing continents with the highest death count per population 
Select continent, MAX(CAST(total_deaths as SIGNED)) as TotalDeathCount 
From portfolio.coviddeaths
-- Where location like '%states%'
Where continent is not null 
Group by continent 
Order by TotalDeathCount desc;

-- GLOBAL NUMBERS 
Select SUM(new_cases) as total_cases, SUM(CAST(new_deaths as SIGNED)) as total_deaths, SUM(CAST(new_deaths as SIGNED))/SUM(new_cases) * 100 as DeathPercentage
From portfolio.coviddeaths
-- Where location like '%states%' 
Where continent is not null 
-- Group by date 
order by 1,2;


Select * 
FROM portfolio.coviddeaths dea
Join portfolio.covidvaccinations vac
On dea.location = vac.location 
and dea.date = vac.date; 


-- Looking at Total Population vs Vaccinations 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM portfolio.coviddeaths dea
Join portfolio.covidvaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null 
order by 2,3;

-- USE CTE 
 
 With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
 as 
 (
 Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM portfolio.coviddeaths dea
Join portfolio.covidvaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null 
-- order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac;

-- Temp Table 
-- Drop Table if EXISTS PercentPopulationVaccinated;
Create table PercentPopulationVaccinated 
(
continent nvarchar(255),
location nvarchar(255),
date datetime, 
population numeric, 
new_vaccination numeric, 
RollingPeopleVaccinated numeric); 

INSERT into PercentPopulationVaccinated 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM portfolio.coviddeaths dea
Join portfolio.covidvaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null;
-- order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100 
FROM PercentPopulationVaccinated;

-- Creating view to store data for later visualizations 

Create View PercentPopVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(vac.new_vaccinations) OVER (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
FROM portfolio.coviddeaths dea
Join portfolio.covidvaccinations vac
On dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null;
-- order by 2,3

Select * 
From PercentPopVaccinated; 


