 CREATE DATABASE  CRIME;
 use crime;
 
 /*
What is the total number of crimes reported for each type of crime across all states?
List all the states where the total number of crimes exceeded 10,000 in any given year.
How many crimes were reported in each year across all states?
Find the total number of crimes reported in Delhi over the 20-year period.
Top 5 states which had the lowest number of reported crimes in 2020?
Which states have consistently ranked in the top 5 for the highest number of crimes reported over the years?
Identify the crime type that saw the largest drop in occurrences from one year to the next.
Compare the total number of crimes between Northern and Southern states for each year.
For each type of crime, find which state reported the highest number of cases in 2020.
What is the trend in the number of crimes in states with the highest populations versus states with the lowest populations?
*/
 
 SELECT *
FROM CRIME_DETAILS;

SHOW COLUMNS FROM CRIME_DETAILS;

DESC CRIME_DETAILS;



-- 1. What is the total number of crimes reported for each type of crime across all states?

SELECT 
    State, 
    SUM(Rape) AS TOTAL_RAPES, 
    SUM(`K&A`) AS TOTAL_KIDNAP_ASSAULT, 
    SUM(`DD`) AS TOTAL_DOWRY_DEATHS, 
    SUM(`AoW`) AS TOTAL_ASSAULTS, 
    SUM(`AoM`) AS TOTAL_ASSAULTS_MODESTY, 
    SUM(`DV`) AS TOTAL_DOMESTIC_VIOLENCE, 
    SUM(`WT`) AS TOTAL_TRAFFICKING  
FROM CRIME_DETAILS  
GROUP BY State  
ORDER BY State;

-- 2. List all the states where the total number of crimes exceeded 10,000 in any given year.
    
    WITH STATE_WISE_CRIME AS (
    SELECT 
        State,
        Year,
        SUM(Rape) + SUM(`K&A`) + SUM(`DD`) + SUM(`AoW`) + 
        SUM(`AoM`) + SUM(`DV`) + SUM(`WT`) AS TOTAL_CRIMES
    FROM CRIME_DETAILS
    GROUP BY State, Year
)
SELECT State, Year, TOTAL_CRIMES
FROM STATE_WISE_CRIME
WHERE TOTAL_CRIMES > 10000
ORDER BY TOTAL_CRIMES DESC;

-- 3. How many crimes were reported in each year across all states?
SELECT 
    Year,
    SUM(Rape) + SUM(`K&A`) + SUM(`DD`) + SUM(`AoW`) + 
    SUM(`AoM`) + SUM(`DV`) + SUM(`WT`) AS TOTAL_CRIMES
FROM CRIME_DETAILS
GROUP BY Year
ORDER BY Year;


-- 4. Find the total number of crimes reported in Delhi over the 20-year period.

SELECT 
    State,
    SUM(Rape) + SUM(`K&A`) + SUM(`DD`) + SUM(`AoW`) + 
    SUM(`AoM`) + SUM(`DV`) + SUM(`WT`) AS TOTAL_CRIMES
FROM CRIME_DETAILS
WHERE State = 'Delhi UT'
GROUP BY State;

-- 5. Top 5 states which had the lowest number of reported crimes in 2020?

SELECT 
    State,
    SUM(Rape) + SUM(`K&A`) + SUM(`DD`) + SUM(`AoW`) + 
    SUM(`AoM`) + SUM(`DV`) + SUM(`WT`) AS TOTAL_CRIMES
FROM CRIME_DETAILS
WHERE Year = 2020
GROUP BY State
ORDER BY TOTAL_CRIMES ASC
LIMIT 5;

-- 6. Difference between total number of crimes between the year 2019 and 2020

WITH TOTAL_CRIMES AS (
    SELECT 
        State, 
        Year,
        SUM(Rape) + SUM(`K&A`) + SUM(`DD`) + SUM(`AoW`) +
        SUM(`AoM`) + SUM(`DV`) + SUM(`WT`) AS TOTAL_CRIMES
    FROM CRIME_DETAILS
    WHERE Year IN (2019, 2020)
    GROUP BY State, Year
)
SELECT 
    State,
    Year,
    TOTAL_CRIMES,
    LAG(TOTAL_CRIMES, 1, 0) OVER(PARTITION BY State ORDER BY Year) AS PREVIOUS_YEAR_CRIMES, 
    TOTAL_CRIMES - LAG(TOTAL_CRIMES, 1, 0) OVER(PARTITION BY State ORDER BY Year) AS CRIME_DIFFERENCE
FROM TOTAL_CRIMES
WHERE Year = 2020;

-- 7. TOP 5 STATES (YEAR WISE) BASED ON TOTAL CRIMES

WITH YEAR_WISE_CRIMES AS (
    SELECT 
        State, 
        Year, 
        SUM(Rape) + SUM(`K&A`) + SUM(`DD`) + SUM(`AoW`) +
        SUM(`AoM`) + SUM(`DV`) + SUM(`WT`) AS TOTAL_CRIMES
    FROM CRIME_DETAILS
    GROUP BY State, Year
)
SELECT State, Year, TOTAL_CRIMES, CRIME_RANK
FROM (
    SELECT 
        State, 
        Year, 
        TOTAL_CRIMES,
        DENSE_RANK() OVER(PARTITION BY Year ORDER BY TOTAL_CRIMES DESC) AS CRIME_RANK
    FROM YEAR_WISE_CRIMES
) AS RankedCrimes
WHERE CRIME_RANK <= 5;

-- 8. States that have consistently ranked in the top 5 for the highest number of crimes reported over the years

WITH YEAR_WISE_CRIMES AS (
    SELECT 
        State, 
        Year, 
        SUM(Rape) + SUM(`K&A`) + SUM(`DD`) + SUM(`AoW`) +
        SUM(`AoM`) + SUM(`DV`) + SUM(`WT`) AS TOTAL_CRIMES
    FROM CRIME_DETAILS
    GROUP BY State, Year
)
SELECT State, 
       COUNT(*) AS TOP_5_APPEARANCE_COUNT
FROM (
    SELECT 
        State, 
        Year, 
        TOTAL_CRIMES, 
        DENSE_RANK() OVER(PARTITION BY Year ORDER BY TOTAL_CRIMES DESC) AS CRIME_RANK
    FROM YEAR_WISE_CRIMES
) AS RankedCrimes
WHERE CRIME_RANK <= 5
GROUP BY State
ORDER BY TOP_5_APPEARANCE_COUNT DESC;

-- 9. Compare the total number of crimes between Northern and Southern states for each year.

WITH STATE_CATEGORIZED AS (
    SELECT 
        Year,
        CASE 
            WHEN State IN ('Delhi UT', 'Haryana', 'Himachal Pradesh', 'Jammu & Kashmir', 
                           'West Bengal', 'Punjab', 'Rajasthan', 'Uttar Pradesh', 
                           'Uttarakhand', 'Jharkhand') THEN 'Northern'
            WHEN State IN ('Andhra Pradesh', 'Goa', 'Karnataka', 'Kerala', 
                           'Tamil Nadu', 'Telangana', 'Puducherry', 'Lakshadweep') THEN 'Southern'
            ELSE 'Other'
        END AS State_Category,
        SUM(Rape) + SUM(`K&A`) + SUM(`DD`) + SUM(`AoW`) +
        SUM(`AoM`) + SUM(`DV`) + SUM(`WT`) AS Total_Crimes
    FROM CRIME_DETAILS
    GROUP BY Year, State_Category
)
SELECT Year, 
       State_Category, 
       Total_Crimes
FROM STATE_CATEGORIZED
WHERE State_Category IN ('Northern', 'Southern')
ORDER BY Year, State_Category;

-- 10. For each type of crime, find which state reported the highest number of cases in 2020.

WITH CRIME_TOTALS AS (
	SELECT 
		STATE, 
        SUM(RAPE) AS TOTAL_RAPE, 
        SUM(`K&A`) AS TOTAL_KIDNAP_ASSAULT,
        SUM(`DD`) AS TOTAL_DOWRY_DEATHS, 
        SUM(`AoW`) AS TOTAL_ASSAULT_AGAINST_WOMEN, 
        SUM(`AoM`) AS TOTAL_ASSAULT_AGAINST_MODESTY_OF_WOMEN,
        SUM(`DV`) AS TOTAL_DOMESTIC_VIOLENCE, 
        SUM(`WT`) AS TOTAL_WOMEN_TRAFFICKING
	FROM CRIME_DETAILS
    WHERE YEAR = 2020
    GROUP BY STATE
),
MAX_CRIMES AS (
	SELECT 
		'Rape' AS CRIME_TYPE, 
		MAX(TOTAL_RAPE) AS MAX_CASES
	FROM CRIME_TOTALS
    
    UNION ALL 
    SELECT 
		'Kidnap Assault', 
		MAX(TOTAL_KIDNAP_ASSAULT) 
	FROM CRIME_TOTALS
    
    UNION ALL
    SELECT 
		'Dowry Deaths', 
		MAX(TOTAL_DOWRY_DEATHS) 
	FROM CRIME_TOTALS
    
    UNION ALL 
    SELECT 
		'Assault Against Women', 
		MAX(TOTAL_ASSAULT_AGAINST_WOMEN) 
	FROM CRIME_TOTALS
    
    UNION ALL
    SELECT 
		'Assault Against Modesty of Women', 
        MAX(TOTAL_ASSAULT_AGAINST_MODESTY_OF_WOMEN) 
	FROM CRIME_TOTALS
    
    UNION ALL
    SELECT 
		'Domestic Violence', 
		MAX(TOTAL_DOMESTIC_VIOLENCE)
	FROM CRIME_TOTALS
    
    UNION ALL
    SELECT 
		'Women Trafficking', 
		MAX(TOTAL_WOMEN_TRAFFICKING)
	FROM CRIME_TOTALS
)
, 

MAX_CRIME_STATES AS (
	SELECT
		m.CRIME_TYPE, 
        c.STATE AS STATE_WITH_MAX_CRIME,
        CASE 
			WHEN M.CRIME_TYPE = 'Rape' THEN C.TOTAL_RAPE
            WHEN M.CRIME_TYPE = 'Kidnap Assault' THEN C.TOTAL_KIDNAP_ASSAULT
            WHEN M.CRIME_TYPE = 'Dowry Deaths' THEN C.TOTAL_DOWRY_DEATHS
            WHEN M.CRIME_TYPE = 'Assault Against Women' THEN C.TOTAL_ASSAULT_AGAINST_WOMEN
            WHEN M.CRIME_TYPE = 'Assault Against Modesty of Women' THEN C.TOTAL_ASSAULT_AGAINST_MODESTY_OF_WOMEN
            WHEN M.CRIME_TYPE = 'Domestic Violence' THEN C.TOTAL_DOMESTIC_VIOLENCE
            WHEN M.CRIME_TYPE = 'Women Trafficking' THEN C.TOTAL_WOMEN_TRAFFICKING
		END AS MAX_CASES 
	FROM MAX_CRIMES AS M 
	JOIN CRIME_TOTALS AS C ON (M.CRIME_TYPE = 'Rape' AND C.TOTAL_RAPE = M.MAX_CASES) OR 
								(M.CRIME_TYPE = 'Kidnap Assault' AND C.TOTAL_KIDNAP_ASSAULT = M.MAX_CASES) OR 
                                (M.CRIME_TYPE = 'Dowry Deaths' AND C.TOTAL_DOWRY_DEATHS = M.MAX_CASES) OR 
                                (M.CRIME_TYPE = 'Assault Against Women' AND C.TOTAL_ASSAULT_AGAINST_WOMEN = M.MAX_CASES) OR 
                                (M.CRIME_TYPE = 'Assault Against Modesty of Women' AND C.TOTAL_ASSAULT_AGAINST_MODESTY_OF_WOMEN = M.MAX_CASES) OR 
                                (M.CRIME_TYPE = 'Domestic Violence' AND C.TOTAL_DOMESTIC_VIOLENCE = M.MAX_CASES) OR 
                                (M.CRIME_TYPE = 'Women Trafficking' AND C.TOTAL_WOMEN_TRAFFICKING = M.MAX_CASES)
)
SELECT
	CRIME_TYPE,
    STATE_WITH_MAX_CRIME, 
    MAX_CASES
FROM MAX_CRIME_STATES
ORDER BY 3 DESC;


-- 11. What is the trend in the number of crimes in states with the highest populations versus states with the lowest populations?

WITH CRIME_RATE_BY_POPULATION AS (
	SELECT 
		STATE, 
		CASE 
			-- States with a population of 30 Million or above are categorized as highly populated states (17 States)
			WHEN STATE IN ('Uttar Pradesh', 'Maharashtra', 'Bihar', 'West Bengal', 
							'Madhya Pradesh', 'Tamil Nadu', 'Rajasthan', 'Karnataka', 
							'Gujarat', 'Andhra Pradesh', 'Odisha', 'Telangana', 'Assam', 
							'Punjab', 'Jharkhand', 'Kerala', 'Haryana') THEN 'High Population' 
			-- Other states are categorized as low populated states (19 States)
			ELSE 'Low Population'
		END AS POPULATION_CATEGORY,
		SUM(RAPE) + SUM(`K&A`) + SUM(`DD`) + SUM(`AoW`) +
		SUM(`AoM`) + SUM(`DV`) + SUM(`WT`) AS TOTAL_CRIMES
	FROM crime_details
	GROUP BY 1, 2
)
SELECT 
	POPULATION_CATEGORY, 
    SUM(TOTAL_CRIMES) AS TOTAL_CRIMES
FROM CRIME_RATE_BY_POPULATION
GROUP BY 1
ORDER BY 2;

 /*Final Takeaways
🔹 Crimes against women remain a significant issue in certain states and require stronger policies.
🔹 Northern states have higher crime rates compared to Southern states.
🔹 Uttar Pradesh, Maharashtra, and West Bengal consistently rank high in reported crimes.
🔹 State-wise crime patterns differ—some states report more domestic violence, while others see higher kidnapping or trafficking.
🔹 More populated states generally report higher crimes, but factors like governance, awareness, and law enforcement play a crucial role.
*/






