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