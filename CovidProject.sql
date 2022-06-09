Select *
From CovidProject..CovidDeaths$
Order by 3, 4

--Select *
--From CovidProject..CovidVaccinations$
--Order by 3, 4

-- Select Data we're going to use

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths$
Order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying if you contract COVID in Australia
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as Death_Rate
From CovidProject..CovidDeaths$
Where location like '%Australia%'
Order by 1, 2

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID in Australia
Select Location, date, total_cases, population, (total_cases/population) * 100 as Percent_Infected
From CovidProject..CovidDeaths$
Where location like '%Australia%'
Order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population)) * 100 as Max_Percent_Infected
From CovidProject..CovidDeaths$
where continent is not null
Group by Location, Population
Order by Max_Percent_Infected desc

-- Countries with the Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
where continent is not null
Group by Location
Order by TotalDeathCount desc

-- INVESTIGATING BY CONTINENT
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidProject..CovidDeaths$
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL STATS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as Death_Rate
From CovidProject..CovidDeaths$
Where continent is not null
Order by 1, 2


-- Looking at Total Population vs Vaccinations over Time
With Pop_vs_Vaxx (Continent, Location, Date, Population, New_Vaccinations, Culmulative_Vaccinations)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as Culmulative_Vaccinations
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

Select *, (Culmulative_Vaccinations/Population)*100 as Culmulative_Percent_Vaccinated
From Pop_vs_Vaxx
where Location like '%Australia%'
