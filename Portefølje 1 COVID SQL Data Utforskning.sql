/*

Covid 19 Data Utforskning

Metoder brukt: Joins, CTE, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/


-- Disse er tabellene som ble brukt til prosjektet

SELECT *
FROM PortfolioProject.dbo.Covid_Dødsfall


SELECT *
FROM PortfolioProject.dbo.Covid_Vaksinasjon




-- 1.
-- Dette er Data som vi skal bruke gjennom prosjektet

SELECT location, date, total_cases, new_cases, new_deaths, total_deaths, population
FROM PortfolioProject.dbo.Covid_Dødsfall

SELECT new_vaccinations, total_vaccinations
FROM PortfolioProject.dbo.Covid_Vaksinasjon




-- 2.
-- Se på total påvist smitte VS total dødsfall
-- Hvor mange prosent som døde sammenlignet med antall påvist total smitte
-- Viser sannnsynligheten for å dø av covid smitte

SELECT location, date, total_cases as påvist_total_smitte, total_deaths as total_døde,
       (convert(float, total_deaths)/convert(float, total_cases)) * 100 as prosent_antall_døde
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE location = 'Norway'
ORDER BY date




-- 3.
-- Se på antall påvist total smitte VS befolkningen i Norge
-- Se på prosent av befolkningen som har fått covid

SELECT location, date, population, total_cases as påvist_total_smitte, 
       (convert(float, total_cases)/convert(float, population)) * 100 as prosent_antall_påvist_smitte_i_Norge
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE location in ('Norway')
ORDER BY date




-- 4.
-- Se på land i verden med høyest påvist smitte sammenlignet med befolkningen
-- Se på prosent antall påvist smitte

SELECT location, population, SUM(convert(float, new_cases)) as antall_påvist_total_smitte, 
	   MAX(convert(float, total_cases)/convert(float, population))* 100 as prosent_antall_påvist_smitte
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null
GROUP BY location, population
ORDER BY prosent_antall_påvist_smitte desc




-- 5.
-- BRYTE NED TING ETTER KONTINENT
-- Vise kontinenter med total antall døde

SELECT location, SUM(convert(float, new_cases)) as total_antall_døde_i_verden
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is null
AND location in ('Africa', 'Oceania', 'South America', 'Asia', 'North America', 'Europe')
GROUP BY location




-- 6.
-- kalkulasjon som utgjør hele verden (Globalt nummer)
-- nye påvist smitte | nye antall døde | prosent døde

SELECT date, sum(convert(float, new_cases)) as antall_påvist_nye_smitte, 
	     sum(convert(float, new_deaths)) as antall_nye_døde,
	     sum(convert(float, new_deaths))/sum(convert(float, new_cases))*100 as prosent_antall_døde
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null
GROUP BY date
ORDER BY date




-- 7.
-- GLOBALT NUMMER

SELECT sum(convert(float, new_cases)) as antall_påvist_nye_smitte, 
       sum(convert(float, new_deaths)) as antall_nye_døde,
       sum(convert(float, new_deaths))/sum(convert(float, new_cases))*100 as prosent_antall_døde
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null




-- 8.
-- Se på den Totale befolkningen i Norge vs vaksinasjon

SELECT cod.location, cod.date, cod.population, vak.new_vaccinations,
       sum(convert(float, vak.new_vaccinations)) OVER (partition by cod.location order by cod.location, cod.date) 
       as sum_vaksinerte_per_dag
       --(sum_vaksinerte_per_dag/population)* 100
FROM PortfolioProject.dbo.Covid_Dødsfall cod
JOIN PortfolioProject.dbo.Covid_Vaksinasjon vak
	ON cod.location = vak.location
	AND cod.date = vak.date
	AND cod.continent is not null
	AND cod.location = 'Norway'
ORDER BY location




-- 9.
-- Bruk CTE 

With bef_vs_vak (continet, location, date, population, new_vaccinations, sum_vaksinerte_per_dag)
as 
(
SELECT cod.continent, cod.location, cod.date, cod.population, vak.new_vaccinations,
       sum(convert(float, vak.new_vaccinations)) OVER (partition by cod.location order by cod.location, cod.date)
       as sum_vaksinerte_per_dag
       --(sum_vaksinerte_per_dag/population)* 100
FROM PortfolioProject.dbo.Covid_Dødsfall cod
JOIN PortfolioProject.dbo.Covid_Vaksinasjon vak
	ON cod.location = vak.location
	AND cod.date = vak.date
	AND cod.continent is not null
	AND cod.location = 'Norway'
)
SELECT *, (sum_vaksinerte_per_dag/population)* 100
FROM bef_vs_vak




-- 10.
-- TEMP 

Create Table #prosent_befolkning_vaksinert
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Sum_vaksinerte_per_dag numeric
)

Insert into #prosent_befolkning_vaksinert
SELECT cod.continent, cod.location, cod.date, cod.population, vak.new_vaccinations,
	   sum(convert(float, vak.new_vaccinations)) OVER (partition by cod.location order by cod.location, cod.date)
       as sum_vaksinerte_per_dag
       --(sum_vaksinerte_per_dag/population)*100
FROM PortfolioProject.dbo.Covid_Dødsfall cod
JOIN PortfolioProject.dbo.Covid_Vaksinasjon vak
	ON cod.location = vak.location
	AND cod.date = vak.date
	AND cod.continent is not null
	AND cod.location = 'Norway'

SELECT *, (sum_vaksinerte_per_dag/population)*100
FROM #prosent_befolkning_vaksinert




-- 11.
-- Lage View for å lagre det til visualisering til senere bruk

-- View 1
Create View  total_antall_døde_i_verden_v
as
SELECT location, SUM(convert(float, new_cases)) as total_antall_døde_i_verden
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is null
AND location in ('Africa', 'Oceania', 'South America', 'Asia', 'North America', 'Europe')
GROUP BY location


SELECT *
FROM total_antall_døde_i_verden_v




--View 2

Create View totale_befolkningen_i_Norge_vs_vaksinasjon
as
SELECT cod.location, cod.date, cod.population, vak.new_vaccinations,
	   sum(convert(float, vak.new_vaccinations)) OVER (partition by cod.location order by cod.location, cod.date)
       as sum_vaksinerte_per_dag
       --(sum_vaksinerte_per_dag/population)*100
FROM PortfolioProject.dbo.Covid_Dødsfall cod
JOIN PortfolioProject.dbo.Covid_Vaksinasjon vak
	ON cod.location = vak.location
	AND cod.date = vak.date
	AND cod.continent is not null
	AND cod.location = 'Norway'


SELECT *
FROM totale_befolkningen_i_Norge_vs_vaksinasjon
