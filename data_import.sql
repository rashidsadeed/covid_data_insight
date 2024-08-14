use portfolio_project;


Select *
From covid_death
Where continent is not null 
order by 3,4;


-- Select Data that we are going to be starting with

Select location, date, total_cases, new_cases, total_deaths, population
From covid_death
Where continent is not null 
order by 1,2;


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_rate
From covid_death
Where location = "Turkey"
and continent is not null 
order by 1,2;


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select location, date, population, total_cases,  (total_cases/population)*100 as population_infection_rate
From covid_death
-- Where location like '%states%'
order by 1,2;


-- Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as highest_infection_count,  Max((total_cases/population))*100 as max_population_indfection_rate
From covid_death
-- Where location like '%states%'
Group by Location, Population
order by max_population_indfection_rate desc;

-- Countries with Highest Death Count per Population

Select location, MAX(total_deaths) as total_death_count
From covid_death
-- Where location like '%states%'
Where continent is not null 
Group by location
order by total_death_count desc;



-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(total_deaths) as total_death_count
From covid_death
-- Where location like '%states%'
Where continent is not null 
Group by continent
order by total_death_count desc;



-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(new_Cases)*100 as death_rate
From covid_death
-- Where location like '%states%'
where continent is not null 
-- Group By date
order by 1,2;



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (Partition by death.location Order by death.location, death.date) as rolling_vaccinated_count
-- , (RollingPeopleVaccinated/population)*100
From covid_death death
Join covid_vaccine vax
	On death.location = vax.location
	and death.date = vax.date
where death.continent is not null 
order by 2,3;


-- Using CTE to perform Calculation on Partition By in previous query

With population_vs_vaccine (continent, location, date, population, new_vaccinations, rolling_vaccinated_count)
as
(
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (Partition by death.location Order by death.location, death.date) as rolling_vaccinated_count
-- , (RollingPeopleVaccinated/population)*100
From covid_death death
Join covid_vaccine vax
	On death.location = vax.location
	and death.date = vax.date
where death.continent is not null 
-- order by 2,3
)
Select *, (rolling_vaccinated_count/population)*100
From population_vs_vaccine;



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists population_vaccination_rate;

Create Table population_vaccination_rate
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population BIGINT,
new_vaccinations BIGINT,
rolling_vaccinated_count float
);

Insert into population_vaccination_rate
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (Partition by death.location Order by death.location, death.date) as rolling_vaccinated_count
-- , (rolling_vaccinated_count/population)*100
From covid_death death
Join covid_vaccine vax
	On death.location = vax.location
	and death.date = vax.date
-- where death.continent is not null 
-- order by 2,3
;

Select *, (rolling_vaccinated_count/population)*100
From population_vaccination_rate;




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select death.continent, death.location, death.date, death.population, vax.new_vaccinations
, SUM(vax.new_vaccinations) OVER (Partition by death.location Order by death.location, death.date) as rolling_vaccinated_count
-- , (rolling_vaccinated_count/population)*100
From covid_death death
Join covid_vaccine vax
	On death.location = vax.location
	and death.date = vax.date
where death.continent is not null;
