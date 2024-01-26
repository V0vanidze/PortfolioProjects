--SELECT *
--FROM EmployeeDemographics
--WHERE EmployeeID >= 1002


select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths 
order by 1,2



-- The number of deaths in relation to the infected

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
-- For example, let's take a look at my country
where location like '%ukr%' 
and continent is NOT NULL
order by 1,2


-- Total cases vs population 
-- Shows the percentage of population got infected
select Location, date, population, total_cases, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths 
where location like '%ukr%' 
order by 1,2


-- Countries with highest infection rate
select Location, population, Max(total_cases), Max((total_cases/population))*100 as HighestRate
from PortfolioProject..CovidDeaths 
Where continent is NOT NULL
Group By Location, population
Order by HighestRate desc

-- Highest death count per population
select Location, MAX(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths 
Where continent is NOT NULL
Group by location
order by TotalDeathsCount desc


-- Same with continents
select location, MAX(cast(total_deaths as int)) as TotalDeathsCount
from PortfolioProject..CovidDeaths 
Where continent is NULL
Group by location
order by TotalDeathsCount desc


-- Global numbers 
select  SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not NULL 
--Group by date 
order by 1, 2


-- Total population vs Vaccination (Using CTE)


With PopVsVac (continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
as
(
Select  dead.continent, dead.location, dead.date, dead.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dead.location Order by dead.location, dead.date) as Rolling_people_vaccinated
from PortfolioProject..CovidDeaths dead
join PortfolioProject..CovidVaccinations vac
	on dead.location = vac.location 
	and dead.date = vac.date
where dead.continent is not null
)

Select *, (Rolling_people_vaccinated/population)*100 
from PopVsVac


-- TEMP TABLE 
Drop table if exists #PercentagePopulationVaccinated
CREATE TABLE #PercentagePopulationVaccinated
(
Continent varchar(250),
Location varchar(250),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)

Insert into #PercentagePopulationVaccinated
Select  dead.continent, dead.location, dead.date, dead.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dead.location Order by dead.location, dead.date) as Rolling_people_vaccinated
from PortfolioProject..CovidDeaths dead
join PortfolioProject..CovidVaccinations vac
	on dead.location = vac.location 
	and dead.date = vac.date
where dead.continent is not null

Select *, (Rolling_people_vaccinated/population)*100 
from #PercentagePopulationVaccinated


-- Creating view for visualization (for later)

Create View PercentagePopulationVaccinated as 
Select  dead.continent, dead.location, dead.date, dead.population, vac.new_vaccinations, SUM(CONVERT(int, vac.new_vaccinations))
OVER (Partition by dead.location Order by dead.location, dead.date) as Rolling_people_vaccinated
from PortfolioProject..CovidDeaths dead
join PortfolioProject..CovidVaccinations vac
	on dead.location = vac.location 
	and dead.date = vac.date
where dead.continent is not null
