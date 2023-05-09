use [covid-personal-project]

-- select all data

select *
from [covid-personal-project]..[CovidData]
order by Location, date

-- select data that we are going to be using

select 
	Location, 
	date, 
	total_cases, 
	new_cases, 
	total_deaths, 
	population
from [covid-personal-project]..[CovidData]
order by Location, date

-- look at total cases vs total deaths
-- calculate death rate for those infected

select 
	Location, 
	date, 
	total_cases, 
	total_deaths, 
	(total_deaths/total_cases)*100 as death_rate_of_infected
from [covid-personal-project]..[CovidData]
where continent is not null
-- and Location like '%United Kingdom%'
order by Location, date

-- look at total cases vs population
-- calculate infection rate

select 
	Location, 
	date, 
	Population, 
	total_cases, 
	(total_cases/Population)*100 as infection_rate
from [covid-personal-project]..[CovidData]
where continent is not null
-- and Location like '%United Kingdom%'
order by Location, date

-- calculate highest infection rate for each location and it's population

select 
	Location, 
	Population, 
	MAX(total_cases) as highest_case_count, 
	(MAX(total_cases)/Population)*100 as infection_rate
from [covid-personal-project]..[CovidData]
where continent is not null
-- and Location like '%United Kingdom%'
group by Location, population
order by infection_rate desc

-- show highest death counts for each location

select 
	Location, 
	MAX(total_deaths) as tota_death_count
from [covid-personal-project]..[CovidData]
where continent is not null
-- and Location like '%United Kingdom%'
group by Location
order by tota_death_count desc

-- show highest death counts for each continent
-- using continent column

select 
	continent, 
	MAX(total_deaths) as tota_death_count
from [covid-personal-project]..[CovidData]
where continent is not null
-- and Location like '%United Kingdom%'
group by continent
order by tota_death_count desc

-- show highest death counts for each continent
-- using location column

select 
	lgroup.location, 
	lgroup.total_death_count 
from 
(
select 
	Location, 
	MAX(total_deaths) as total_death_count, 
	CASE location
		when 'Europe' then 'continent'
		when 'Asia' then 'continent'
		when 'North America' then 'continent'
		when 'South America' then 'continent'
		when 'Africa' then 'continent'
		when 'Oceania' then 'continent'
		when 'High income' then 'income'
		when 'Upper middle income' then 'income'
		when 'Lower middle income' then 'income'
		when 'Low income' then 'income'
		when 'World' then 'world'
		when 'European Union' then 'European Union'
	end as location_group
from [covid-personal-project]..[CovidData]
where continent is null
group by Location
) as lgroup
where location_group = 'continent'

-- global death rate of infected for each date

select 
	date, 
	SUM(new_cases) as total_cases, 
	SUM(new_deaths) as total_deaths, 
	(SUM(new_deaths)/NULLIF(SUM(new_cases), 0))*100 as death_rate_of_infected
from [covid-personal-project]..[CovidData]
where continent is not null
-- and Location like '%United Kingdom%'
group by date
order by date asc

-- global death rate of infected

select 
	SUM(new_cases) as total_cases, 
	SUM(new_deaths) as total_deaths, 
	(SUM(new_deaths)/NULLIF(SUM(new_cases), 0))*100 as death_rate_of_infected
from [covid-personal-project]..[CovidData]
where continent is not null
-- and Location like '%United Kingdom%'

-- look at total population vs vaccinations using CTE

with popvsvac (continent, location, date, population, new_vaccinations, cummulative_new_vaccinations)
as 
(
select 
	continent, 
	location, 
	date, 
	population, 
	new_vaccinations, 
	SUM(new_vaccinations) over (partition by location order by location, date) as cummulative_new_vaccinations
from [covid-personal-project]..[CovidData]
where continent is not null
)
select
	*,
	(cummulative_new_vaccinations/population)*100 as vaccination_rate
from popvsvac
order by Location, date

-- look at total population vs vaccinations using temp table

drop table if exists #vaccinationrate
create table #vaccinationrate
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
cummulative_new_vaccinations numeric
)

insert into #vaccinationrate
select 
	continent, 
	location, 
	date, 
	population, 
	new_vaccinations, 
	SUM(new_vaccinations) over (partition by location order by location, date) as cummulative_new_vaccinations
from [covid-personal-project]..[CovidData]
where continent is not null

select
	*,
	(cummulative_new_vaccinations/population)*100 as vaccination_rate
from #vaccinationrate
order by Location, date

-- creating view to store data for later visualisations

create view vaccinations as
select 
	continent, 
	location, 
	date, 
	population, 
	new_vaccinations, 
	SUM(new_vaccinations) over (partition by location order by location, date) as cummulative_new_vaccinations
from [covid-personal-project]..[CovidData]
where continent is not null

