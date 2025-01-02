-- Query 1) Top & Botton Performing Cities
-- Identify the top 3 and bottom 3 cities by total trips over the entire analysis period.

-- Top 3 Performing Cities
SELECT 
    dim_city.city_name AS City_Name,
    COUNT(fact_trips.trip_id) AS Total_Trips
FROM
    fact_trips
        JOIN
    dim_city ON dim_city.city_id = fact_trips.city_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 3;

-- Bottom 3 Performing Cities
SELECT 
    dim_city.city_name AS City_Name,
    COUNT(fact_trips.trip_id) AS Total_Trips
FROM
    fact_trips
        JOIN
    dim_city ON dim_city.city_id = fact_trips.city_id
GROUP BY 1
ORDER BY 2 ASC
LIMIT 3;

-- Query 2) Average Fare Trip by City & Comparing it with Average trip distance
-- Calculate the average fare per trip for each city and compare it with the citys average trip distance. 
-- Identify the cities with the highest and lowest average fare per trip to assess pricing efficiency across locations.

-- City with Highest Avergae
SELECT 
    dim_city.city_name AS City_Name,
    ROUND(AVG(fact_trips.fare_amount), 0) AS Avg_Fare_Amount,
    ROUND(AVG(fact_trips.distance_travelled_km), 0) AS Avg_Kms_Travelled
FROM
    fact_trips
        JOIN
    dim_city ON dim_city.city_id = fact_trips.city_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

-- City with Lowest Average
SELECT 
    dim_city.city_name AS City_Name,
    ROUND(AVG(fact_trips.fare_amount), 0) AS Avg_Fare_Amount,
    ROUND(AVG(fact_trips.distance_travelled_km), 0) AS Avg_Kms_Travelled
FROM
    fact_trips
        JOIN
    dim_city ON dim_city.city_id = fact_trips.city_id
GROUP BY 1
ORDER BY 2 ASC
LIMIT 1;

-- Query 3) Avg Ratings by city & passenger type
-- Calculate the average passenger and driver ratings for each city, segmented by passenger type (new vs. repeat). 
-- Identify cities with the highest and lowest average ratings.

-- Top Rated City
SELECT 
    dim_city.city_name AS City_Name,
    fact_trips.passenger_type AS Passenger_Type,
    AVG(fact_trips.passenger_rating) AS Avg_Passenger_Rating,
    AVG(fact_trips.driver_rating) AS Avg_Driver_Rating
FROM
    fact_trips
        JOIN
    dim_city ON dim_city.city_id = fact_trips.city_id
GROUP BY 1, 2
ORDER BY Avg_Passenger_Rating DESC, Avg_Driver_Rating DESC
limit 1;

-- Low Rated City
SELECT 
    dim_city.city_name AS City_Name,
    fact_trips.passenger_type AS Passenger_Type,
    AVG(fact_trips.passenger_rating) AS Avg_Passenger_Rating,
    AVG(fact_trips.driver_rating) AS Avg_Driver_Rating
FROM
    fact_trips
        JOIN
    dim_city ON dim_city.city_id = fact_trips.city_id
GROUP BY 1, 2
ORDER BY Avg_Passenger_Rating ASC, Avg_Driver_Rating ASC
limit 1;

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

-- Query 5) Weekend vs. Weekday Trip Demand by City
-- Compare the total trips taken on weekdays versus weekends for each city over the six-month period
-- Identify cities with a strong preference for either weekend or weekday trips to understand demand variations
WITH Trip_Count AS(
SELECT 
    dim_city.city_name AS City_Name,
    dim_date.day_type AS Day_Type,
    COUNT(fact_trips.trip_id) AS Total_Trips
FROM
    fact_trips
        JOIN
    dim_city ON dim_city.city_id = fact_trips.city_id
        JOIN
    dim_date ON dim_date.`date` = fact_trips.`date`
GROUP BY City_Name , Day_Type),
Trip_Comparison AS (
		SELECT 
    City_name,
    SUM(CASE
        WHEN Day_type = 'Weekday' THEN Total_trips
        ELSE 0
		END) AS Weekday_trips,
    SUM(CASE
        WHEN Day_type = 'Weekend' THEN Total_trips
        ELSE 0
		END) AS Weekend_trips
FROM
    Trip_Count
GROUP BY City_name
		)

SELECT 
    City_name,
    Weekday_trips,
    Weekend_trips,
    Weekday_trips - Weekend_trips AS Trip_difference,
    CASE 
        WHEN Weekday_trips > Weekend_trips THEN 'Weekday'
        WHEN Weekday_trips < Weekend_trips THEN 'Weekend'
        ELSE 'Equal Demand'
    END AS Preference
FROM Trip_Comparison
ORDER BY Trip_difference DESC;

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

-- Query 7) Monthly Target Achievement Analysis for Key Metrics --
-- For each city, evaluate monthly performance against targets for total trips, new passengers, and average passenger ratings 
-- from targets db. Determine if each metric met, exceeded, or missed the target, and calculate the percentage difference. 
-- Identify any consistent patterns in target achievement, particularly across tourism versus business-focused cities.

-- Passenger Rating Achievement by City
SELECT
dc.city_id AS City_ID,
dc.city_name AS City_Name,
ctpr.target_avg_passenger_rating AS Target_Avg_Passenger_Rating,
ROUND(AVG(ft.passenger_rating), 2) AS Actual_Passenger_Rating,
ROUND(ROUND(AVG((ft.passenger_rating) - ctpr.target_avg_passenger_rating), 2) * 100 / ctpr.target_avg_passenger_rating , 2) AS Percentage_Difference,
CASE WHEN 
ctpr.target_avg_passenger_rating <= ROUND(AVG(ft.passenger_rating), 2) THEN 'Target Achieved'
ELSE 'Target Not Achieved'
END AS Target_Data
FROM fact_trips ft
JOIN dim_city dc
ON ft.city_id = dc.city_id
JOIN targets_db.city_target_passenger_rating ctpr
ON ft.city_id = ctpr.city_id
GROUP BY City_ID;

-- Monthly New Passenger Achievement by City
SELECT
dc.city_id AS City_ID,
dc.city_name AS City_Name,
fps.`month` AS Target_Month,
mtnp.target_new_passengers AS Targeted_New_Passenger,
fps.new_passengers AS Actual_New_Passenger,
ROUND((fps.new_passengers - mtnp.target_new_passengers) * 100 / mtnp.target_new_passengers, 2) AS Percentage_Difference,
CASE WHEN 
mtnp.target_new_passengers <= fps.new_passengers THEN 'Target Achieved'
ELSE 'Target Not Achieved'
END AS Target_Data
FROM fact_passenger_summary fps
JOIN dim_city dc
ON fps.city_id = dc.city_id
JOIN targets_db.monthly_target_new_passengers mtnp
ON fps.city_id = mtnp.city_id;

-- Monthly Target Trips Achievement Data
WITH actual_table AS(
SELECT dc.city_id AS at_City_ID,
dc.city_name AS at_City_Name,
MONTH(ft.`date`) AS `Month`,
COUNT(ft.trip_id) AS Actual_Trips
FROM fact_trips ft
JOIN dim_city dc
ON ft.city_id = dc.city_id
GROUP BY 1, 3),
target_table AS(
SELECT mtt.city_id AS tt_City_ID,
dc.city_name AS tt_City_Name,
mtt.total_target_trips AS Target_Trips
FROM targets_db.monthly_target_trips mtt
JOIN dim_city dc
ON mtt.city_id = dc.city_id)
SELECT `Month`,
tt_City_ID AS City_ID,
tt_City_Name AS City_Name,
Actual_Trips,
Target_Trips,
CASE WHEN 
Target_Trips <= Actual_Trips THEN 'Target Achieved'
ELSE 'Target Not Achieved'
END AS Target_Data,
ROUND(((Actual_Trips - Target_Trips) * 100 / Target_Trips), 2) AS Percentage_Difference
FROM target_table
JOIN actual_table
ON target_table.tt_City_ID = actual_table.at_City_ID;

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
