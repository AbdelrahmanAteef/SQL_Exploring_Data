Select *
From PortfolioProject..CovidDeaths
Order by 3,4

Select *
From PortfolioProject..CovidVaccinations
Order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Total_Deaths_Vs_Total_Cases
From PortfolioProject..CovidDeaths
Where Location like '%Egypt%'
Order by 1,2 


Select Location, 
		date, 
		population,
		total_cases, 
		(total_cases/population)*100 as Total_Cases_Percentage
From PortfolioProject..CovidDeaths
Where Location like '%Egypt%'
Order by 1,2 


Select location,  
		population,
		MAX(total_cases) as HighestInfection, 
		MAX((total_cases/population))*100 as Total_Cases_Percentage
From PortfolioProject..CovidDeaths
Group by location, population
Order by Total_Cases_Percentage DESC


Select location,
		MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount DESC


Select continent,
		MAX(CAST(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

Select date,
		SUM(New_cases) as total_cases,
		SUM(cast(New_deaths as int)) as total_deaths,
		SUM(cast(new_deaths as int))/SUM(new_cases)* 100 as Death_Percentage
From PortfolioProject..CovidDeaths
Where continent is not null
Group by date
Order by 1,2



SELECT Location,
    SUM(CAST(total_cases AS BIGINT)) AS total_cases,
    SUM(CAST(total_deaths AS BIGINT)) AS total_deaths
FROM PortfolioProject..CovidDeaths
GROUP BY Location
Order by total_cases DESC




Select Dea.continent,
	Dea.location,
	Dea.date,
	Dea.population,
	Vac.new_vaccinations,
	SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition By Dea.location Order By Dea.location, Dea.Date) as Commulative_Vaccinations
From PortfolioProject..CovidDeaths Dea 
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location 
	And Dea.date = Vac.date
Where dea.continent is not null
Order by 2,3



--CET

With PopulationVsVaccinations (Continent, location, date, population, new_vaccinations, Commulative_Vaccinations)
as
(
Select Dea.continent,
	Dea.location,
	Dea.date,
	Dea.population,
	Vac.new_vaccinations,
	SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition By Dea.location Order By Dea.location, Dea.Date) as Commulative_Vaccinations
From PortfolioProject..CovidDeaths Dea 
Join PortfolioProject..CovidVaccinations Vac
	On Dea.location = Vac.location 
	And Dea.date = Vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (Commulative_Vaccinations/population)*100
FROM PopulationVsVaccinations


--Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View Highest_Location_Cases as

SELECT Location,
    SUM(CAST(total_cases AS BIGINT)) AS total_cases,
    SUM(CAST(total_deaths AS BIGINT)) AS total_deaths
FROM PortfolioProject..CovidDeaths
GROUP BY Location
--Order by total_cases DESC

Select *
FROM Highest_Location_Cases
