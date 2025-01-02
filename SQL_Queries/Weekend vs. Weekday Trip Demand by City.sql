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