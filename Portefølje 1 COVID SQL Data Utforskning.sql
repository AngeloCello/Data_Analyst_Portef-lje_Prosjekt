
SELECT *
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject.dbo.Covid_Vaksinasjon
--ORDER BY 3,4

-- Dette er Data som vi skal bruke gjennom prosjektet

SELECT location, date, total_cases, new_cases, new_deaths, total_deaths, population
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE continent is not null
order by 1, 2


-- Se p� totalt antall saker VS Totale D�dsfall
-- Hvor mange prosent som d�de sammenlignet med antall saker i Norge
-- Viser sannnsynligheten for � d� av covid smitte i Norge


SELECT location, date, total_cases as p�vist_total_smitte, total_deaths as total_d�de, (convert(float, total_deaths)/convert(float, total_cases)) * 100 as prosent_antall_d�de
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE location in ('Norway')
order by 1, 2





-- Se p� Total Smitte VS befolkningen i Norge
-- Viser prosent av den norske befolkningen som har f�tt covid
SELECT location, date, population, total_cases as p�vist_total_smitte, (convert(float, total_cases)/convert(float, population)) * 100 as prosent_antall_p�vist_smitte_i_Norge
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE location in ('Norway')
order by 1, 2


-- Se p� land i verden med h�yest p�vist smitte sammenlignet med befolkningen

SELECT location, population, MAX(convert(float, total_cases)) as h�yest_p�vist_antall_smitte, MAX((convert(float, total_cases)/convert(float, population))) * 100 as prosent_antall_p�vist_smitte_i_verden
FROM PortfolioProject.dbo.Covid_D�dsfall
GROUP BY location, population
ORDER BY prosent_antall_p�vist_smitte_i_verden desc



-- Viser land med h�yest antall d�de per befolkningen
SELECT location, MAX(convert(float, total_deaths)) as total_antall_d�de
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE continent is not null
GROUP BY location
ORDER BY total_antall_d�de desc



-- BRYTE NED TING ETTER KONTINENT
SELECT continent as Kontinent, MAX(convert(float, total_deaths)) as total_antall_d�de
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE continent is not null
GROUP BY continent
ORDER BY total_antall_d�de desc


-- Vise kontinenter med h�yest antall d�de per populasjon
SELECT location, MAX(convert(float, total_deaths)) as total_antall_d�de
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE continent is null
GROUP BY location
ORDER BY total_antall_d�de desc


-- kalkulasjon som utgj�r hele verden //

-- GLOBALT NUMMER

SELECT date, sum(convert(float, new_cases)) as total_antall_nye_p�vist_smitte, 
			 sum(convert(float, new_deaths)) as total_antall_nye_d�de,
			 sum(convert(float, new_deaths))/sum(convert(float, new_cases))*100 prosent_antall_d�de
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE continent is not null
GROUP BY date
order by 1, 2


-- totalt p�vist smitte | totalt antall d�de | prosent d�de

SELECT sum(convert(float, new_cases)) as total_antall_nye_p�vist_smitte, 
	   sum(convert(float, new_deaths)) as total_antall_nye_d�de,
	   sum(convert(float, new_deaths))/sum(convert(float, new_cases))*100 prosent_d�de
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE continent is not null



-- Se p� den Totale befolkningen i Norge vs vaksinasjon

SELECT cod.continent, cod.location, cod.date, cod.population, vak.new_vaccinations,
sum(convert(float, vak.new_vaccinations)) OVER (partition by cod.location order by cod.location, cod.date)
as sum_vaksinerte_per_dag
--(sum_vaksinerte_per_dag/population)*100 --CTE/TEMP tabell

FROM PortfolioProject.dbo.Covid_D�dsfall cod
JOIN PortfolioProject.dbo.Covid_Vaksinasjon vak
	on cod.location = vak.location
	and cod.date = vak.date
WHERE cod.continent is not null
AND cod.location in ('Norway', 'Denmark') --Denmark
ORDER BY 2,3


-- Bruk CTE 

With bef_vs_vak (continet, location, date, population, new_vaccinations, sum_vaksinerte_per_dag)
as 
(
SELECT cod.continent, cod.location, cod.date, cod.population, vak.new_vaccinations,
sum(convert(float, vak.new_vaccinations)) OVER (partition by cod.location order by cod.location, cod.date)
as sum_vaksinerte_per_dag
--(sum_vaksinerte_per_dag/population)*100 --CTE/TEMP tabell

FROM PortfolioProject.dbo.Covid_D�dsfall cod
JOIN PortfolioProject.dbo.Covid_Vaksinasjon vak
	on cod.location = vak.location
	and cod.date = vak.date
WHERE cod.continent is not null
AND cod.location in ('Norway', 'Denmark') --Denmark
--ORDER BY 2,3
)
SELECT *, (sum_vaksinerte_per_dag/population)*100
FROM bef_vs_vak


-- TEMP 

DROP table if exists #prosent_befolkning_vaksinert
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
--(sum_vaksinerte_per_dag/population)*100 --CTE/TEMP tabell

FROM PortfolioProject.dbo.Covid_D�dsfall cod
JOIN PortfolioProject.dbo.Covid_Vaksinasjon vak
	on cod.location = vak.location
	and cod.date = vak.date
WHERE cod.continent is not null
AND cod.location in ('Norway', 'Denmark') --Denmark
--ORDER BY 2,3

SELECT *, (sum_vaksinerte_per_dag/population)*100
FROM #prosent_befolkning_vaksinert



-- Lage View for � lagre det til visualisering til senere bruk

-- BRYTE NED TING ETTER KONTINENT *kopiert*
Create view total_antall_d�de_i_verden_v
as
SELECT continent as Kontinent, MAX(convert(float, total_deaths)) as total_antall_d�de
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE continent is not null
GROUP BY continent


SELECT *
FROM total_antall_d�de_i_verden_v



-- Se p� den Totale befolkningen i Norge vs vaksinasjon *kopiert*

Create View Totale_befolkningen_i_Norge_vs_vaksinasjon_v
as
SELECT cod.continent, cod.location, cod.date, cod.population, vak.new_vaccinations,
sum(convert(float, vak.new_vaccinations)) OVER (partition by cod.location order by cod.location, cod.date)
as sum_vaksinerte_per_dag
--(sum_vaksinerte_per_dag/population)*100 --CTE/TEMP tabell

FROM PortfolioProject.dbo.Covid_D�dsfall cod
JOIN PortfolioProject.dbo.Covid_Vaksinasjon vak
	on cod.location = vak.location
	and cod.date = vak.date
WHERE cod.continent is not null
AND cod.location in ('Norway')
--ORDER BY 2,3


SELECT *--, sum_vaksinerte_per_dag/population --> senere bruk til visualisring
FROM Totale_befolkningen_i_Norge_vs_vaksinasjon_v