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