-- Query 8) Highest and Lowest Repeat Passenger Rate (RPR%) by City and Month
-- I.	Analyse the Repeat Passenger Rate (RPR%) for each city across the six-month period. 
-- Identify the top 2 and bottom 2 cities based on their RPR% to determine which locations have the strongest and weakest rates.
-- II.	Similarly, analyse the RPR% by month across all cities and identify the months with the highest and lowest repeat passenger rates. 
-- This will help to pin-point any seasonal patterns or months with higher repeat passenger loyalty

-- Top 2 Cities With High RPR
SELECT fps.city_id AS City_ID,
dc.city_name AS City_Name,
SUM(fps.total_passengers) AS Total_Passengers,
SUM(fps.repeat_passengers) AS Repeat_Passengers,
ROUND(AVG(ROUND(((`Total_Passengers` - `Repeat_Passengers`) * 100 / `Total_Passengers`), 2)), 2) AS RPR_Percent
FROM fact_passenger_summary fps
JOIN dim_city dc
ON fps.city_id = dc.city_id
GROUP BY 1
ORDER BY 5 DESC
LIMIT 2;

-- Bottom 2 Cities With Low RPR
SELECT fps.city_id AS City_ID,
dc.city_name AS City_Name,
SUM(fps.total_passengers) AS Total_Passengers,
SUM(fps.repeat_passengers) AS Repeat_Passengers,
ROUND(AVG(ROUND(((`Total_Passengers` - `Repeat_Passengers`) * 100 / `Total_Passengers`), 2)), 2) AS RPR_Percent
FROM fact_passenger_summary fps
JOIN dim_city dc
ON fps.city_id = dc.city_id
GROUP BY 1
ORDER BY 5 ASC
LIMIT 2;

-- Top 2 Months With High RPR
SELECT MONTH(`month`) AS `Month`,
SUM(total_passengers) AS Total_Passengers,
SUM(repeat_passengers) AS Repeat_Passengers,
ROUND(AVG(ROUND(((`Total_Passengers` - `Repeat_Passengers`) * 100 / `Total_Passengers`), 2)), 2) AS RPR_Percent
FROM fact_passenger_summary fps
GROUP BY 1
ORDER BY 4 DESC
LIMIT 2;

-- Bottom 2 Months With Low RPR
SELECT MONTH(`month`) AS `Month`,
SUM(total_passengers) AS Total_Passengers,
SUM(repeat_passengers) AS Repeat_Passengers,
ROUND(AVG(ROUND(((`Total_Passengers` - `Repeat_Passengers`) * 100 / `Total_Passengers`), 2)), 2) AS RPR_Percent
FROM fact_passenger_summary fps
GROUP BY 1
ORDER BY 4 ASC
LIMIT 2;