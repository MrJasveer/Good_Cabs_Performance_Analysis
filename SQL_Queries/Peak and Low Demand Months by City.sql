-- Query 4)	Peak and Low Demand Months by City
-- For each city, identify the month with the highest total trips (peak demand) and the month with the lowest total trips (low demand). 
-- This analysis will help Goodcabs understand seasonal patterns and adjust resources accordingly.

WITH Trip_Counts AS (
SELECT 
    dim_city.city_name AS City_Name,
    MONTH(fact_trips.`date`) AS `Month`,
    COUNT(fact_trips.trip_id) AS Total_Trips
FROM
    fact_trips
        JOIN
    dim_city ON dim_city.city_id = fact_trips.city_id
GROUP BY City_Name , `Month`),
Peak_Demand AS (
SELECT 
    City_Name, `Month` AS Peak_Month, Total_Trips AS Peak_Trips
FROM
    Trip_Counts
WHERE
    Total_Trips = (SELECT 
    MAX(Total_Trips)
FROM
    Trip_Counts tc
WHERE
    tc.City_Name = Trip_Counts.City_Name)
),
Low_Demand AS (
SELECT 
    City_Name, `Month` AS Low_Month, Total_Trips AS Low_Trips
FROM
    Trip_Counts
WHERE
    Total_Trips = (SELECT 
    MIN(Total_Trips)
FROM
    Trip_Counts tc
WHERE
    tc.City_Name = Trip_Counts.City_Name)
)
SELECT 
    p.City_Name,
    p.Peak_Month,
    p.Peak_Trips,
    l.Low_Month,
    l.Low_Trips
FROM
    Peak_Demand p
        JOIN
    Low_Demand l ON p.City_Name = l.City_Name;