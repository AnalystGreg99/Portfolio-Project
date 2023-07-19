SELECT*
FROM covid_vaccination
WHERE total_tests is not null
and new_tests is not null
Order by 3, 4;

--Formula to bring up full covid_death table
Select *
From covid_death;

SELECT v.continent, v.location, v.date, v.total_tests, d.population
FROM covid_death as d, covid_vaccination as v
WHERE v.iso_code = d.iso_code
And v.continent is not null AND v.total_tests is not null
order by 1,3,4

Alter table covid_vaccination
Alter column total_tests float

--Total tests vs total population
SELECT v.continent, sum(distinct  v.total_tests ) AS Total_test_continental, sum(distinct d.population) AS total_population_continental
FROM covid_death as d, covid_vaccination as v
WHERE v.iso_code = d.iso_code 
And v.continent is not null AND v.total_tests is not null
Group by v.continent
order by 1

--POPULATION Vs new vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM covid_death as dea
Join covid_vaccination as vac
ON dea.continent = vac.continent AND  dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1,3

--Making a rolling sum
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.location Order by dea.location, dea.date  ROWS UNBOUNDED PRECEDING) AS Rolling_sum
FROM covid_death as dea
Join covid_vaccination as vac
ON dea.continent = vac.continent 
AND  dea.date = vac.date
WHERE dea.continent is not null
AND vac.new_vaccinations is not null
ORDER BY 2,3

--USING CTE FOR LOBAL VACCINATION
WITH cte AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS Rolling_peoplevaccinated
    FROM covid_death AS dea
    INNER JOIN covid_vaccination AS vac
    ON dea.continent = vac.continent 
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
    AND vac.new_vaccinations IS NOT NULL
)
SELECT continent, location, date, population, new_vaccinations, Rolling_peoplevaccinated
FROM cte
ORDER BY location, date;

--DATA FOR AFRICA TOTAL TESTS VS TOTAL CASES categorised by date 
Select location,  date,  total_deaths,population, (total_deaths/population)*100 as death_rate, 
SUM(total_deaths) over (Partition by location order by location, date ROWS UNBOUNDED PRECEDING) AS ROLLING_DEATHS
FROM covid_death
Where continent  like '%africa%'
Order by 1,2
--USING CTE TO GET TOTAL DEATHS IN AFRICAN COUNTRIES
WITH african_deaths as (
Select location,  date,  total_deaths,population, (total_deaths/population)*100 as death_rate, 
SUM(total_deaths) over (Partition by location order by location, date ROWS UNBOUNDED PRECEDING) AS ROLLING_DEATHS
FROM covid_death
Where continent  like '%africa%'

)
Select location, max(ROLLING_DEATHS) as max_deaths, min(ROLLING_DEATHS) as min_deaths
FROM african_deaths
Group by location
Order by 2,3 desc

--GETTING FOR NIGERIA
WITH nigeria_deaths as (
Select location,  date,  total_deaths,population, (total_deaths/population)*100 as death_rate, 
SUM(total_deaths) over (Partition by location order by location, date ROWS UNBOUNDED PRECEDING) AS ROLLING_DEATHS
FROM covid_death
Where continent  like '%africa%'

)
Select location, max(ROLLING_DEATHS) as max_deaths, min(ROLLING_DEATHS) as min_deaths
FROM nigeria_deaths
where location = 'nigeria'
Group by location

--creating view
CREATE VIEW PERCENTPOPULATIONVACCINATED AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date ROWS UNBOUNDED PRECEDING) AS Rolling_peoplevaccinated
    FROM covid_death AS dea
    INNER JOIN covid_vaccination AS vac
    ON dea.continent = vac.continent 
    AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
-- ORDER BY 2, 3