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