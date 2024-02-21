select * from deathinfo
where continent is not null
--select * from covidvaccination
--order by 3,4
--select data that we are going to be using--
select location, date,total_cases,new_cases,total_deaths, population
from deathinfo
where continent is not null
order by 1,2

--looking at the Total cases vs Total deaths--
--shows likelihood of dying if you contract covid in your country--
select location, date,total_cases,total_deaths, cast(total_deaths as float)/cast(total_cases as float)*100 as DeathPercentage
from deathinfo
where location like 'Estonia'
order by 1,2
--looking at countries with Highest infection Rate v/s population--
select location,population,max(total_cases) as highestinfectioncount, 
max(cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
from deathinfo
group by location, population
order by PercentPopulationInfected desc
--showing country with Highest Death Count per Population--
select location,max(cast(total_deaths as int)) as TotalDeathCount
from deathinfo
where continent is not null
group by location
order by TotalDeathCount desc
--LET'S BREAK THINGS DOWN BY CONTINENT--
select continent,max(cast(total_deaths as int)) as TotalDeathCount
from deathinfo
where continent is not null
group by continent
order by TotalDeathCount desc
--Global Variable
select sum(new_cases) as Total_Cases, sum(cast(new_deaths as int)) as Total_Deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from deathinfo
where continent is not null
order by 1,2
--looking at Total Population vs Vaccination
--use cte
with PopvsVac(continent,location,date,population,new_vaccinations
,RollingPeopleVaccinated)
as(
select di.continent,di.location,di.date,di.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by di.location 
order by di.location, di.date) as RollingPeopleVaccinated
from deathinfo di
join covidvaccination cv
on di.location=cv.location
and di.date=cv.date
where di.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from PopvsVac

--Temp Tables--
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255), Location nvarchar(255), Date datetime, Population numeric, 
New_vaccinations numeric, RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select di.continent,di.location,di.date,di.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by di.location 
order by di.location, di.date) as RollingPeopleVaccinated
from deathinfo di
join covidvaccination cv
on di.location=cv.location
and di.date=cv.date
--where di.continent is not null
--order by 2,3
select *  from #PercentPopulationVaccinated

--creating view to store data for later visualization
create view PercentPopulationVaccinated as
select di.continent,di.location,di.date,di.population,cv.new_vaccinations,
sum(cast(cv.new_vaccinations as bigint)) over (partition by di.location 
order by di.location, di.date) as RollingPeopleVaccinated
from deathinfo di
join covidvaccination cv
on di.location=cv.location
and di.date=cv.date
where di.continent is not null
--order by 2,3



























