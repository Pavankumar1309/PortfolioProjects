select *
from PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%Indi%'
and continent is not null
order by 1,2 

-- Shows the percentage of population got Covid
select location, date, total_cases, population, (total_cases/population)*100 as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths
where location like '%Indi%'
and continent is not null
order by 1,2 

-- Looking at Countires with Highest Infection Rate compared to Population

select location, population, max(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as InfectedPopulationPercentage
from PortfolioProject..CovidDeaths
--where location like '%Indi%'
Group By location, population
order by InfectedPopulationPercentage desc

-- Showing Countries with Highest Death Count per Population

select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group By location
order by TotalDeathCount desc


--LET'S BREAK THINGS DOWN BY CONTINENT




--Showing Continents with highest death count per population

select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
Group By continent
order by TotalDeathCount desc


--GLOBAL NUMBERS

select date, SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths AS int)) as Total_Deaths, SUM(CAST(new_deaths AS int)) / SUM(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
--where location like '%Indi%'
where continent is not null
group by date
order by 1,2 


--Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
order by 2,3



-- With CTE 

With PopvsVac (Continent, Location, Date, Popolation,new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/ Popolation) *100
From PopvsVac


--TempTable

Create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Popolation numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/ Popolation) *100
From #PercentagePopulationVaccinated



--TempTable

DROP Table if exists #PercentagePopulationVaccinated
Create table #PercentagePopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Popolation numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentagePopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/ Popolation) *100
From #PercentagePopulationVaccinated

--Creating View to store data for later visualizations
create view PercentagePopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
--, RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	And dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentagePopulationVaccinated