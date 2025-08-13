-- Create Database
CREATE DATABASE cleaned_ride_share;
USE cleaned_ride_share;

-- Transfer Tables
CREATE TABLE cleaned_ride_share.rides AS (
	SELECT * FROM ride_share_case_study.rides);

CREATE TABLE cleaned_ride_share.users AS (
	SELECT * FROM ride_share_case_study.rfm_users);

CREATE TABLE cleaned_ride_share.drivers AS (
	SELECT * FROM ride_share_case_study.rfm_drivers);

CREATE TABLE cleaned_ride_share.ratings AS (
	SELECT * FROM ride_share_case_study.ratings);

CREATE TABLE cleaned_ride_share.vehicles AS (
	SELECT * FROM ride_share_case_study.vehicles);

-- Add Primary Keys
ALTER TABLE cleaned_ride_share.rides ADD PRIMARY KEY (ride_id);
ALTER TABLE cleaned_ride_share.users ADD PRIMARY KEY (user_id);
ALTER TABLE cleaned_ride_share.drivers ADD PRIMARY KEY (driver_id);
ALTER TABLE cleaned_ride_share.ratings ADD PRIMARY KEY (rating_id);
ALTER TABLE cleaned_ride_share.vehicles ADD PRIMARY KEY (vehicle_id);

-- Add Foreign Keys
ALTER TABLE cleaned_ride_share.rides
ADD CONSTRAINT fk_rides_users FOREIGN KEY (user_id) REFERENCES cleaned_ride_share.users(user_id),
ADD CONSTRAINT fk_rides_drivers FOREIGN KEY (driver_id) REFERENCES cleaned_ride_share.drivers(driver_id);

ALTER TABLE cleaned_ride_share.drivers
ADD CONSTRAINT fk_drivers_vehicles FOREIGN KEY (vehicle_id) REFERENCES cleaned_ride_share.vehicles(vehicle_id);

ALTER TABLE cleaned_ride_share.ratings
ADD CONSTRAINT fk_ratings_users FOREIGN KEY (user_id) REFERENCES cleaned_ride_share.users(user_id),
ADD CONSTRAINT fk_ratings_drivers FOREIGN KEY (driver_id) REFERENCES cleaned_ride_share.drivers(driver_id);