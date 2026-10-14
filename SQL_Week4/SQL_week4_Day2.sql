-- ---- Table 1: drivers ----
CREATE TABLE practice_drivers (
    driver_id INT PRIMARY KEY,
    driver_name VARCHAR(50),
    nationality VARCHAR(30)
);
 
INSERT INTO practice_drivers (driver_id, driver_name, nationality) VALUES
(1, 'Max Verstappen', 'Dutch'),
(2, 'Lewis Hamilton', 'British'),
(3, 'Charles Leclerc', 'Monegasque'),
(4, 'Lando Norris', 'British'),
(5, 'Carlos Sainz', 'Spanish'),
(6, 'George Russell', 'British'),
(7, 'Sergio Perez', 'Mexican'),
(8, 'Fernando Alonso', 'Spanish'),
(9, 'Oscar Piastri', 'Australian'),
(10, 'Yuki Tsunoda', 'Japanese');
-- Note: driver_id 99 deliberately has NO entry here, used below to test LEFT JOIN gaps



-- ---- Table 2: constructors ----
CREATE TABLE practice_constructors (
    constructor_id INT PRIMARY KEY,
    constructor_name VARCHAR(50)
);
 
INSERT INTO practice_constructors (constructor_id, constructor_name) VALUES
(1, 'Red Bull'),
(2, 'Mercedes'),
(3, 'Ferrari'),
(4, 'McLaren'),
(5, 'Aston Martin');
-- Note: constructor_id 6 deliberately has no drivers assigned to it in results



-- ---- Table 3: results (the main fact table) ----
CREATE TABLE practice_results (
    result_id INT PRIMARY KEY,
    race_name VARCHAR(50),
    driver_id INT,          -- intentionally NOT a foreign key constraint, so bad data is allowed through
    constructor_id INT,
    position INT,
    points INT
);
 
INSERT INTO practice_results (result_id, race_name, driver_id, constructor_id, position, points) VALUES
(1, 'Bahrain GP', 1, 1, 1, 25),
(2, 'Bahrain GP', 2, 2, 2, 18),
(3, 'Bahrain GP', 3, 3, 3, 15),
(4, 'Bahrain GP', 4, 4, 4, 12),
(5, 'Bahrain GP', 99, 1, 5, 10),   -- driver_id 99 does NOT exist in practice_drivers (data quality gap)
(6, 'Saudi GP', 1, 1, 2, 18),
(7, 'Saudi GP', 7, 1, 1, 25),
(8, 'Saudi GP', 2, 2, 3, 15),
(9, 'Saudi GP', 5, 3, 4, 12),
(10, 'Saudi GP', 8, 5, 5, 10),
(11, 'Australian GP', 1, 1, 1, 25),
(12, 'Australian GP', 3, 3, 2, 18),
(13, 'Australian GP', 4, 4, 3, 15),
(14, 'Australian GP', 9, 4, 4, 12),
(15, 'Australian GP', 6, 2, 5, 10),
(16, 'Japanese GP', 1, 1, 1, 25),
(17, 'Japanese GP', 2, 2, 2, 18),
(18, 'Japanese GP', 10, 4, 3, 15),
(19, 'Japanese GP', 3, 3, 4, 12),
(20, 'Japanese GP', 5, 3, 5, 10);
-- Driver 10 (Yuki Tsunoda) only appears once — useful for "drivers with few results" questions



-- ---- Table 4: lap_times (related to results via result_id) ----
CREATE TABLE practice_lap_times (
    lap_id INT PRIMARY KEY,
    result_id INT,
    lap_number INT,
    lap_time_seconds NUMERIC(5,2)
);
 
INSERT INTO practice_lap_times (lap_id, result_id, lap_number, lap_time_seconds) VALUES
(1, 1, 1, 92.5),
(2, 1, 2, 91.8),
(3, 2, 1, 93.1),
(4, 2, 2, 92.9),
(5, 3, 1, 93.5),
(6, 6, 1, 94.0),
(7, 7, 1, 92.2),
(8, 11, 1, 91.5),
(9, 11, 2, 90.9),
(10, 16, 1, 92.0);
-- Note: most result_ids (e.g. 4, 5, 8, 9, 10...) have NO lap time entries at all —
-- deliberate gap, good for practicing LEFT JOIN to find results missing lap data
 

SELECT * FROM practice_drivers
SELECT * FROM practice_constructors
SELECT * FROM practice_results
SELECT * FROM practice_lap_times



--1. Join practice_results to practice_drivers to pull in driver_name and nationality alongside each result — use INNER JOIN on driver_id.
SELECT * FROM practice_results AS pr
INNER JOIN practice_drivers AS pd
ON pr.driver_id = pd.driver_id


--2. Using a LEFT JOIN from practice_results to practice_drivers, find any result rows that have no matching driver — should return exactly the rows where driver_id = 99.
SELECT pr.* FROM practice_results AS pr
LEFT JOIN practice_drivers AS pd
ON pr.driver_id = pd.driver_id 
WHERE pd.driver_id = 99

--3. Join practice_results to practice_lap_times on result_id — pull each result's lap times alongside its race_name and position. Notice most results will show NULL for lap time columns — that's expected given the data.
SELECT pr.race_name, pr.position, pr.points, pt.lap_number, pt.lap_time_seconds FROM practice_results AS pr
LEFT JOIN practice_lap_times AS pt
ON pr.result_id = pt.result_id

--4. Find all results in practice_results that have zero matching entries in practice_lap_times — use a LEFT JOIN and filter where the lap time side is NULL. (This should return a lot of rows, given the deliberate gap in the data.)
SELECT * FROM practice_results AS pr
LEFT JOIN practice_lap_times AS pt
ON pr.result_id = pt.result_id
WHERE lap_time_seconds IS NULL

--5. Join practice_results to itself (self-join) to compare a driver's position in one race to their position in a different race — e.g., compare each driver's Bahrain GP result to their Saudi GP result, side by side in one row.
SELECT 
	r1.driver_id,
	r1.position AS bahrain_pos,
	r2.position AS saudi_gp
FROM practice_results AS r1
INNER JOIN practice_results AS r2
ON r1.driver_id = r2.driver_id
WHERE r1.race_name = 'Bahrain GP'
AND r2.race_name = 'Saudi GP'


--6. Count how many lap time entries exist per race, by joining practice_results and practice_lap_times and grouping by race_name.
SELECT * FROM practice_results
SELECT * FROM practice_lap_times

SELECT 
	pr.race_name,
	COUNT(pt.lap_id)
FROM practice_results AS pr
LEFT JOIN practice_lap_times AS pt
ON pr.result_id = pt.result_id
GROUP BY pr.race_name



--7. Using an INNER JOIN between practice_results and practice_drivers, find the average points scored by drivers of a specific nationality (e.g., British drivers).
SELECT * FROM practice_results
SELECT * FROM practice_drivers

SELECT
	ROUND(AVG(pr.points),2) AS avg_points,
	pd.nationality 
FROM practice_results AS pr
INNER JOIN practice_drivers AS pd
ON pr.driver_id = pd.driver_id
-- WHERE pd.nationality = 'British' -- TO filter out by nationality only 
GROUP BY pd.nationality
ORDER BY ROUND(AVG(pr.points),2) DESC


--8. Join practice_results and practice_constructors on constructor_id — find which constructor(s) have the most total points across all races.
SELECT * FROM practice_results
SELECT * FROM practice_constructors

SELECT
	SUM(pr.points) AS total_points_of_constuctor,
	pc.constructor_name
FROM practice_results AS pr
LEFT JOIN practice_constructors AS pc
ON pr.constructor_id = pc.constructor_id
GROUP BY pc.constructor_name
ORDER BY SUM(pr.points) DESC

--9. Use a FULL JOIN between practice_drivers and practice_results on driver_id, and count how many rows came back with NULL on either side — this should surface both driver 99 (missing from drivers) and reveal whether every real driver actually has at least one result.
SELECT * FROM practice_drivers 
SElECT * FROM practice_results

SELECT
	COUNT(CASE WHEN pd.driver_id IS NULL THEN 1 END) AS missing_value_of_driver_table,
	COUNT(CASE WHEN pr.driver_id IS NULL THEN 1 END) AS drivers_with_no_result
FROM practice_drivers AS pd
FULL JOIN practice_results AS pr
ON pd.driver_id = pr.driver_id



--10. Pick practice_results and practice_lap_times, or practice_results and practice_constructors — before writing the query, state in one sentence which join type you'd use and why, then write it.
--TO check the tables
select * from practice_results
select * from practice_lap_times
select * from practice_constructors

-- 1
SELECT 
	pr.race_name AS race,
	COUNT(pt.lap_id) total_laps,
	SUM(pr.points) AS total_points
FROM practice_results AS pr
LEFT JOIN practice_lap_times AS pt 
ON pr.result_id = pt.result_id
GROUP BY pr.race_name
ORDER BY SUM(pr.points) DESC

--2
SELECT 
	pr.race_name AS race,
	pr.driver_id AS driver_id,
	COUNT(pt.lap_id) AS total_lap,
	pc.constructor_name AS team
FROM practice_results AS pr
RIGHT JOIN practice_lap_times AS pt 
ON pr.result_id = pt.result_id
LEFT JOIN practice_constructors AS pc
ON pr.constructor_id = pc.constructor_id
GROUP BY pr.race_name,pr.driver_id,pc.constructor_name


--3
SELECT 
    pc.constructor_name,
    COALESCE(SUM(pr.points), 0) AS total_points
FROM practice_constructors pc
LEFT JOIN practice_results pr 
    ON pc.constructor_id = pr.constructor_id
GROUP BY pc.constructor_name
ORDER BY total_points DESC;