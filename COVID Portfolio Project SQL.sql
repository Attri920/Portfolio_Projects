Select *
From PortfolioProject..CovidDeaths
Order by 3 ,4 

--Select *
--From PortfolioProject..CovidVaccinations
--Order by 3 ,4 

Select location , date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by  1,2 


--Looking  at Total Death vs total Infected
--how likely is it for someone to loose their life if they get covid in a specific country
Select location , date, total_cases,total_deaths, (total_deaths/ total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location = 'India'
Order by  1, 2 

--What percentage of People got covid (Total infected Percentage)
Select location , date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
from PortfolioProject..CovidDeaths
order by 1,2


--Countries with highest Infection rate
Select location ,population, Max(total_cases) , Max((total_cases/population)*100) as InfectedPercentage 
from PortfolioProject..CovidDeaths 
group by Location , population
order by  InfectedPercentage  desc

--Countries with highest Death rate
Select location ,population, Max(cast(total_deaths as int)) , Max((total_deaths/population)*100) as DeathPercentage 
from PortfolioProject..CovidDeaths 
group by Location , population
order by  DeathPercentage  desc

--Countries with highest Death Count
Select location, Max(cast(total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths 
where continent is not null
group by Location 
order by  DeathCount desc

--Continent with highest Death Count
Select Continent , Max(cast(total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths 
where continent is not null
group by continent 
order by  DeathCount desc

--Continent with highest Death Count (Getting the correct data, as continent not null)
Select location , Max(cast(total_deaths as int)) as DeathCount
from PortfolioProject..CovidDeaths 
where continent is  null
group by location
order by  DeathCount desc


-- Global Data
Select  date, sum(new_cases) as TotalCases , sum(cast(new_deaths as int)) TotalDeaths , sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths 
where continent is not null
group by date
order by 1,2


-- total covid vaccination rolling count
Select dea.continent , dea.location, dea.date, dea.population, vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date, dea.location) as  RollingPeopleVacinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 2,3


--Rolling % vacinated (using CTE)
With PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVacinated)
as
(
Select dea.continent , dea.location, dea.date, dea.population ,vac.new_vaccinations,   
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date, dea.location) as RollingPeopleVacinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVacinated / population)*100 as per
from PopvsVac


--Rolling % vacinated (using temp)

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255) , 
  location nvarchar(255),
  Date datetime,
  population numeric,
  New_vaccinations numeric,
  RollingPeopleVacinated numeric
  )
insert into #PercentPopulationVaccinated
Select dea.continent , dea.location, dea.date, dea.population ,vac.new_vaccinations,   
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date, dea.location) as RollingPeopleVacinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVacinated / population)*100 as per
from #PercentPopulationVaccinated

--Creating View
create view PercentPopulationVaccinated as
Select dea.continent , dea.location, dea.date, dea.population ,vac.new_vaccinations,   
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.date, dea.location) as RollingPeopleVacinated 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
--order by 2,3
