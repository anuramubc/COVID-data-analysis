USE covidanalysis;
-- TO LOAD LARGE DATA SETS FASTER INTO MYSQL DATABASE, 
-- STEP 1: CREATE A TABLE WITH THE COLUMN NAMES AND DATATYPES SAME AS THE DATASET YOU WANT TO LOAD
CREATE TABLE coviddeaths(
iso_code VARCHAR(10),
continent VARCHAR(20),
location VARCHAR(30),
date DATE,
population int,
total_cases int,
new_cases int,
new_cases_smoothed decimal(20,5),
total_deaths int,
new_deaths int,
new_deaths_smoothed decimal(20,5),
total_cases_per_million decimal(20,5),
new_cases_per_million decimal(20,5),
new_cases_smoothed_per_million decimal(20,5),
total_deaths_per_million decimal(20,5),
new_deaths_per_million decimal(20,5),
new_deaths_smoothed_per_million decimal(20,5),
reproduction_rate decimal(20,5),
icu_patients int,
icu_patients_per_million decimal(20,5),
hosp_patients int,
hosp_patients_per_million  decimal(20,5),
weekly_icu_admissions  decimal(20,5),
weekly_icu_admissions_per_million  decimal(20,5),
weekly_hosp_admissions  decimal(20,5),
weekly_hosp_admissions_per_million  decimal(20,5)
);

-- STEP 2: Use LOAD DATA LOCAL INLINE command to import the csv into the desired table
-- USED THESE FOLLOWING LINES OF CODE TO LOAD THE DATASET COVIDDEATHS INTO MYSQL THROUGH COMMAND LINE EXECUTION
-- LOAD DATA LOCAL INFILE "/Users/anuram/Desktop/COVID ANALYSIS/CovidDeaths.csv"
-- INTO TABLE coviddeaths
-- FIELDS TERMINATED BY ','
-- LINES TERMINATED BY '\n'
-- IGNORE 1 LINES
-- (iso_code,continent,location,@datevar,population,total_cases,new_cases,new_cases_smoothed,total_deaths,new_deaths,new_deaths_smoothed,total_cases_per_million,new_cases_per_million,new_cases_smoothed_per_million,total_deaths_per_million,new_deaths_per_million,new_deaths_smoothed_per_million,reproduction_rate,icu_patients,icu_patients_per_million,hosp_patients,hosp_patients_per_million,weekly_icu_admissions,weekly_icu_admissions_per_million,weekly_hosp_admissions,weekly_hosp_admissions_per_million)
-- SET date = STR_TO_DATE(@datevar,'%m/%d/%Y');

-- REPEATING THE STEP 1 and STEP 2 to load the COVDVACCINATIONS DATASET
CREATE TABLE covidvaccinations(
iso_code VARCHAR(10),
continent VARCHAR(20),
location VARCHAR(30),
date DATE,
new_tests INT ,
total_tests INT,
total_tests_per_thousand decimal(20,5),
new_tests_per_thousand decimal(20,5),
new_tests_smoothed INT,
new_tests_smoothed_per_thousand decimal(20,5),
positive_rate decimal(20,5),
tests_per_case decimal(20,5),
tests_units VARCHAR(40),
total_vaccinations INT,
people_vaccinated INT,
people_fully_vaccinated INT,
new_vaccinations INT, 
new_vaccinations_smoothed INT,
total_vaccinations_per_hundred decimal(20,5),
people_vaccinated_per_hundred decimal(20,5),
people_fully_vaccinated_per_hundred decimal(20,5),
new_vaccinations_smoothed_per_million INT,
stringency_index decimal(20,5),
population_density decimal(20,5),
median_age decimal(20,5),
aged_65_older decimal(20,5),
aged_70_older decimal(20,5),
gdp_per_capita decimal(20,5),
extreme_poverty decimal(20,5),
cardiovasc_death_rate decimal(20,5),
diabetes_prevalence decimal(20,5),
female_smokers decimal(20,5),
male_smokers decimal(20,5),
handwashing_facilities decimal(20,5),
hospital_beds_per_thousand decimal(20,5),
life_expectancy decimal(20,5),
human_development_index decimal(20,5)
);

SELECT * 
FROM coviddeaths 
WHERE continent != ''
ORDER BY 3,4;

SELECT * 
FROM covidvaccinations ORDER BY 3,4;

-- SELECT DATA THAT WE ARE GOING TO BE USING
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM coviddeaths 
ORDER BY 1,2;

-- Looking at toal cases Vs Total deaths
-- Likelihood of dying if you got covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases)*100 as DeathPercentage
FROM coviddeaths 
WHERE location like '%india%'
ORDER BY 1,2;

-- Looking at toal cases Vs Population
-- Percentage of population that got COVID
SELECT location, date, total_cases, population,(total_cases / population)*100 as CasePercentage
FROM coviddeaths 
-- To get estimates for all countries then comment out WHERE command
WHERE location like '%india%'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population
SELECT location, population, max(total_cases) as HighestInfectionCount, MAX((total_cases / population)*100) as CasePercentage
FROM coviddeaths 
GROUP BY location, population
ORDER BY CasePercentage desc;

-- Countries with the highest death count per population
-- Hungary has the highest death rate per population 
SELECT location, population, MAX((total_deaths / population)*100) as DeathPercentage
FROM coviddeaths 
WHERE continent != ''
GROUP BY location, population
ORDER BY DeathPercentage desc;

-- Continents with highest death count
-- USA seems to have the highest deaths due to covid
SELECT location, MAX(total_deaths) as maxDeath
FROM coviddeaths 
WHERE continent != ''
GROUP BY location
ORDER BY maxDeath desc;

-- Death count per continent
-- North America has the highest number of deaths due to COVID
SELECT continent, MAX(total_deaths) as maxDeath
FROM coviddeaths 
WHERE continent != ''
GROUP BY continent
ORDER BY maxDeath desc;

-- Global Numbers
-- Total cases, total deaths and total death percentage across the world with time
SELECT date, sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as deathPercentage
FROM coviddeaths 
WHERE continent != ''
GROUP BY date
ORDER BY 1,2;

-- Total cases and deaths till date across the globe
SELECT sum(new_cases) as total_cases, sum(new_deaths) as total_deaths, (sum(new_deaths)/sum(new_cases))*100 as deathPercentage
FROM coviddeaths 
WHERE continent != ''
ORDER BY 1,2;

-- Total vaccination vs population
--
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM coviddeaths as dea 
JOIN covidvaccinations as vac 
ON dea.location = vac.location and dea.date = vac.date
where dea.continent != ''
order by 2,3;

-- Rolling vaccination counter for each location
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as Rolling_vacCount
FROM coviddeaths as dea 
JOIN covidvaccinations as vac 
ON dea.location = vac.location and dea.date = vac.date
where dea.continent != ''
order by 2,3;

-- To get the ratio of max(rolling_vacCount)/population *100 would yield percentage vaccinated per location
-- But we need to use CTE or Temptable to access rolling_vacCount and then find max of that

-- USE CTE
-- The number of columns in the WITH statement must be same as the number of columns in the SELECT statement within CTE
WITH PopsVsVac (continent, location, date, population, new_vaccinations, Rolling_vacCount)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as Rolling_vacCount
FROM coviddeaths as dea 
JOIN covidvaccinations as vac 
ON dea.location = vac.location and dea.date = vac.date
where dea.continent != ''
-- order by 2,3
)

-- SELECT *, (Rolling_vacCount/population)*100 as tot_percentVaccinated
-- FROM PopsVsVac
-- ;

-- Percentage of total vaccinated per population foe each country till date
SELECT location, population, max(Rolling_vacCount) as tot_percentVaccinated, max(Rolling_vacCount)/population as percentVaccinated
FROM PopsVsVac
WHERE continent != ''
Group by location, population
;


-- METHOD 2 Usibg TEMP TABLE
-- STEP 1: creating a temp table PercentPopVac
DROP TABLE if exists PercentPopVac ;
CREATE Table PercentPopVac(
Continent varchar(30),
Location varchar(30),
Date date,
population int,
new_vaccination int,
rolling_vaccount int
);

-- Step 2: Cpoying desired columns into the temp table
INSERT INTO PercentPopVac 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition By dea.location ORDER BY dea.location, dea.date) as Rolling_vacCount
FROM coviddeaths as dea 
JOIN covidvaccinations as vac 
ON dea.location = vac.location and dea.date = vac.date
where dea.continent != '';
-- order by 2,3

-- Step 3: Percentage of total vaccinated per population foe each country till date
SELECT location, population, max(Rolling_vacCount) as tot_percentVaccinated, max(Rolling_vacCount)/population as percentVaccinated
FROM PercentPopVac 
WHERE continent != ''
Group by location, population
;






