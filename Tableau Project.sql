-- Tableau Project


SELECT date, sum(convert(float, new_cases)) as total_antall_nye_påvist_smitte, 
			 sum(convert(float, new_deaths)) as total_antall_nye_døde,
			 sum(convert(float, new_deaths))/sum(convert(float, new_cases))*100 prosent_antall_døde
FROM PortfolioProject.dbo.Covid_Dødsfall
WHERE continent is not null
--GROUP BY date
order by 1, 2