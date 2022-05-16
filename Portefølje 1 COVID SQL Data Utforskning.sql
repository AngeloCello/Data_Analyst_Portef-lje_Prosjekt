
SELECT *
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null
ORDER BY 3,4


--SELECT *
--FROM PortfolioProject.dbo.Covid_Vaksinasjon
--ORDER BY 3,4

-- Dette er Data som vi skal bruke gjennom prosjektet

SELECT location, date, total_cases, new_cases, new_deaths, total_deaths, population
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null
order by 1, 2


-- Se på totalt antall saker VS Totale Dødsfall
-- Hvor mange prosent som døde sammenlignet med antall saker i Norge
-- Viser sannnsynligheten for å dø av covid smitte i Norge


SELECT location, date, total_cases as påvist_total_smitte, total_deaths as total_døde, (convert(float, total_deaths)/convert(float, total_cases)) * 100 as prosent_antall_døde
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE location in ('Norway')
order by 1, 2





-- Se på Total Smitte VS befolkningen i Norge
-- Viser prosent av den norske befolkningen som har fått covid
SELECT location, date, population, total_cases as påvist_total_smitte, (convert(float, total_cases)/convert(float, population)) * 100 as prosent_antall_påvist_smitte_i_Norge
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE location in ('Norway')
order by 1, 2


-- Se på land i verden med høyest påvist smitte sammenlignet med befolkningen

SELECT location, population, MAX(convert(float, total_cases)) as høyest_påvist_antall_smitte, MAX((convert(float, total_cases)/convert(float, population))) * 100 as prosent_antall_påvist_smitte_i_verden
FROM PortfolioProject.dbo.Covid_Dødsfall
GROUP BY location, population
ORDER BY prosent_antall_påvist_smitte_i_verden desc



-- Viser land med høyest antall døde per befolkningen
SELECT location, MAX(convert(float, total_deaths)) as total_antall_døde
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null
GROUP BY location
ORDER BY total_antall_døde desc



-- BRYTE NED TING ETTER KONTINENT
SELECT continent as Kontinent, MAX(convert(float, total_deaths)) as total_antall_døde
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null
GROUP BY continent
ORDER BY total_antall_døde desc


-- Vise kontinenter med høyest antall døde per populasjon
SELECT location, MAX(convert(float, total_deaths)) as total_antall_døde
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is null
GROUP BY location
ORDER BY total_antall_døde desc


-- kalkulasjon som utgjør hele verden //

-- GLOBALT NUMMER

SELECT date, sum(convert(float, new_cases)) as total_antall_nye_påvist_smitte, 
			 sum(convert(float, new_deaths)) as total_antall_nye_døde,
			 sum(convert(float, new_deaths))/sum(convert(float, new_cases))*100 prosent_antall_døde
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null
GROUP BY date
order by 1, 2


-- totalt påvist smitte | totalt antall døde | prosent døde

SELECT sum(convert(float, new_cases)) as total_antall_nye_påvist_smitte, 
	   sum(convert(float, new_deaths)) as total_antall_nye_døde,
	   sum(convert(float, new_deaths))/sum(convert(float, new_cases))*100 prosent_døde
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null



-- Se på den Totale befolkningen i Norge vs vaksinasjon

SELECT cod.continent, cod.location, cod.date, cod.population, vak.new_vaccinations,
sum(convert(float, vak.new_vaccinations)) OVER (partition by cod.location order by cod.location, cod.date)
as sum_vaksinerte_per_dag
--(sum_vaksinerte_per_dag/population)*100 --CTE/TEMP tabell

FROM PortfolioProject.dbo.Covid_Dødsfall cod
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

FROM PortfolioProject.dbo.Covid_Dødsfall cod
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

FROM PortfolioProject.dbo.Covid_Dødsfall cod
JOIN PortfolioProject.dbo.Covid_Vaksinasjon vak
	on cod.location = vak.location
	and cod.date = vak.date
WHERE cod.continent is not null
AND cod.location in ('Norway', 'Denmark') --Denmark
--ORDER BY 2,3

SELECT *, (sum_vaksinerte_per_dag/population)*100
FROM #prosent_befolkning_vaksinert



-- Lage View for å lagre det til visualisering til senere bruk

-- BRYTE NED TING ETTER KONTINENT *kopiert*
Create view total_antall_døde_i_verden_v
as
SELECT continent as Kontinent, MAX(convert(float, total_deaths)) as total_antall_døde
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null
GROUP BY continent


SELECT *
FROM total_antall_døde_i_verden_v



-- Se på den Totale befolkningen i Norge vs vaksinasjon *kopiert*

Create View Totale_befolkningen_i_Norge_vs_vaksinasjon_v
as
SELECT cod.continent, cod.location, cod.date, cod.population, vak.new_vaccinations,
sum(convert(float, vak.new_vaccinations)) OVER (partition by cod.location order by cod.location, cod.date)
as sum_vaksinerte_per_dag
--(sum_vaksinerte_per_dag/population)*100 --CTE/TEMP tabell

FROM PortfolioProject.dbo.Covid_Dødsfall cod
JOIN PortfolioProject.dbo.Covid_Vaksinasjon vak
	on cod.location = vak.location
	and cod.date = vak.date
WHERE cod.continent is not null
AND cod.location in ('Norway')
--ORDER BY 2,3


SELECT *--, sum_vaksinerte_per_dag/population --> senere bruk til visualisring
FROM Totale_befolkningen_i_Norge_vs_vaksinasjon_v