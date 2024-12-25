SELECT * FROM ProjectPortfolio.coviddeaths1;
update coviddeaths1 set `date` = STR_TO_DATE( `date`, '%m/%d/%Y');

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths1
ORDER BY 1,2;


-- total cases vs total deaths
-- Shows liklehood of dying from Covid In states
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercent
FROM coviddeaths1
WHERE location LIKE '%state%' AND total_deaths IS NOT NULL AND continent IS NOT NULL
ORDER BY 1,2;


-- total cases vs population
-- what percent got covid in States

SELECT location, date, population, total_cases, (total_cases/population) * 100 AS PopulationInfected
FROM coviddeaths1
WHERE location LIKE '%States%' AND total_cases IS NOT NULL AND continent IS NOT NULL
ORDER BY 4
;

-- look at countries with highest infection rate compared to population

select location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS PopulationInfected
FROM coviddeaths1
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PopulationInfected desc
;

-- Countries with highest death count per population

select location,  MAX(cast(total_deaths AS FLOAT)) AS TotalDeathCount
FROM coviddeaths1
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount desc
;

-- Lets break thibgs down by continent

select continent,  MAX(cast(total_deaths AS FLOAT)) AS TotalDeathCount
FROM coviddeaths1
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc
;


-- showing continents as highest death per population

select continent,  MAX(cast(total_deaths AS FLOAT)) AS TotalDeathCount
FROM coviddeaths1
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc
;


-- global numbers

SELECT date, sum(new_cases) as TotalCases, sum(new_deaths) AS TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as	DeathPercent
FROM coviddeaths1
WHERE continent IS NOT NULL
group by date
ORDER BY 1;

-- global numbers without date
SELECT  sum(new_cases) as TotalCases, sum(new_deaths) AS TotalDeaths, sum(new_deaths)/sum(new_cases)*100 as	DeathPercent
FROM coviddeaths1
WHERE continent IS NOT NULL
ORDER BY 1;

select * 
from covidvaccs1;
update covidvaccs1 set `date` = STR_TO_DATE( `date`, '%m/%d/%Y');


-- Looking at total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vacced
from coviddeaths1 dea
join covidvaccs1 vac
		on dea.location = vac.location
        and dea.date = vac.date
WHERE vac.new_vaccinations is not null
ORDER by 2
;

with PopvsVacc (continent, location, date, population, new_vaccinations, rolling_total_vacced)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vacced
-- (rolling_total_vacced/population)*100
from coviddeaths1 dea
join covidvaccs1 vac
		on dea.location = vac.location
        and dea.date = vac.date
WHERE vac.new_vaccinations is not null
ORDER by 2
)
select *, (rolling_total_vacced/population)*100 as vacced_people_percent
FROM PopvsVacc;

-- Temp Table
drop table if exists percentpopvacced;
create temporary table percentpopvacced
(
continent varchar(255), 
location varchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_total_vacced numeric
);
INSERT into percentpopvacced
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vacced
-- (rolling_total_vacced/population)*100
from coviddeaths1 dea
join covidvaccs1 vac
		on dea.location = vac.location
        and dea.date = vac.date
WHERE vac.new_vaccinations is not null
ORDER by 2;

select *, (rolling_total_vacced/population) * 100 as vacced_people_percent
from percentpopvacced;

-- I want to chabge temp table and exclude: "WHERE vac.new_vaccinations is not null" this

drop table if exists percentpopvacced;
create temporary table percentpopvacced
(
continent varchar(255), 
location varchar(255), 
date datetime, 
population numeric, 
new_vaccinations numeric, 
rolling_total_vacced numeric
);
INSERT into percentpopvacced
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vacced
-- (rolling_total_vacced/population)*100
from coviddeaths1 dea
join covidvaccs1 vac
		on dea.location = vac.location
        and dea.date = vac.date
WHERE vac.new_vaccinations is not null
ORDER by 2;

select *, (rolling_total_vacced/population) * 100 as vacced_people_percent
from percentpopvacced;


-- creating view for later visualisation


create view percentpopvacced as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(vac.new_vaccinations) over (partition by dea.location order by dea.location, dea.date) as rolling_total_vacced
-- (rolling_total_vacced/population)*100
from coviddeaths1 dea
join covidvaccs1 vac
		on dea.location = vac.location
        and dea.date = vac.date
WHERE vac.new_vaccinations is not null
ORDER by 2;

select * 
from percentpopvacced;
































