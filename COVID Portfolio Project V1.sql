Select*
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select*
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Select Data that we going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Alter column total_cases and total_deaths
ALTER TABLE..CovidDeaths
ALTER COLUMN total_cases float


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, 
(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
--where continent is not null
order by 1,2


-- Looking at Total Cases Vs Population
-- Show what percentage of population got Covid

Select Location, date,  population, total_cases,
(total_cases/population)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select Location, population, MAX(total_cases) as HighestInfectionCount,
Max((total_cases/population))*100 as PercentagePopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Group by Location, population
order by PercentagePopulationInfected desc

-- Showing Country with Highest Death Count per Population

Select Location, MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by Location
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent , MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent 
order by TotalDeathCount desc


-- Continents with the Highest death count per population

Select continent , MAX(total_deaths) as TotalDeathCount
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
Group by continent 
order by TotalDeathCount asc


-- GLOBAL NUMBERS 

Select sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
sum(new_deaths)/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
--Group by date
order by 1,2

-- ALTER COLUMN new_deaths to int

ALTER TABLE..CovidVaccinations
ALTER COLUMN new_vaccinations float

-- Null value is eliminated by an aggregate or other SET operation issues.

SET ANSI_WARNINGS OFF
GO


-- Looking at Total Population vs Vacinnations

select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select*, (RollingPeopleVaccinated/Population)*100 
from PopvsVac


-- TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
Population numeric,
New_vaccincations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select*, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, 
vac.new_vaccinations, sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select*
from PercentPopulationVaccinated