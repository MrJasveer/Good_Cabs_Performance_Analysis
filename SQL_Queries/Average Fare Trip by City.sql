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