-- Query 6) Repeat Passenger Frequency and City Contribution Analysis
-- Analyse the frequency of trips taken by repeat passengers in each city (e.g., % of repeat passengers taking 2 trips, 3 trips, etc.)
-- Identify which cities contribute most to higher trip frequencies among repeat passengers
-- examine if there are distinguishable patterns between tourism-focused and business-focused cities
WITH trip_table AS (
SELECT 
dim_city.city_name AS City_Name,
dim_repeat_trip_distribution.trip_count AS Trip_Count,
SUM(dim_repeat_trip_distribution.repeat_passenger_count) AS Total_Repeat_Passengers
FROM  dim_repeat_trip_distribution
JOIN dim_city
ON dim_repeat_trip_distribution.city_id = dim_city.city_id
GROUP BY City_Name, Trip_Count
),
total_table AS (
SELECT 
City_Name,
Trip_Count,
Total_Repeat_Passengers,
SUM(Total_Repeat_Passengers) OVER (PARTITION BY City_Name) AS Total_Passengers
FROM trip_table
)
SELECT
City_Name,
    ROUND(SUM(CASE WHEN Trip_Count = 2 THEN Total_Repeat_Passengers * 100.0 / Total_Passengers END), 0) AS '2-Trips',
    ROUND(SUM(CASE WHEN Trip_Count = 3 THEN Total_Repeat_Passengers * 100.0 / Total_Passengers END), 0) AS '3-Trips',
    ROUND(SUM(CASE WHEN Trip_Count = 4 THEN Total_Repeat_Passengers * 100.0 / Total_Passengers END), 0) AS '4-Trips',
    ROUND(SUM(CASE WHEN Trip_Count = 5 THEN Total_Repeat_Passengers * 100.0 / Total_Passengers END), 0) AS '5-Trips',
    ROUND(SUM(CASE WHEN Trip_Count = 6 THEN Total_Repeat_Passengers * 100.0 / Total_Passengers END), 0) AS '6-Trips',
    ROUND(SUM(CASE WHEN Trip_Count = 7 THEN Total_Repeat_Passengers * 100.0 / Total_Passengers END), 0) AS '7-Trips',
    ROUND(SUM(CASE WHEN Trip_Count = 8 THEN Total_Repeat_Passengers * 100.0 / Total_Passengers END), 0) AS '8-Trips',
    ROUND(SUM(CASE WHEN Trip_Count = 9 THEN Total_Repeat_Passengers * 100.0 / Total_Passengers END), 0) AS '9-Trips',
    ROUND(SUM(CASE WHEN Trip_Count = 10 THEN Total_Repeat_Passengers * 100.0 / Total_Passengers END), 0) AS '10-Trips'
FROM  total_table
GROUP BY City_Name;