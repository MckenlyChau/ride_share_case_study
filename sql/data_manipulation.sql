-- Age Bucketing Users
ALTER TABLE ride_share_case_study.users ADD age_bucket VARCHAR(10);

UPDATE ride_share_case_study.users
SET age_bucket = CASE
  WHEN age BETWEEN 18 AND 25 THEN '18–25'
  WHEN age BETWEEN 26 AND 35 THEN '26–35'
  WHEN age BETWEEN 36 AND 45 THEN '36–45'
  WHEN age BETWEEN 46 AND 55 THEN '46–55'
  WHEN age BETWEEN 56 AND 65 THEN '56–65'
  ELSE 'Unknown'  -- In case of bad/missing data
END;

-- Recorded Earnings for Drivers
ALTER TABLE ride_share_case_study.drivers ADD recorded_earning DECIMAL(10,2);

UPDATE ride_share_case_study.drivers d
JOIN (
  SELECT driver_id, SUM(fare_amount) AS total_earnings
  FROM ride_share_case_study.rides
  GROUP BY driver_id
) r ON d.driver_id = r.driver_id
SET d.recorded_earning = r.total_earnings;

-- Recorded Distance for Drivers
ALTER TABLE ride_share_case_study.drivers ADD recorded_distance DECIMAL(10,2);

UPDATE ride_share_case_study.drivers d
JOIN (
  SELECT driver_id, SUM(distance_km) AS total_distance
  FROM ride_share_case_study.rides
  GROUP BY driver_id
) r ON d.driver_id = r.driver_id
SET d.recorded_distance = r.total_distance;

-- Recorded Spend for Users
ALTER TABLE ride_share_case_study.users ADD recorded_spend DECIMAL(10,2);

UPDATE ride_share_case_study.users u
JOIN (
  SELECT user_id, SUM(fare_amount) AS total_spend
  FROM ride_share_case_study.rides
  GROUP BY user_id
) r ON u.user_id = r.user_id
SET u.recorded_spend = r.total_spend;

-- Recorded Distance for Users
ALTER TABLE ride_share_case_study.users ADD recorded_distance DECIMAL(10,2);

UPDATE ride_share_case_study.users u
JOIN (
  SELECT user_id, SUM(distance_km) AS total_distance
  FROM ride_share_case_study.rides
  GROUP BY user_id
) r ON u.user_id = r.user_id
SET u.recorded_distance = r.total_distance;

-- Separate DATE TIME in Rides
-- -- Create Columns
ALTER TABLE ride_share_case_study.rides
ADD COLUMN start_date DATE,
ADD COLUMN start_time TIME,
ADD COLUMN end_date DATE,
ADD COLUMN end_time TIME;
-- -- Set Columns
UPDATE ride_share_case_study.rides
SET
	start_date = DATE(ride_start_time),
    start_time = TIME(ride_start_time),
    end_date = DATE(ride_end_time),
    end_time = TIME(ride_end_time);
-- -- Remove Older Columns
ALTER TABLE ride_share_case_study.rides
DROP COLUMN ride_start_time,
DROP COLUMN ride_end_time;
-- -- Reorganize columns
ALTER TABLE ride_share_case_study.rides
MODIFY COLUMN start_date DATE AFTER end_location,
MODIFY COLUMN start_time TIME AFTER start_date,
MODIFY COLUMN end_date DATE AFTER start_time,
MODIFY COLUMN end_time TIME AFTER end_date;

-- Seperate DATE TIME for Users
-- -- CREATE Columns
ALTER TABLE ride_share_case_study.users
ADD COLUMN registration_date_only DATE,
ADD COLUMN registration_time TIME;
-- -- SET COLUMN
UPDATE ride_share_case_study.users
SET
	registration_date_only = DATE(registration_date),
	registration_time = TIME(registration_date);
-- -- Remove Older COLUMN
ALTER TABLE ride_share_case_study.users
DROP COLUMN registration_date;
-- -- Rename Column
ALTER TABLE ride_share_case_study.users
CHANGE registration_date_only registration_date DATE;
-- -- Reorganize Columns
ALTER TABLE ride_share_case_study.users
MODIFY COLUMN registration_date DATE AFTER user_id,
MODIFY COLUMN registration_time TIME AFTER registration_date;

-- Seperate DATE TIME in Ratings
-- -- CREATE Columns
ALTER TABLE ride_share_case_study.ratings
ADD COLUMN rating_date_only DATE,
ADD COLUMN rating_time TIME;
-- -- SET COLUMN
UPDATE ride_share_case_study.ratings
SET
	rating_date_only = DATE(rating_date),
	rating_time = TIME(rating_date);
-- -- Remove Older COLUMN
ALTER TABLE ride_share_case_study.ratings
DROP COLUMN rating_date;
-- -- Rename Column
ALTER TABLE ride_share_case_study.ratings
CHANGE rating_date_only rating_date DATE;

-- RFM prep
-- -- User Columns
-- -- -- Add the new columns
ALTER TABLE ride_share_case_study.users
ADD COLUMN earliest_ride_date DATE,
ADD COLUMN latest_ride_date DATE,
ADD COLUMN recorded_rides INT;

-- -- -- Populate the new columns
UPDATE ride_share_case_study.users u
JOIN (
  SELECT
    user_id,
    MIN(start_date) AS first_ride,
    MAX(start_date) AS last_ride,
    COUNT(*) AS ride_count
  FROM ride_share_case_study.rides
  GROUP BY user_id
) r ON u.user_id = r.user_id
SET 
  u.earliest_ride_date = r.first_ride,
  u.latest_ride_date = r.last_ride,
  u.recorded_rides = r.ride_count;

-- -- Driver Columns
-- -- -- Add the new columns
ALTER TABLE ride_share_case_study.drivers
ADD COLUMN earliest_ride_date DATE,
ADD COLUMN latest_ride_date DATE,
ADD COLUMN recorded_rides INT;

-- -- -- Populate the new columns
UPDATE ride_share_case_study.drivers d
JOIN (
  SELECT
    driver_id,
    MIN(start_date) AS first_ride,
    MAX(start_date) AS last_ride,
    COUNT(*) AS ride_count
  FROM ride_share_case_study.rides
  GROUP BY driver_id
) r ON d.driver_id = r.driver_id
SET 
  d.earliest_ride_date = r.first_ride,
  d.latest_ride_date = r.last_ride,
  d.recorded_rides = r.ride_count;
  
-- Apply Users and Driver to Ratings Table
-- -- Add the new columns
ALTER TABLE ride_share_case_study.ratings
ADD COLUMN driver_id INT;

-- -- Populate the new column and correct incorrect column
UPDATE ride_share_case_study.ratings r1
JOIN ride_share_case_study.rides r2 ON r1.ride_id = r2.ride_id
SET 
  r1.user_id = r2.user_id, -- Rides table is considered the correct data for sake of Data integrity
  r1.driver_id = r2.driver_id;
  
-- -- Organize new Column
ALTER TABLE ride_share_case_study.ratings
MODIFY driver_id INT AFTER user_id;

-- Recorded Driver Rating Averages
-- -- Add the new columns
ALTER TABLE ride_share_case_study.drivers
ADD COLUMN recorded_rating DECIMAL(5,2);

-- -- Populate the new column 
UPDATE ride_share_case_study.drivers d
JOIN (
	SELECT
		driver_id,
		AVG(rating_value) AS average_rating
	FROM ride_share_case_study.ratings
    GROUP BY driver_id
    ) r ON d.driver_id = r.driver_id
SET 
  d.recorded_rating = r.average_rating;
  
-- RFM Model Tables
-- -- Users
-- -- -- Create New Table
CREATE TABLE ride_share_case_study.rfm_users AS (
	SELECT
		user_id,
        registration_date,
        age_bucket,
        gender,
        location,
        latest_ride_date AS churn_date,
        recorded_distance AS distance,
        DATEDIFF('2024-10-04', latest_ride_date) AS recency, -- Using 2024-10-04 as it is last recorded date in the dataset
        recorded_rides AS frequency,
        recorded_spend AS monetary
	FROM ride_share_case_study.users
    );

-- -- -- Add the new columns
ALTER TABLE ride_share_case_study.rfm_users
ADD COLUMN r_score INT,
ADD COLUMN f_score INT,
ADD COLUMN m_score INT,
ADD COLUMN rfm_segment VARCHAR(3),
ADD COLUMN rfm_class VARCHAR(20),
ADD COLUMN estimated_clv INT;

-- -- -- Use a CTE to rank users for each metric
WITH scored AS (
  SELECT
    user_id,
    NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
  FROM ride_share_case_study.rfm_users
)
UPDATE ride_share_case_study.rfm_users AS u
JOIN scored AS s USING (user_id)
SET
  u.r_score = s.r_score,
  u.f_score = s.f_score,
  u.m_score = s.m_score;

-- -- -- Create RFM segment code
UPDATE ride_share_case_study.rfm_users
SET rfm_segment = CONCAT(r_score, f_score, m_score);

-- -- -- Classify RFM segments
UPDATE ride_share_case_study.rfm_users
SET rfm_class = 
  CASE
    WHEN rfm_segment = '555' THEN 'Top Spender'
    WHEN r_score >= 4 AND f_score >= 4 THEN 'Loyal Spender'
    WHEN r_score >= 3 AND f_score <= 2 THEN 'At Risk Spender'
    WHEN r_score <= 2 AND f_score <= 2 THEN 'Churned Spender'
    ELSE 'Other'
  END;

-- -- -- Calculate Estimated Customer Lifetime value
UPDATE ride_share_case_study.rfm_users
SET estimated_clv = 
  CASE
    WHEN rfm_class = 'Top Spender' THEN IFNULL(monetary, 0) * 5
    WHEN rfm_class = 'Loyal Spender' THEN IFNULL(monetary, 0) * 4
    WHEN rfm_class = 'At Risk Spender' THEN IFNULL(monetary, 0) * 2
    WHEN rfm_class = 'Churned Spender' THEN IFNULL(monetary, 0) * 1
    ELSE IFNULL(monetary, 0) * 3
  END;

-- -- Drivers
-- -- -- Create New Table
CREATE TABLE ride_share_case_study.rfm_drivers AS (
	SELECT
		driver_id,
        vehicle_id,
        recorded_rating AS rating,
        available,
        latest_ride_date AS churn_date,
        recorded_distance AS distance,
        DATEDIFF('2024-10-04', latest_ride_date) AS recency, -- Using 2024-10-04 as it is last recorded date in the dataset
        recorded_rides AS frequency,
        recorded_earning AS monetary
	FROM ride_share_case_study.drivers
    );

-- -- -- Add the new columns
ALTER TABLE ride_share_case_study.rfm_drivers
ADD COLUMN r_score INT,
ADD COLUMN f_score INT,
ADD COLUMN m_score INT,
ADD COLUMN rfm_segment VARCHAR(3),
ADD COLUMN rfm_class VARCHAR(20),
ADD COLUMN estimated_elv INT;

-- -- -- Use a CTE to rank drivers for each metric
WITH scored AS (
  SELECT
    driver_id,
    NTILE(5) OVER (ORDER BY recency DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
  FROM ride_share_case_study.rfm_drivers
)
UPDATE ride_share_case_study.rfm_drivers AS d
JOIN scored AS s USING (driver_id)
SET
  d.r_score = s.r_score,
  d.f_score = s.f_score,
  d.m_score = s.m_score;

-- -- -- Create RFM segment code
UPDATE ride_share_case_study.rfm_drivers
SET rfm_segment = CONCAT(r_score, f_score, m_score);

-- -- -- Classify RFM segments
UPDATE ride_share_case_study.rfm_drivers
SET rfm_class = 
  CASE
    WHEN rfm_segment = '555' THEN 'Top Earner'
    WHEN r_score >= 4 AND f_score >= 4 THEN 'Loyal Earner'
    WHEN r_score >= 3 AND f_score <= 2 THEN 'At Risk Earner'
    WHEN r_score <= 2 AND f_score <= 2 THEN 'Churned Earner'
    ELSE 'Other'
  END;

-- -- -- Calculate Estimated Earner Lifetime value
UPDATE ride_share_case_study.rfm_drivers
SET estimated_elv = 
  CASE
    WHEN rfm_class = 'Top Earner' THEN IFNULL(monetary, 0) * 5
    WHEN rfm_class = 'Loyal Earner' THEN IFNULL(monetary, 0) * 4
    WHEN rfm_class = 'At Risk Earner' THEN IFNULL(monetary, 0) * 2
    WHEN rfm_class = 'Churned Earner' THEN IFNULL(monetary, 0) * 1
    ELSE IFNULL(monetary, 0) * 3
  END;

