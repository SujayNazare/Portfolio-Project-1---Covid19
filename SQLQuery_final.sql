--#1 Pulling the data from the server to check if its loaded correctly

SELECT *
FROM Covid19_Deaths$
WHERE continent is not null
ORDER BY 3, 4

SELECT *
FROM Covid19_Vaccinations$
ORDER BY 3, 4

--#2 Selecting the relevant data from the dataset

SELECT	location, date, total_cases, new_cases, total_deaths, population
FROM Covid19_Deaths$
WHERE continent is not null
ORDER BY 1, 2

--#3 Checking Total Cases v Total Deaths 
-- This insight shows the likelihood of dying if a person is infected by Covid

SELECT	location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM Covid19_Deaths$
WHERE continent is not null
ORDER BY 1, 2

--#4 Checking Total Cases v Population
-- To know the percentage of the population infected by Covid

SELECT	location, date, population, total_cases,  (total_cases/population)*100 AS infected_percentage
FROM Covid19_Deaths$ 
WHERE continent is not null
ORDER BY 1, 2

--#5 Checking country with Highest infection rates w.r.t. Population

SELECT	location, population, MAX(total_cases) AS highest_infected_count,  MAX((total_cases/population))*100 AS highest_infected_percentage
FROM Covid19_Deaths$ 
WHERE continent is not null
GROUP BY location, population
ORDER BY highest_infected_percentage DESC



--#6 Countries with highest Death count per Population

SELECT	location,  MAX(cast(total_deaths as int)) AS highest_deathcount
FROM Covid19_Deaths$ 
WHERE continent is not null
GROUP BY location
ORDER BY highest_deathcount  DESC

--#7 Split-up/segregation of the data by Continent
-- Showing continents with the highest death count per population

SELECT	continent,  MAX(cast(total_deaths as int)) AS highest_deathcount
FROM Covid19_Deaths$
WHERE continent is not null
GROUP BY continent
ORDER BY highest_deathcount DESC

--#8 Analysing the data on a Global scale

SELECT SUM(new_cases) AS total_cases_per_day, SUM(convert(int, new_deaths) AS total_deaths_per_day, 
(SUM(convert(int, new_deaths))/SUM(new_cases))*100
FROM Covid19_Deaths$
WHERE continent is not null 
order by 1, 2


--#9 Total Population v Vaccinations
-- Shows percentage of Population that has received at least one dose of Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_peo_vac
--, (RollingPeopleVaccinated/population)*100
From Covid19_Deaths$ dea
Join Covid19_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


--#10 Using CTE to perform Calculation on Partition By in the previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, rolling_peo_vac)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as rolling_peo_vac
--, (rolling_peo_vac/population)*100
From Covid19_Deaths$ dea
Join Covid19_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (rolling_peo_vac/Population)*100
From PopvsVac

--#11 Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
rolling_peo_vac numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as rolling_peo_vac
--, (rolling_peo_vac/population)*100
From Covid19_Deaths$ dea
Join Covid19_Vaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
Select *, (rolling_peo_vac/Population)*100
From #PercentPopulationVaccinated

--#12 Opening the View
Select *
FROM PercentPopulationVaccinated

--Thank you
