-- Backup Database
CREATE DATABASE ride_share_case_study_backup;

CREATE TABLE ride_share_case_study_backup.rides
	SELECT *
    FROM ride_share_case_study.rides;
CREATE TABLE ride_share_case_study_backup.users
	SELECT *
    FROM ride_share_case_study.users;
CREATE TABLE ride_share_case_study_backup.vehicles
	SELECT *
    FROM ride_share_case_study.vehicles;
CREATE TABLE ride_share_case_study_backup.drivers
	SELECT *
    FROM ride_share_case_study.drivers;
CREATE TABLE ride_share_case_study_backup.ratings
	SELECT *
    FROM ride_share_case_study.ratings;

-- Flag Shared Rides
-- -- Add the new column
ALTER TABLE ride_share_case_study.rides
ADD COLUMN shared_flag VARCHAR(10);

-- -- Default all to 'Solo' first 
UPDATE ride_share_case_study.rides
SET shared_flag = 'Solo';

-- -- Create indexes to make joins function better
CREATE INDEX idx_driver ON ride_share_case_study.rides(driver_id);
CREATE INDEX idx_times ON ride_share_case_study.rides(ride_start_time, ride_end_time);
CREATE INDEX idx_ride_id ON ride_share_case_study.rides(ride_id);

-- -- Update shared rides first part
UPDATE ride_share_case_study.rides r1
JOIN ride_share_case_study.rides r2
  ON r1.driver_id = r2.driver_id
  AND r1.ride_id < r2.ride_id
  AND r1.ride_end_time > r2.ride_start_time
  AND r1.ride_start_time < r2.ride_end_time
SET r1.shared_flag = 'Shared';

-- -- Update shared rides second part
UPDATE ride_share_case_study.rides r2
JOIN ride_share_case_study.rides r1
  ON r1.driver_id = r2.driver_id
  AND r1.ride_id < r2.ride_id
  AND r1.ride_end_time > r2.ride_start_time
  AND r1.ride_start_time < r2.ride_end_time
SET r2.shared_flag = 'Shared';

-- Remove overlapping user rides
-- -- Composite Index for users
CREATE INDEX idx_user_time ON ride_share_case_study.rides(user_id, ride_start_time, ride_end_time, ride_id);

-- -- Delete second half of overlapping user rides
DELETE FROM ride_share_case_study.rides
WHERE ride_id IN (
  SELECT ride_id FROM (
    SELECT DISTINCT r2.ride_id
    FROM ride_share_case_study.rides r1
    JOIN ride_share_case_study.rides r2 
      ON r1.user_id = r2.user_id
      AND r1.ride_id < r2.ride_id
      AND r1.ride_end_time > r2.ride_start_time
      AND r1.ride_start_time < r2.ride_end_time
  ) AS to_delete
);

-- -- Delete ratings for rides that were removed
DELETE r1
FROM ride_share_case_study.ratings r1
LEFT JOIN ride_share_case_study.rides r2
  ON r1.ride_id = r2.ride_id
WHERE r2.ride_id IS NULL;

-- Remove Carriage returns for Drivers
UPDATE ride_share_case_study.drivers
SET available = REPLACE(available, CHAR(13), '');

-- Flag Unregistered Rides
ALTER TABLE ride_share_case_study.rides
ADD registered_flag VARCHAR(20);
UPDATE ride_share_case_study.rides r
JOIN 
	ride_share_case_study.users u
	ON 
		r.user_id = u.user_id
SET r.registered_flag = 
	CASE 
		WHEN r.ride_start_time < u.registration_date THEN 'Unregistered' 
        ELSE 'Registered' 
	END;
    
-- Remove Comments from Ratings
ALTER TABLE ride_share_case_study.ratings
DROP COLUMN comments;

-- Flag Inactive
-- -- Inactive Users
ALTER TABLE ride_share_case_study.users
ADD COLUMN inactive_flag VARCHAR(10);
UPDATE ride_share_case_study.users u
LEFT JOIN ride_share_case_study.rides r
	ON u.user_id = r.user_id
SET
	u.inactive_flag = 
		CASE
			WHEN
				r.user_id IS NULL THEN 'Inactive'
				ELSE 'Active'
		END;
        
-- -- Inactive Vehicles
ALTER TABLE ride_share_case_study.vehicles
ADD COLUMN inactive_flag VARCHAR(10);
UPDATE ride_share_case_study.vehicles v
LEFT JOIN ride_share_case_study.drivers d
	ON v.vehicle_id = d.vehicle_id
SET
	v.inactive_flag = 
		CASE
			WHEN
				d.vehicle_id IS NULL THEN 'Inactive'
				ELSE 'Active'
		END;