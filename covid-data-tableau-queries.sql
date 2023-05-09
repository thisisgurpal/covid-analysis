-- queries for Tableau dashboard
use [covid-personal-project]

-- 1

-- death rate of infected globally
-- method: sum of continent counts where not null
create view DeathRateOfInfectedGlobally as
select
	isnull(SUM(new_cases), 0) as total_cases, 
	isnull(SUM(new_deaths), 0) as total_deaths,
	isnull((SUM(new_deaths)/SUM(new_cases))*100, 0) as death_rate_of_infected
from [covid-personal-project]..CovidData
where continent is not null

-- another method to check numbers/accuracy
-- death rate of infected globally
-- method: location = 'World'
/*
select
	SUM(new_cases) as total_cases, 
	SUM(new_deaths) as total_deaths,
	(SUM(new_deaths)/SUM(new_cases))*100 as death_rate_of_infected
from [covid-personal-project]..CovidData
where location = 'World'
*/

-- 2

-- total deaths for each continent
create view TotalDeathsByContinent as
select
	location,
	isnull(SUM(new_deaths), 0) as total_deaths
from [covid-personal-project]..CovidData
where continent is null
and location not like '%income%'
and location not in ('World', 'European Union')
group by location
order by location

-- 3

-- highest infection rate for each location
create view HighestInfectionRateByLocation as
select
	location,
	population,
	isnull(MAX(total_cases), 0) as highest_cases,
	isnull((MAX(total_cases)/population)*100, 0) as highest_infection_rate
from [covid-personal-project]..CovidData
where continent is not null
group by location, population
order by highest_infection_rate desc

-- 4

-- highest infection rate for each location and date
create view HighestInfectionRateByLocationAndDate as
select
	location,
	population,
	date,
	isnull(MAX(total_cases), 0) as highest_cases,
	isnull((MAX(total_cases)/population)*100, 0) as highest_infection_rate
from [covid-personal-project]..CovidData
where continent is not null
group by location, population, date
order by highest_infection_rate desc