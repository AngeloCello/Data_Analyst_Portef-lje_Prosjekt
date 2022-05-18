SELECT *
FROM PortfolioProject.dbo.Covid_D�dsfall


SELECT *
FROM PortfolioProject.dbo.Covid_Vaksinasjon


-- 1.
-- Dette er Data som vi skal bruke gjennom prosjektet

SELECT location, date, total_cases, new_cases, new_deaths, total_deaths, population
FROM PortfolioProject.dbo.Covid_D�dsfall

SELECT new_vaccinations, total_vaccinations
FROM PortfolioProject.dbo.Covid_Vaksinasjon




-- 2.
-- Se p� totalt antall saker VS Totale D�dsfall
-- Hvor mange prosent som d�de sammenlignet med antall p�vist total smitte
-- Viser sannnsynligheten for � d� av covid smitte

SELECT location, date, total_cases as p�vist_total_smitte, total_deaths as total_d�de,
	   (convert(float, total_deaths)/convert(float, total_cases)) * 100 as prosent_antall_d�de
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE location = 'Norway'
ORDER BY date




-- 3.
-- Se p� antall p�vist total smitte VS befolkningen i Norge
-- Se p� prosent av befolkningen som har f�tt covid

SELECT location, date, population, total_cases as p�vist_total_smitte, 
	   (convert(float, total_cases)/convert(float, population)) * 100 as prosent_antall_p�vist_smitte_i_Norge
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE location in ('Norway')
ORDER BY date




-- 4.
-- Se p� land i verden med h�yest p�vist smitte sammenlignet med befolkningen
-- Se p� prosent antall p�vist smitte

SELECT location, population, SUM(convert(float, new_cases)) as antall_p�vist_total_smitte, 
	   MAX(convert(float, total_cases)/convert(float, population))* 100 as prosent_antall_p�vist_smitte
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE continent is not null
GROUP BY location, population
ORDER BY prosent_antall_p�vist_smitte desc




-- 5.
-- BRYTE NED TING ETTER KONTINENT
-- Vise kontinenter med total antall d�de

SELECT location, SUM(convert(float, new_cases)) as total_antall_d�de_i_verden
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE continent is null
AND location in ('Africa', 'Oceania', 'South America', 'Asia', 'North America', 'Europe')
GROUP BY location




-- 6.
-- kalkulasjon som utgj�r hele verden (Globalt nummer)
-- nye p�vist smitte | nye antall d�de | prosent d�de

SELECT date, sum(convert(float, new_cases)) as antall_p�vist_nye_smitte, 
			 sum(convert(float, new_deaths)) as antall_nye_d�de,
			 sum(convert(float, new_deaths))/sum(convert(float, new_cases))*100 as prosent_antall_d�de
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE continent is not null
GROUP BY date
ORDER BY date




-- 7.
-- GLOBALT NUMMER

SELECT sum(convert(float, new_cases)) as antall_p�vist_nye_smitte, 
	   sum(convert(float, new_deaths)) as antall_nye_d�de,
	   sum(convert(float, new_deaths))/sum(convert(float, new_cases))*100 as prosent_antall_d�de
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE continent is not null




-- 8.
-- Se p� den Totale befolkningen i Norge vs vaksinasjon

SELECT cod.location, cod.date, cod.population, vak.new_vaccinations,
	   sum(convert(float, vak.new_vaccinations)) OVER (partition by cod.location order by cod.location, cod.date)
       as sum_vaksinerte_per_dag
       --(sum_vaksinerte_per_dag/population)*100
FROM PortfolioProject.dbo.Covid_D�dsfall cod
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
       --(sum_vaksinerte_per_dag/population)*100
FROM PortfolioProject.dbo.Covid_D�dsfall cod
JOIN PortfolioProject.dbo.Covid_Vaksinasjon vak
	ON cod.location = vak.location
	AND cod.date = vak.date
	AND cod.continent is not null
	AND cod.location = 'Norway'
)
SELECT *, (sum_vaksinerte_per_dag/population)*100
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
FROM PortfolioProject.dbo.Covid_D�dsfall cod
JOIN PortfolioProject.dbo.Covid_Vaksinasjon vak
	ON cod.location = vak.location
	AND cod.date = vak.date
	AND cod.continent is not null
	AND cod.location = 'Norway'

SELECT *, (sum_vaksinerte_per_dag/population)*100
FROM #prosent_befolkning_vaksinert




-- 11.
-- Lage View for � lagre det til visualisering til senere bruk

-- View 1
Create View  total_antall_d�de_i_verden_v
as
SELECT location, SUM(convert(float, new_cases)) as total_antall_d�de_i_verden
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE continent is null
AND location in ('Africa', 'Oceania', 'South America', 'Asia', 'North America', 'Europe')
GROUP BY location


SELECT *
FROM total_antall_d�de_i_verden_v




--View 2

Create View totale_befolkningen_i_Norge_vs_vaksinasjon
as
SELECT cod.location, cod.date, cod.population, vak.new_vaccinations,
	   sum(convert(float, vak.new_vaccinations)) OVER (partition by cod.location order by cod.location, cod.date)
       as sum_vaksinerte_per_dag
       --(sum_vaksinerte_per_dag/population)*100
FROM PortfolioProject.dbo.Covid_D�dsfall cod
JOIN PortfolioProject.dbo.Covid_Vaksinasjon vak
	ON cod.location = vak.location
	AND cod.date = vak.date
	AND cod.continent is not null
	AND cod.location = 'Norway'


SELECT *
FROM totale_befolkningen_i_Norge_vs_vaksinasjon