SELECT 
  'ride_id', 'user_id', 'start_location', 'end_location', 'start_date', 'start_time', 
  'end_date', 'end_time', 'distance_km', 'fare_amount', 'driver_id', 'shared_flag', 'registered_flag'
UNION ALL
SELECT 
  ride_id, user_id, start_location, end_location, start_date, start_time, 
  end_date, end_time, distance_km, fare_amount, driver_id, shared_flag, registered_flag
FROM cleaned_ride_share.rides
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/rides.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT 
  'user_id', 'registration_date', 'age_bucket', 'gender', 'location', 'churn_date', 
  'distance', 'recency', 'frequency', 'monetary', 'r_score', 'f_score', 'm_score',
  'rfm_segment', 'rfm_class', 'estimated_clv'
UNION ALL
SELECT  
  user_id, registration_date, age_bucket, gender, location, churn_date, 
  distance, recency, frequency, monetary, r_score, f_score, m_score,
  rfm_segment, rfm_class, estimated_clv
FROM cleaned_ride_share.users
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT 
	'driver_id', 'vehicle_id', 'rating', 'available', 'churn_date', 'distance', 
	'recency', 'frequency', 'monetary', 'r_score', 'f_score', 'm_score',
	'rfm_segment', 'rfm_class', 'estimated_elv'
UNION ALL
SELECT  
	driver_id, vehicle_id, rating, available, churn_date, distance, 
	recency, frequency, monetary, r_score, f_score, m_score,
	rfm_segment, rfm_class, estimated_elv
FROM cleaned_ride_share.drivers
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/drivers.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT 
	'vehicle_id', 'make', 'model', 'year', 'capacity', 'inactive_flag'
UNION ALL
SELECT
	vehicle_id, make, model, year, capacity, inactive_flag
FROM cleaned_ride_share.vehicles
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/vehicles.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';

SELECT
	'rating_id', 'ride_id', 'user_id', 'driver_id', 'rating_value', 'rating_date', 'rating_time'
UNION ALL
SELECT
	rating_id, ride_id, user_id, driver_id, rating_value, rating_date, rating_time
FROM cleaned_ride_share.ratings
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ratings.csv'
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n';