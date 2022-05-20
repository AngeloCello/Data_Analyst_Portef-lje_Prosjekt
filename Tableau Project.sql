-- Tableau Project


SELECT date, sum(convert(float, new_cases)) as total_antall_nye_p�vist_smitte, 
			 sum(convert(float, new_deaths)) as total_antall_nye_d�de,
			 sum(convert(float, new_deaths))/sum(convert(float, new_cases))*100 prosent_antall_d�de
FROM PortfolioProject.dbo.Covid_D�dsfall
WHERE continent is not null
--GROUP BY date
order by 1, 2