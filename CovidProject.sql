Select *
From CovidProject..CovidDeaths$
order by 3,4

--Select *
--From CovidProject..CovidVaccinations$
--order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From CovidProject..CovidDeaths$
order by 1,2

-- Total Cases vs Total deaths
Select Location, date, total_cases, total_deaths, (Total_deaths/total_cases)*100 as death_percentage
From CovidProject..CovidDeaths$
Where location like 'Brazil'
order by 1,2

-- Total cases vs Population

Select Location, date, total_cases, new_cases, population, (total_cases/population)*100 as 'population_infected'
From CovidProject..CovidDeaths$
--Where location like 'Brazil'
order by 1,2

--Ranking countries by percentage of population infected
Select Location, MAX(total_cases) as max_infected, population, Max(total_cases/population)*100 as 'population_infected'
From CovidProject..CovidDeaths$
Where continent	 is not null
Group by Location, population
order by population_infected desc

--Ranking countries by number of deaths 
Select Location, max(cast(total_deaths as int)) as death_count
From CovidProject..CovidDeaths$
Where continent	 is not null
Group by location
order by death_count desc

--Ranking continents by number of deaths
Select continent, max(cast(total_deaths as int)) as death_count
From CovidProject..CovidDeaths$
Where continent	 is not null
Group by continent
order by death_count desc



--Cases, deaths and death percentage per day
Select date, sum(new_cases) as global_cases, sum(cast(new_deaths as int)) as global_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100
as death_percentage
From CovidProject..CovidDeaths$
Where continent is not null
Group by date
order by 1,2

--Percentage of people fully vaccinated by country
Select dea.location, population, max(cast(people_fully_vaccinated as int)) as total_vac, 
(max(cast(people_fully_vaccinated as int))/population)*100 as vac_percentage
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
	Group by dea.location, population
	order by vac_percentage desc

--Total population vs Vaccinations

With PopvsVac (continent, location, date, population, new_vaccinations, sum_people_vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as sum_people_vaccinated
--,(sum_people_vaccinated/population)*100
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null and dea.location like 'Albania'
)
Select *, (sum_people_vaccinated/population)*100 
From PopvsVac



--Temp table
Drop table if exists #percent_population_vaccinated
Create Table #percent_population_vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
sum_people_vaccinated numeric
)




Insert into #percent_population_vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as sum_people_vaccinated
--,(sum_people_vaccinated/population)*100
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null 

Select *,(sum_people_vaccinated/population)*100
From #percent_population_vaccinated


--Views

create view percent_population_vaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as sum_people_vaccinated
--,(sum_people_vaccinated/population)*100
From CovidProject..CovidDeaths$ dea
Join CovidProject..CovidVaccinations$ vac
	On dea.location = vac.location and dea.date = vac.date
Where dea.continent is not null 

Select *
From percent_population_vaccinated
