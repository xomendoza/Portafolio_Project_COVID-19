select *
from Portafolio_Project..covid_deaths$
order by 3,4

--select *
--from Portafolio_Project..covid_vaccinations$
--order by 3,4

-- Selecting Data that are going  to be using

select location, date, total_cases, new_cases, total_deaths, population
from Portafolio_Project..covid_deaths$
order by 1,2 


-- Taking a look at total cases vs total deaths

-- Demostrate the likelihood of dying if you contract Covid-19 in Mexico 
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Portafolio_Project..covid_deaths$
where location like 'mexico'
order by 1,2 

-- Looking at the total cases vs the population

-- Demostrate the percentage of people who got Covid-19
select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as infected_porcentage
from Portafolio_Project..covid_deaths$
where location like 'mexico'
order by 1,2


-- Taking a look at countries with highest infection rate compared to population
select location, population, Max(total_cases) as highest_infection_count, Max((total_cases/population))*100 as infected_percentage
from Portafolio_Project..covid_deaths$
--where location like 'mexico'
group by location, population
order by infected_percentage desc


-- Showing countries with highest death count per population 
select location, Max(cast(total_deaths as int)) as total_death_count
from Portafolio_Project..covid_deaths$
--where location like 'mexico'
where continent is not null
group by location
order by total_death_count desc


-- Braking things down by continent:  continents with highest death count per population 
select location, Max(cast(total_deaths as int)) as total_death_count
from Portafolio_Project..covid_deaths$
where continent is null
group by location
order by total_death_count desc


-- Showing North America Countries 
select location, Max(cast(total_deaths as int)) as total_death_count
from Portafolio_Project..covid_deaths$
where continent like 'North America'
group by location 
order by total_death_count desc


-- Showing global death percentage 
select SUM(new_cases) as total_new_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_porcentage
from Portafolio_Project..covid_deaths$
where continent is not null
--group by date
order by 1,2

 
 --------------- FOR ME: INTERMEDIATE 


 -- Doing a join
 -- Taking a look at total population vs vaccinations 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
FROM Portafolio_Project..covid_vaccinations$ vac
JOIN Portafolio_Project..covid_deaths$ dea
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 1,2,3


-- Using a CTE
-- Showing the porcentage of vaccinated population
WITH popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
--,(rolling_people_vaccinated/population)*100
FROM Portafolio_Project..covid_vaccinations$ vac
JOIN Portafolio_Project..covid_deaths$ dea
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (rolling_people_vaccinated/population)*100 as vaccinated_porcentage
FROM popvsvac


-- Using a temp table 

DROP TABLE IF EXISTS #population_vaccinated_percentage

CREATE TABLE #population_vaccinated_percentage
(
continent NVARCHAR(255),
location NVARCHAR(255),
date DATETIME, 
population NUMERIC,
new_vaccinations NUMERIC,
rolling_people_vaccinated NUMERIC
)
INSERT INTO #population_vaccinated_percentage
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
--,(rolling_people_vaccinated/population)*100
FROM Portafolio_Project..covid_vaccinations$ vac
JOIN Portafolio_Project..covid_deaths$ dea
	ON dea.location = vac.location
	and dea.date = vac.date
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (rolling_people_vaccinated/population)*100 as vaccinated_porcentage
FROM #population_vaccinated_percentage




-- Creating view to store data for later visualizations

CREATE VIEW population_vaccinated_percentage_view AS 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as rolling_people_vaccinated
--,(rolling_people_vaccinated/population)*100
FROM Portafolio_Project..covid_vaccinations$ vac
JOIN Portafolio_Project..covid_deaths$ dea
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3