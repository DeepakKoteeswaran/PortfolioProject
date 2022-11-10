--SEELCT data that we are going to use
--SELECT Location, Date, total_cases, New_cases, total_deaths, Population
--From dbo.deaths
--ORDER BY 1,2

-- Tota_cases vs Total_deaths
SELECT Location, date, total_deaths, total_cases, (total_deaths/total_cases) *100 as DeathPercentage
FROM dbo.deaths
Where location like '%ndia'
order by 1,2
-- Total_cases vs Population
SELECT Location, date, population, total_cases, (total_cases/population) *100 as DeathPercentage
FROM dbo.deaths
--Where location like '%ndia'
order by 1,2

-- Looking at countries with highest infecetion rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population)) *100 as PercentagePopulationInfected
FROM dbo.deaths
--Where location like '%ndia'
where location like '%states'
Group by Location,Population
Order by PercentagePopulationInfected Desc

--Let's Break things down by continent

-- Showing the continent with the highest death count
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM dbo.deaths
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global Numbers

SELECT  sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as  total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage 
FROM dbo.deaths
Where continent is not null
order by 1,2

--Looking total population vs vaccinations
Select  continent, sum(cast(people_fully_vaccinated as int))/sum(population) as vacciantionPercentage 
from dbo.Vaccinations
where continent is not null
Group by continent


Select dea.continent,dea.location, dea.date,dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location) as RollingPeopeleVaccinated
from dbo.deaths as dea
join dbo.Vaccinations as vac
on dea.location= vac.location
and dea.date= vac.date
where dea.continent is not null
order  by 2,3

-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
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
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null