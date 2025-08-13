-- Database Setup
CREATE DATABASE ride_share_case_study;
USE ride_share_case_study;

-- Create Tables and Import data
-- -- Rides
CREATE TABLE rides (
	ride_id INT,
    user_id INT,
    start_location VARCHAR(40),
    end_location VARCHAR(40),
    ride_start_time DATETIME,
    ride_end_time DATETIME,
    distance_km DECIMAL(10,2),
    fare_amount DECIMAL(10,2),
    driver_id INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/rides.csv'
INTO TABLE rides
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
  ride_id, user_id, start_location, end_location,
  @ride_start_time, @ride_end_time, distance_km, fare_amount, driver_id
)
SET
  ride_start_time = STR_TO_DATE(@ride_start_time, '%m/%d/%Y %H:%i'),
  ride_end_time   = STR_TO_DATE(@ride_end_time, '%m/%d/%Y %H:%i');

-- Users
CREATE TABLE users (
    user_id INT,
    registration_date DATETIME,
    age INT,
    gender VARCHAR(10),
    location VARCHAR(40)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/users.csv'
INTO TABLE users
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS(
  user_id, @registration_date, age, gender,
  location
)
SET
  registration_date = STR_TO_DATE(@registration_date, '%m/%d/%Y %H:%i');

-- Vehicles
CREATE TABLE vehicles (
    vehicle_id INT,
    make VARCHAR(50),
    model VARCHAR(20),
    year YEAR,
    capacity INT
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/vehicles.csv'
INTO TABLE vehicles
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS(
  vehicle_id, make, model, year,
  capacity
);

-- Drivers
CREATE TABLE drivers (
    driver_id INT,
    vehicle_id INT,
    rating DECIMAL(5,2),
    total_rides INT,
    available VARCHAR(10)
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/drivers.csv'
INTO TABLE drivers
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS(
  driver_id, vehicle_id, rating, total_rides,
  available
);

-- Ratings
CREATE TABLE ratings (
    rating_id INT,
    ride_id INT,
    user_id INT,
    rating_value INT,
    comments TEXT,
    rating_date DATETIME
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/ratings.csv'
INTO TABLE ratings
FIELDS TERMINATED BY ',' ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS(
  rating_id, ride_id, user_id, rating_value,
  comments, @rating_date
)
SET
  rating_date = STR_TO_DATE(@rating_date, '%m/%d/%Y %H:%i');