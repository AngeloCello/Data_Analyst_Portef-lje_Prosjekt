/*
Data tabell brukt til Tableau Project
*/


-- TABLEAU 1
SELECT sum(convert(float, new_cases)) as antall_påvist_nye_smitte, 
	   sum(convert(float, new_deaths)) as antall_nye_døde,
	   sum(convert(float, new_deaths))/sum(convert(float, new_cases))*100 as prosent_antall_døde
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null
AND location in ('Norway', 'Sweden', 'Denmark', 'Finland')




-- TABLEAU 2
SELECT location, SUM(convert(float, new_deaths)) as total_antall_døde_i_skandinavia
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null
AND location in ('Norway', 'Sweden', 'Denmark', 'Finland')
GROUP BY location



-- TABLEAU 3
SELECT location, population, SUM(convert(float, new_cases)) as antall_påvist_total_smitte, 
	   MAX(convert(float, total_cases)/convert(float, population))* 100 as prosent_antall_påvist_smitte
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null
GROUP BY location, population
ORDER BY prosent_antall_påvist_smitte desc




-- TABLEAU 4
SELECT location, population, date, SUM(convert(float, new_cases)) as antall_påvist_total_smitte, 
	   MAX(convert(float, total_cases)/convert(float, population))* 100 as prosent_antall_påvist_smitte
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null
GROUP BY location, population, date
ORDER BY prosent_antall_påvist_smitte desc