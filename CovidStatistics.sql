USE [Portfolio 1]

/*FIRST STEP - converting the Date data type and restricting the data to the required columns only*/

IF OBJECT_ID ('tempdb..#DataConversion') IS NOT NULL
	DROP TABLE #DataConversion

SELECT
	d.location
	,d.continent
	,CONVERT(DATE, d.date, 103) AS Date
	,CONVERT(Float,total_cases) AS TotalCases
	,CONVERT(Float,new_cases) AS NewCases
	,CONVERT(Float,total_deaths) AS TotalDeaths
	,CONVERT(Float,population) AS Population
	,CONVERT(Float,v.people_vaccinated) AS PeopleVaccinated
	,CONVERT(Float,v.people_fully_vaccinated) AS PeopleFullyVaccinated
INTO #DataConversion	
FROM
	..CovidDeaths D
	INNER JOIN ..CovidVaccinations V
		ON D.location = v.location 
		AND d.date = v.date
WHERE
	d.continent IS NOT NULL

SELECT *
FROM #DataConversion

/*By Country*/
IF OBJECT_ID ('tempdb..#ByCountry') IS NOT NULL
	DROP TABLE #ByCountry

SELECT
	Location
	,Continent
	,Population
	,MAX(TotalCases) AS TotalInfected
	,MAX(TotalDeaths) AS TotalDeaths
	,MAX(PeopleVaccinated) AS TotalPeopleVaccinated
	,MAX(PeopleFullyVaccinated) AS TotalPeopleFullyVaccinated
	,CONVERT(DECIMAL(10,2),((MAX(TotalCases))/Population*100)) AS HighestInfectedPercentage
	,CONVERT(DECIMAL(10,2),((MAX(TotalDeaths))/Population*100)) AS PopulationDiedPercentage
	,CONVERT(DECIMAL(10,2),((MAX(PeopleVaccinated))/Population*100)) AS PopulationVaccinatedPercentage
	,CONVERT(DECIMAL(10,2),((MAX(PeopleFullyVaccinated))/Population*100)) AS PopulationFullyVaccinatedPercentage
INTO #ByCountry
FROM #DataConversion
GROUP BY
	Location
	,continent
	,Population
	
SELECT *
FROM #ByCountry
