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



--1. ROW_NUMBER() on each driver's results, ordered by position, within each race_name
SELECT 
	pd.driver_name,
	pr.position,
	pr.race_name,
	ROW_NUMBER() OVER(PARTITION BY pr.race_name ORDER BY pr.position) AS rnk
FROM practice_results AS pr 
JOIN practice_drivers AS pd
ON pr.driver_id = pd.driver_id

--2. RANK() vs DENSE_RANK() on points, and where they differ
SELECT 
*,
RANK() OVER( ORDER BY points) AS rnk,
DENSE_RANK() OVER(ORDER BY points) AS dense_rnk
FROM practice_results

--3. LAG() to show each driver's previous race position
--Another thinking 1. Wrong One as per question
SELECT 
pd.driver_name,
pr.*,
LAG(position,1,0) OVER(PARTITION BY pr.position ORDER BY pr.race_name) AS record
FROM practice_results AS pr
LEFT JOIN practice_drivers AS pd
ON pr.driver_id = pd.driver_id

--Another thinking 2. Right One as or oer question
SELECT 
pd.driver_name, 
pr.*,
LAG(position) OVER(PARTITION BY pr.driver_id ORDER BY pr.result_id) AS record
FROM practice_results AS pr
LEFT JOIN practice_drivers AS pd
ON pr.driver_id = pd.driver_id

--4. Running total of points per driver with SUM() OVER (PARTITION BY ... ORDER BY ...)
--Right Option
SELECT *,
  SUM(points) OVER (PARTITION BY driver_id ORDER BY result_id) AS running_points
FROM practice_results;


--Wrong Approach
SELECT 
*,
SUM(points) OVER (
    ORDER BY points
    ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
)
FROM practice_results


--5.NTILE(4) to split all results into four groups by points
--Right Approach
SELECT *,
  SUM(points) OVER (ORDER BY points DESC) AS running_points
FROM practice_results;

--Wrong Approach
SELECT 
*,
NTILE(4) OVER(PARTITION BY points) AS tile
FROM practice_results
