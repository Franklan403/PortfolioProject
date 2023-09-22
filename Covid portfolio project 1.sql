Select *
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4


--Select Data that we are going to by using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 1, 2


-- looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float))*100 AS case_death_ratio
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2


--Looking at Total Cases vs Population
--Shows likelihood of dying if you contract covid in your country
Select location, date, total_cases, total_deaths, (CAST(total_deaths AS float) / CAST(total_cases AS float))*100 AS case_death_ratio
From PortfolioProject..CovidDeaths
where location like '%states%'
order by 1, 2


--Looking at Total Cases vs Population
--Shows what percentage of population got covid

Select location, date, total_cases, population,
(CAST(total_cases AS float) /population)*100 AS case_death_ratio
From PortfolioProject..CovidDeaths
where location like 'United States'
order by 1, 2 


--Looking at country with highest infection rate compared to population
Select Location, Population, MAX(CAST(total_cases AS float)) as HighestInfectionCount
, MAX((CAST(total_cases AS float) /population))*100 AS PercentPopulationInfected
From PortfolioProject..CovidDeaths
where continent is not null
group by Location, Population
order by PercentPopulationInfected DESC


--Showing Countries with Highest Death Count per Population
Select Location, MAX(CAST(total_deaths AS float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
group by Location
order by TotalDeathCount DESC



-- Break things down by continent(correct)
Select location, MAX(CAST(total_deaths AS float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
group by location
order by TotalDeathCount DESC


--Showing continent with the highest death count per population
Select continent, MAX(CAST(total_deaths AS float)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is null
group by continent
order by TotalDeathCount DESC


--Global Numbers
Select date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths,
(sum(new_deaths) / SUM(nullif(new_cases,0)))*100 AS case_death_ratio
From PortfolioProject..CovidDeaths
where continent is null
group by date
order by 1, 2


--Looking at Total population vs Vaccinations
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as float)) over(partition by d.location order by d.location,
d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as d 
left join PortfolioProject..CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
order by 2, 3


--USE CTE
with PopvsVac as (
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as float)) over(partition by d.location order by d.location,
d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as d 
left join PortfolioProject..CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 2, 3
)
select *, (RollingPeopleVaccinated/population)*100 
From PopvsVac
order by 2,3


--Temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as float)) over(partition by d.location order by d.location,
d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as d 
left join PortfolioProject..CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 2, 3

select *, (RollingPeopleVaccinated/Population)*100 
From #PercentPopulationVaccinated
order by 2,3



-- Creating view to store data for later visulization

create view PercentPopulationVaccinated as
select d.continent, d.location, d.date, d.population, v.new_vaccinations,
sum(cast(v.new_vaccinations as float)) over(partition by d.location order by d.location,
d.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths as d 
left join PortfolioProject..CovidVaccinations as v
	on d.location = v.location
	and d.date = v.date
where d.continent is not null
--order by 2, 3


select *
from PercentPopulationVaccinated
