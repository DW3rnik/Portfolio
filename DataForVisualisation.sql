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

/*Global Numbers*/

IF OBJECT_ID ('tempdb..#GlobalNumbers') IS NOT NULL
	DROP TABLE #GlobalNumbers

SELECT 
	SUM(TotalCases) AS TotalCases
	,SUM(TotalDeaths) AS TotalDeaths
	,(SUM(TotalDeaths)/SUM(TotalCases)*100) AS AvgDeathPercentage
INTO #GlobalNumbers
FROM 
(
SELECT 
	Location
	,MAX(TotalCases) AS TotalCases
	,MAX(TotalDeaths) AS TotalDeaths
FROM #DataConversion
GROUP BY
	location
)T1

SELECT *
FROM #GlobalNumbers
/*Population Infected*/

SELECT
	Location
	,Population
	,CONVERT(DECIMAL(10,4),(MAX(TotalCases))/Population) AS PercentageInfected
FROM #DataConversion
GROUP BY
	location
	,Population
ORDER BY
	Location

/*Total deaths per continent*/

SELECT
	Continent
	,SUM(TotalDeathsPerCountry) AS TotalDeaths
FROM
	(
SELECT
	Continent
	,Location
	,MAX(TotalDeaths) AS TotalDeathsPerCountry
FROM #DataConversion
GROUP BY 
	continent
	,Location
)T1 
GROUP BY
	continent

/* Percent Population Infected Over Time for US, UK, Germany, France, Poland*/

SELECT
	Location
	,EOMONTH(Date) AS Month
	,MAX(TotalCases/Population) AS PopulationInfected
FROM #DataConversion
GROUP BY
	Location
	,EOMONTH(Date)
	,TotalCases
	,Population

/* Countries and Continents Table*/

SELECT
	DISTINCT Location
	,Continent
FROM
	#DataConversion


SELECT *
FROM
	..CovidDeaths D
	INNER JOIN ..CovidVaccinations V
		ON D.location = v.location 
		AND d.date = v.date