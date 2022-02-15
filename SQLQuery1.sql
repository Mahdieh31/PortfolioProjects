select * from PortfolioProject..CovidDeath
where continent is not null
order by 3,4


--Select * from PortfolioProject..CovidVaccinations
--order by 3,4;

--Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
where continent is not null order by 1,2

--Looking at total cases vs total deaths


select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as death_percentage
from PortfolioProject..CovidDeath
where location like '%state%'
and continent is not null
order by 1,2

--looking the total cases vs poulation

select location, date,population, total_cases,(total_cases/population)*100 as infection_rate
from PortfolioProject..CovidDeath
where continent is not null
order by 1,2

--looking at countries with hieghst infection rate compared to population

select location, MAX(total_cases) as hieghstInfectionCount, MAX((total_cases/population))*100 as hieghstInfectionCountpercentage
from PortfolioProject..CovidDeath
where continent is not null
group by location, population
order by hieghstInfectionCountpercentage desc

--showing companies with highest death count per population

select location, MAX(cast(total_deaths as int)) as totalDeathcount
from PortfolioProject..CovidDeath
where continent is not null
group by location
order by totalDeathcount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

select continent, MAX(cast(total_deaths as int)) as totalDeathcount
from PortfolioProject..CovidDeath
where continent is not null
group by continent
order by totalDeathcount desc

-- Grouping by date

select SUM(new_cases)as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases) as death_percentage
from PortfolioProject..CovidDeath
where continent is not null
--group by date
order by 1

-- looking at total population vs vaccination


select dea.continent, dea.location, dea.date, dea.population, new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated

from PortfolioProject..CovidDeath as dea
join
PortfolioProject..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
with PopvsVac(continent, location, date, population,New_vaccinations, rollingpeoplevaccinated)
as

(select dea.continent, dea.location, dea.date, dea.population, new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated

from PortfolioProject..CovidDeath as dea
join
PortfolioProject..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
)
 select *, (rollingpeoplevaccinated/population)*100 
 from PopvsVac





 --TEMP TABLE

 drop table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated(
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 rollingpeoplevaccinated numeric)

 insert into  #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated

from PortfolioProject..CovidDeath as dea
join
PortfolioProject..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
--where dea.continent is not null

select *, (rollingpeoplevaccinated/population)*100 
 from #PercentPopulationVaccinated

 --creating view to store data for visualization

 create view PercentPopulationVaccinated as
 select dea.continent, dea.location, dea.date, dea.population, new_vaccinations, SUM(convert(int, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated

from PortfolioProject..CovidDeath as dea
join
PortfolioProject..CovidVaccinations as vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null

