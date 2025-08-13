-- High Level OVerviews
-- -- Rides
SELECT
	COUNT(*) AS total_rides,
    COUNT(DISTINCT start_location) AS unique_starts,
    COUNT(DISTINCT end_location) AS unique_ends,
	MIN(ride_start_time) AS start_date,
    MAX(ride_end_time) AS end_date,
    COUNT(DISTINCT user_id) AS unique_customers,
    COUNT(DISTINCT driver_id) AS unique_drivers,
    SUM(distance_km) AS total_distance,
    SUM(fare_amount) AS total_fare_collected
FROM ride_share_case_study.rides;

-- -- Users
SELECT
	COUNT(DISTINCT user_id) AS total_customers,
    MIN(registration_date) AS earliest_registration,
    MAX(registration_date) AS latest_registration,
    MIN(age) AS youngest_user,
    MAX(age) AS oldest_user,
    COUNT(DISTINCT location) AS unique_locations
FROM ride_share_case_study.users;

-- -- Vehicles
SELECT
	COUNT(DISTINCT vehicle_id) AS total_vehicles,
    COUNT(DISTINCT make) AS unique_makes,
    COUNT(DISTINCT model) AS unique_models,
    MIN(year) AS earliest_year,
    MAX(year) AS latest_year,
    MIN(capacity) AS min_capacity,
    MAX(capacity) AS max_capacity
FROM ride_share_case_study.vehicles;

-- -- Drivers
SELECT
	COUNT(DISTINCT driver_id) AS total_drivers,
    COUNT(DISTINCT vehicle_id) AS unique_vehicles,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    SUM(total_rides) AS total_rides,
    COUNT(CASE WHEN available LIKE '%TRUE%' THEN 1 END) AS total_available,
    COUNT(CASE WHEN available LIKE '%FALSE%' THEN 1 END) AS total_unavailable
FROM ride_share_case_study.drivers;

-- -- Ratings
SELECT 
	COUNT(DISTINCT rating_id) AS total_ratings,
    COUNT(DISTINCT user_id) AS unique_customers,
    MIN(rating_value) AS min_rating,
    MAX(rating_value) AS max_rating,
    COUNT(DISTINCT comments) AS unique_comments,
    MIN(rating_date) AS earliest_rating,
    MAX(rating_date) AS latest_rating
FROM ride_share_case_study.ratings;

-- Detect Duplicates
-- -- Rides
SELECT 
    user_id,
    start_location,
    end_location,
    ride_start_time,
    ride_end_time,
    distance_km,
    fare_amount,
    driver_id,
    COUNT(*) AS duplicate_count
FROM ride_share_case_study.rides
GROUP BY 
    user_id,
    start_location,
    end_location,
    ride_start_time,
    ride_end_time,
    distance_km,
    fare_amount,
    driver_id
HAVING 
    COUNT(*) > 1;

-- -- User
SELECT 
	registration_date,
    age,
    gender,
    location,
    COUNT(*) AS duplicate_count
FROM ride_share_case_study.users
GROUP BY
	registration_date,
    age,
    gender,
    location
HAVING 
	COUNT(*) > 1;

-- -- Vehicles
SELECT
	make,
    model,
    year,
    capacity,
    COUNT(*) AS duplicate_count
FROM ride_share_case_study.vehicles
GROUP BY
	make,
    model,
    year,
    capacity
HAVING 
	COUNT(*) > 1;

-- -- Drivers
SELECT
	vehicle_id,
    rating,
    total_rides,
    available,
    COUNT(*) AS duplicate_count
FROM ride_share_case_study.drivers
GROUP BY
	vehicle_id,
    rating,
    total_rides,
    available
HAVING
	COUNT(*) > 1;

-- -- Ratings
SELECT
	ride_id,
    user_id,
    rating_value,
    comments,
    rating_date,
    COUNT(*) AS duplicate_count
FROM ride_share_case_study.ratings
GROUP BY 
	ride_id,
    user_id,
    rating_value,
    comments,
    rating_date
HAVING
	COUNT(*) > 1;

-- NULL Value checks
-- -- Rides
SELECT
  COUNT(*) AS total_rows,
  COUNT(*) - COUNT(ride_id) AS ride_id_nulls,
  COUNT(*) - COUNT(user_id) AS user_id_nulls,
  COUNT(*) - COUNT(start_location) AS start_location_nulls,
  COUNT(*) - COUNT(end_location) AS end_location_nulls,
  COUNT(*) - COUNT(ride_start_time) AS ride_start_time_nulls,
  COUNT(*) - COUNT(ride_end_time) AS ride_end_time_nulls,
  COUNT(*) - COUNT(distance_km) AS distance_km_nulls,
  COUNT(*) - COUNT(fare_amount) AS fare_amount_nulls,
  COUNT(*) - COUNT(driver_id) AS driver_id_nulls
FROM
  ride_share_case_study.rides;

-- -- Users
SELECT
	COUNT(*) AS total_rows,
    COUNT(*) - COUNT(user_id) AS user_id_nulls,
    COUNT(*) - COUNT(registration_date) AS registration_date_nulls,
    COUNT(*) - COUNT(age) AS age_nulls,
    COUNT(*) - COUNT(gender) AS gender_nulls,
    COUNT(*) - COUNT(location) AS location_nulls
FROM 
	ride_share_case_study.users;
    
-- -- Vehicles
SELECT
	COUNT(*) AS total_rows,
    COUNT(*) - COUNT(make) AS make_nulls,
    COUNT(*) - COUNT(model) AS model_nulls,
    COUNT(*) - COUNT(year) AS year_nulls,
    COUNT(*) - COUNT(capacity) AS capacity_nulls
FROM
	ride_share_case_study.vehicles;

-- -- Drivers
SELECT
	COUNT(*) AS total_rows,
    COUNT(*) - COUNT(driver_id) AS driver_id_nulls,
    COUNT(*) - COUNT(vehicle_id) AS vehicles_id_nulls,
    COUNT(*) - COUNT(rating) AS rating_nulls,
    COUNT(*) - COUNT(total_rides) AS total_rides_nulls,
    COUNT(*) - COUNT(available) AS available_nulls
FROM 
	ride_share_case_study.drivers;
    
-- -- Ratings
SELECT
	COUNT(*) AS total_rows,
    COUNT(*) - COUNT(rating_id) AS rating_id_nulls,
    COUNT(*) - COUNT(ride_id) AS ride_id_nulls,
    COUNT(*) - COUNT(user_id) AS user_id_nulls,
    COUNT(*) - COUNT(rating_value) AS rating_value_nulls,
    COUNT(*) - COUNT(comments) AS comments_nulls,
    COUNT(*) - COUNT(rating_date) AS rating_date_nulls
FROM 
	ride_share_case_study.ratings;
    
-- Plausability checks
-- -- Ride Date check
SELECT * 
FROM ride_share_case_study.rides
WHERE ride_end_time < ride_start_time;

-- -- Rides Negative or Zero Value Checks
SELECT * 
FROM ride_share_case_study.rides
WHERE distance_km <= 0 OR fare_amount < 0;

-- -- Identify Temporal Data Errors
-- -- -- For Drivers
SELECT 
    r1.driver_id,
    r1.ride_id AS ride_1,
    r2.ride_id AS ride_2,
    r1.ride_start_time AS start_1,
    r1.ride_end_time AS end_1,
    r2.ride_start_time AS start_2,
    r2.ride_end_time AS end_2
FROM 
    ride_share_case_study.rides r1
JOIN 
    ride_share_case_study.rides r2 
    ON r1.driver_id = r2.driver_id 
    AND r1.ride_id < r2.ride_id  -- avoid self join and duplicate pairs
    AND r1.ride_end_time > r2.ride_start_time 
    AND r1.ride_start_time < r2.ride_end_time;
    
-- -- -- For Users
SELECT 
    r1.user_id,
    r1.ride_id AS ride_1,
    r2.ride_id AS ride_2,
    r1.ride_start_time AS start_1,
    r1.ride_end_time AS end_1,
    r2.ride_start_time AS start_2,
    r2.ride_end_time AS end_2
FROM 
    ride_share_case_study.rides r1
JOIN 
    ride_share_case_study.rides r2 
    ON r1.user_id = r2.user_id 
    AND r1.ride_id < r2.ride_id  -- avoid self join and duplicate pairs
    AND r1.ride_end_time > r2.ride_start_time 
    AND r1.ride_start_time < r2.ride_end_time;
    
-- -- Identify rides that occurred before rider registration
SELECT 
	r.ride_id,
    r.user_id,
    r.ride_start_time,
    u.registration_date
FROM 
	ride_share_case_study.rides r
JOIN 
	ride_share_case_study.users u
	ON 
		r.user_id = u.user_id
WHERE r.ride_start_time < u.registration_date;

-- Evaluate Hidden Flaws
-- -- Hidden Characters for Rides
SELECT
	COUNT(*) AS total_rows,
  SUM(start_location LIKE '%\r%') AS start_carriage_return_count,
  SUM(start_location LIKE '%\n%') AS start_line_feed_count,
  SUM(start_location LIKE '%\t%') AS start_tab_count,
  SUM(start_location LIKE '%\f%') AS start_form_feed_count,
  SUM(start_location LIKE '%\v%') AS start_vertical_tab_count,
  SUM(start_location LIKE '% %') AS start_non_breaking_space_count,
  SUM(end_location LIKE '%\r%') AS end_carriage_return_count,
  SUM(end_location LIKE '%\n%') AS end_line_feed_count,
  SUM(end_location LIKE '%\t%') AS end_tab_count,
  SUM(end_location LIKE '%\f%') AS end_form_feed_count,
  SUM(end_location LIKE '%\v%') AS end_vertical_tab_count,
  SUM(end_location LIKE '% %') AS end_non_breaking_space_count
FROM ride_share_case_study.rides;

-- -- Hidden Characters for Users
SELECT
	COUNT(*) AS total_rows,
  SUM(gender LIKE '%\r%') AS gender_carriage_return_count,
  SUM(gender LIKE '%\n%') AS gender_line_feed_count,
  SUM(gender LIKE '%\t%') AS gender_tab_count,
  SUM(gender LIKE '%\f%') AS gender_form_feed_count,
  SUM(gender LIKE '%\v%') AS gender_vertical_tab_count,
  SUM(gender LIKE '% %') AS gender_non_breaking_space_count,
  SUM(location LIKE '%\r%') AS loc_carriage_return_count,
  SUM(location LIKE '%\n%') AS loc_line_feed_count,
  SUM(location LIKE '%\t%') AS loc_tab_count,
  SUM(location LIKE '%\f%') AS loc_form_feed_count,
  SUM(location LIKE '%\v%') AS loc_vertical_tab_count,
  SUM(location LIKE '% %') AS loc_non_breaking_space_count
FROM ride_share_case_study.users;

-- -- Hidden Characters for Vehicles
SELECT
	COUNT(*) AS total_rows,
  SUM(make LIKE '%\r%') AS make_carriage_return_count,
  SUM(make LIKE '%\n%') AS make_line_feed_count,
  SUM(make LIKE '%\t%') AS make_tab_count,
  SUM(make LIKE '%\f%') AS make_form_feed_count,
  SUM(make LIKE '%\v%') AS make_vertical_tab_count,
  SUM(make LIKE '% %') AS make_non_breaking_space_count,
  SUM(model LIKE '%\r%') AS model_carriage_return_count,
  SUM(model LIKE '%\n%') AS model_line_feed_count,
  SUM(model LIKE '%\t%') AS model_tab_count,
  SUM(model LIKE '%\f%') AS model_form_feed_count,
  SUM(model LIKE '%\v%') AS model_vertical_tab_count,
  SUM(model LIKE '% %') AS model_non_breaking_space_count
FROM ride_share_case_study.vehicles;

-- -- Hidden Characters for drivers
SELECT
  COUNT(*) AS total_rows,
  SUM(available LIKE '%\r%') AS carriage_return_count,
  SUM(available LIKE '%\n%') AS line_feed_count,
  SUM(available LIKE '%\t%') AS tab_count,
  SUM(available LIKE '%\f%') AS form_feed_count,
  SUM(available LIKE '%\v%') AS vertical_tab_count,
  SUM(available LIKE '% %') AS non_breaking_space_count  -- <- NBSP (Alt+0160)
FROM ride_share_case_study.drivers;

-- -- Hidden Characters for Ratings
SELECT
  COUNT(*) AS total_rows,
  SUM(comments LIKE '%\r%') AS carriage_return_count,
  SUM(comments LIKE '%\n%') AS line_feed_count,
  SUM(comments LIKE '%\t%') AS tab_count,
  SUM(comments LIKE '%\f%') AS form_feed_count,
  SUM(comments LIKE '%\v%') AS vertical_tab_count,
  SUM(comments LIKE '% %') AS non_breaking_space_count
FROM ride_share_case_study.ratings;

-- Users not in Ride Data
SELECT 
	u.user_id,
    u.registration_date,
    u.age,
    u.gender,
    u.location
FROM ride_share_case_study.users u
LEFT JOIN ride_share_case_study.rides r
	ON u.user_id = r.user_id
WHERE r.user_id IS NULL;

-- Drivers Not in Rides Table
SELECT 
	d.driver_id,
    d.vehicle_id,
    d.rating,
    d.total_rides,
    d.available
FROM ride_share_case_study.drivers d
LEFT JOIN ride_share_case_study.rides r
	ON d.driver_id = r.driver_id
WHERE r.driver_id IS NULL;

-- Vehicles not in Drivers Table
SELECT 
	v.vehicle_id,
    v.make,
    v.model,
    v.year,
    v.capacity
FROM ride_share_case_study.vehicles v
LEFT JOIN ride_share_case_study.drivers d
	ON v.vehicle_id = d.vehicle_id
WHERE d.vehicle_id IS NULL;