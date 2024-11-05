select * 
from ProjectPortfolio..CovidDeaths
where continent is not null
order by 3,4

--select * 
--from ProjectPortfolio..CovidVaccinations
--order by 3,4

-- Data That We Are Going To Be Using
--Select location, date, total_cases, new_cases, total_deaths, population
--from ProjectPortfolio..CovidDeaths
--order by 1,2

--Looking at total cases vs total deaths
--Shows chances of dying if you get Covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathRatePercentage
from ProjectPortfolio..CovidDeaths
where location like '%kingdom%'
order by 1,2

--Total Cases vs Population
--Shows how much of the population got covid in your country
Select location, date, population, total_cases, (total_cases/population)*100 as CasesPercentage
from ProjectPortfolio..CovidDeaths
where location like '%kingdom%'
order by 1,2

--Looking at countries with the highest infection rate vs population
Select location, population, MAX(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as HighestInfectionPercentage
from ProjectPortfolio..CovidDeaths
--where location like '%kingdom%'
GROUP BY location, population
order by HighestInfectionPercentage desc

--Showing Countries with Highest Death Count vs Population

--BREAKING THINGS DOWN BY CONTINENT
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
from ProjectPortfolio..CovidDeaths
--where location like '%kingdom%'
where continent is null
GROUP BY location
order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From ProjectPortfolio..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from ProjectPortfolio..CovidDeaths
--Where location like '%kingdom%'
where continent is not null
group by date
order by 1,2

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From ProjectPortfolio..CovidDeaths dea
Join ProjectPortfolio..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


