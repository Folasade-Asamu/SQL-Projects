--PROJECT ON COVID DEATH AND VACCINATION

--OBJECTIVES OF THIS PROJECT ARE:
--1. To determine the total covid cases and the total death in Nigeria
--2. To reveal the likelihood of dying when an individual contract Covid in Nigeria
--3. To determine the percentage of population got covid
--4. To determine Countries with the highest infection rate compared to the population.
--5. To reveal Countries with the highest death count per population
--6. To determine continents with highest death count per population
--7. To evaluate total cases, total deaths and percentages across the world by date.
--8. To evaluate Total cases, Total Deaths and Death Percentage Across the World.
--9. To determine the Total population that got Vaccinations.
--10. Use CTE to determine the percentage of population that got vaccinated
--11. Create views to store data for visualization



select *
from CovidDeaths
order by 3, 4



--select *
--from CovidVaccinations
--order by 3, 4

--select Data that would be used from the CovidDeaths Table

select Location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
where continent is not null
order by 1,2

--Total population of the world from 2020-2021

select [continent], [population] from [dbo].[CovidDeaths]
where continent is not null
group by continent, population


--1. Looking at Total Cases vs Total Deaths

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths
where continent is not null
order by 1,2

--2. Shows the likelihood of dying when an individual contracts Covid in their country

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths
where location like '%Nigeria%'
and continent is not null
order by 1,2

--3. Looking at Total Cases Vs Population
--Shows what percentage of population got covid

select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%Nigeria%'
order by 1,2

--4. Looking at Countries with the highest infection rate compared to the population

select Location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
Group by location, population
order by PercentPopulationInfected desc

--Looking at Countries with the highest infection rate compared to the population and date

select Location, population, date, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
Group by location, population, date
order by PercentPopulationInfected desc


--5. Looking at Countries with the highest death count per population
--(Total_death was casted so it can be read as an integer

select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by location
order by TotalDeathCount desc

6. Looking at continents with highest death count per population

--select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
--from CovidDeaths
--where continent is not null
--Group by continent
--order by TotalDeathCount desc

--Those are excluded because of consistency. European Union is part of Europe

select location, SUM(cast(new_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is null
and location not in ('world', 'European Union', 'International')
group by location
order by TotalDeathCount desc


--Global Numbers
--7. Looking for total cases, total deaths and percentages across the world by date

select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
Group By date
order by 1,2

--8. The Total cases, Total Deaths and Death Percentage Across the World 

select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by 1,2


--Joining the CovidDeath Table and the CovidVaccination Table
select *
from CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

--9. Looking at Total population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3



--USE CTE
--10.Looking at percentage of population that was vaccinated

with PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select * , (RollingPeopleVaccinated/Population)*100
from PopvsVac



--TEMP TABLE

--Drop Table if exists #PercentPopulationVaccinated (use this when making an alteration)
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select * , (RollingPeopleVaccinated/Population)*100
from #PercentPopulationVaccinated

--CREATING VIEWS TO STORE DATA FOR VISUALIZATION

--View 1
Create View PercentPopulationVaccinated as
select dea.Continent, dea.Location, dea.Date, dea.Population, vac.New_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(PARTITION by dea.location order by dea.location, dea.Date) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null

select *
from PercentPopulationVaccinated

--View 2
create view TotalPopulationVsVaccination as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from CovidDeaths dea
join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from TotalPopulationVsVaccination

--View 3
create view TotalCasesTotalDeathsDeathPercentageAcrossTheWorld as
select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
--order by 1,2

select *
from TotalCasesTotalDeathsDeathPercentageAcrossTheWorld


--View 4
create view TotalCasesTotalDeathsAndPercentagesAcrossTheWorldByDate as
select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
from CovidDeaths
where continent is not null
Group By date
--order by 1,2

select *
from TotalCasesTotalDeathsAndPercentagesAcrossTheWorldByDate


--View 5
create view ContinentWithHighestDeathCountPerPopulation as
select Continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by continent
--order by TotalDeathCount desc

select *
from ContinentWithHighestDeathCountPerPopulation


--View 6
create view CountriesWithHighestDeathCountPerPopulation as
select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
Group by location
--order by TotalDeathCount desc

select *
from CountriesWithHighestDeathCountPerPopulation


--view 7
create view CountriesWithHighestInfectionRateByPopulation as
select Location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
Group by location, population
--order by PercentPopulationInfected desc

select *
from CountriesWithHighestInfectionRateByPopulation


--view 8
create view TotalCasesVsPopulation as
select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
where location like '%Nigeria%'
--order by 1,2

select *
from TotalCasesVsPopulation

--view 9
create view LikelihoodofDyingWhenAnIndividualContractsCovidInTheirCountry as
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths
where location like '%Nigeria%'
and continent is not null
--order by 1,2

select *
from LikelihoodofDyingWhenAnIndividualContractsCovidInTheirCountry


--view 10
create view TotalCasesVsTotalDeaths as
select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths
where continent is not null
--order by 1,2

select *
from TotalCasesVsTotalDeaths
order by 1,2
