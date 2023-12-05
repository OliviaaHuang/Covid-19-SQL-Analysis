Select * 
From covid.coviddeaths
Where continent is not null
order by 3,4;

Select location,date,total_cases,new_cases,total_deaths,population
From covid.coviddeaths
Where continent is not null
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- shows likelihood of dying if you contract covid in your country
Select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From covid.coviddeaths
Where continent is not null
-- where location like '%states%'
order by 1,2;

-- Looking at Total Cases vs Population
-- shows what percentage of population got Covid
Select location,date,total_cases,population, (total_cases/population)*100 as PercentagePopulationInfected
From covid.coviddeaths
Where continent is not null
-- where location like '%states%'
order by 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population
Select location,population,max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
From covid.coviddeaths
Where continent is not null
Group by 1,2
order by PercentPopulationInfected desc;

-- showing countries with Highest Death Count per Population
Select location, max(cast(total_deaths as unsigned)) as TotalDeathCount
From covid.coviddeaths
Where continent is not null
Group by location
order by TotalDeathCount desc;

-- Let's break things down by continent 
Select location,max(cast(total_deaths as unsigned)) as TotalDeathCount
From covid.coviddeaths
where continent is not null
Group by location
order by TotalDeathCount desc;

-- showing continents with the higest death count per population
Select continent,max(cast(total_deaths as unsigned)) as TotalDeathCount
From covid.coviddeaths
where continent is not null
Group by continent
order by TotalDeathCount desc;

-- global numbers
Select  sum(new_cases) as total_cases, sum(cast(new_deaths as unsigned)) as total_deaths, sum(cast(new_deaths as unsigned))/sum(new_cases)*100 as DeathPercentage
From covid.coviddeaths
Where continent is not null
-- Group by date
-- where location like '%states%'
order by 1,2;

-- looking at total population vs vaccinations
with PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Data) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
From covid.coviddeaths dea
join covid.covidvaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3)
Select *,(RpllingPeopleVaccinated/population)*100
From PopvsVac;


-- temp table
DROP TABLE IF EXISTS PercentPopulationVaccinated;

CREATE TABLE PercentPopulationVaccinated (
    continent NVARCHAR(255),
    location NVARCHAR(255),
    date DATETIME,
    population NUMERIC,
    new_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);




Insert into PercentPopulationVaccinated
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.Data) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
From covid.coviddeaths dea
join covid.covidvaccinations vac
on dea.location = vac.location
and dea.date=vac.date;
-- where dea.continent is not null
-- order by 2,3


Select *,(RollingPeopleVaccinated/population)*100
From PercentPopulationVaccinated;

-- creating view to store data for later visualization
Create View `PercentPopulationVaccinated` as 
 Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS UNSIGNED)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
-- ,(RollingPeopleVaccinated/population)*100
From covid.coviddeaths dea
join covid.covidvaccinations vac
on dea.location = vac.location
and dea.date=vac.date
where dea.continent is not null
-- order by 2,3






