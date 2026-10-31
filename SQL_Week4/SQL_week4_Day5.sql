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


--1. Create a view v_driver_totals with driver_id and total_points. Query it ordered by total, highest first.
-- CREATE VIEW v_driver_totals AS(
-- 	SELECT 
-- 		pd.driver_name,
-- 		SUM(pr.points) AS total_points
-- 	FROM practice_drivers AS pd
-- 	LEFT JOIN practice_results AS pr
-- 	ON pd.driver_id = pr.driver_id
-- 	GROUP BY pd.driver_name
-- 	ORDER BY SUM(pr.points) DESC
-- )


CREATE VIEW v_driver_totals AS
SELECT driver_id, SUM(points) AS total_points
FROM practice_results
GROUP BY driver_id;

--Check the VIEW
SELECT * FROM v_driver_totals


--2. Create a view v_results_named with race_name, driver_name, position and points. Pick the join so driver 99 isn’t lost.
CREATE VIEW v_results_named AS(
	SELECT 
	pr.race_name,
	pd.driver_name,
	pr.position,
	pr.points
	FROM practice_results AS pr
	LEFT JOIN practice_drivers AS pd
	ON pr.driver_id = pd.driver_id
)

--Check the VIEW
SELECT * FROM v_results_named


--3. Use v_driver_totals in a join to practice_drivers to show names next to totals. You’re querying a view like a table.
SELECT 
vt.driver_id,
pd.driver_name,
vt.total_points
FROM v_driver_totals AS vt
LEFT JOIN practice_drivers AS pd
ON vt.driver_id = pd.driver_id


--4. Create a snapshot table driver_totals_snapshot with CTAS from v_driver_totals.
CREATE TABLE driver_totals_snapshot AS 
SELECT * FROM v_driver_totals


--5. Run INSERT INTO practice_results VALUES (21, 'Japanese GP', 4, 4, 6, 8);, then compare driver 4 in the view and in the snapshot. When you’re done, run DELETE FROM practice_results WHERE result_id = 21;.
SELECT * FROM practice_results
INSERT INTO practice_results VALUES (21, 'Japanese GP', 4, 4, 6, 8)
DELETE FROM practice_results WHERE result_id = 21

--6. Create a temp table tmp_constructor_totals. Use it in two separate queries: the top constructor, and each constructor’s percentage of the total.
CREATE TEMP TABLE tmp_constructor_totals AS
SELECT 
	constructor_id, 
	SUM(points) AS total_points
FROM practice_results
GROUP BY constructor_id

-- top constructor
SELECT 
	c.constructor_name,
	t.total_points
FROM tmp_constructor_totals AS t
JOIN practice_constructors AS c 
ON c.constructor_id = t.constructor_id
ORDER BY t.total_points DESC


-- percentage of total
SELECT 
	c.constructor_name,
	ROUND(100.0 * t.total_points / SUM(t.total_points) OVER (), 1) AS pct
FROM tmp_constructor_totals AS t 
JOIN practice_constructors AS c 
ON t.constructor_id = c.constructor_id
ORDER BY pct DESC


--7. Create a view v_race_totals (points per race). Write a query on it that returns races whose total isn’t 80. Re-insert the test row from #5 to see the check catch it, then delete it again.
--By inserting this values Japanese GP get value of 88.
INSERT INTO practice_results VALUES (21, 'Japanese GP', 4, 4, 6, 8)

--The Solution
CREATE VIEW v_race_totals AS
SELECT 
	race_name,
	SUM(points) AS total_points
FROM practice_results
GROUP BY race_name

SELECT * FROM v_race_totals 
WHERE total_points <> 80

--After checking delete the value
DELETE FROM practice_results WHERE result_id = 21


--8. Create a materialized view mv_driver_totals. Insert the test row, query it, run REFRESH MATERIALIZED VIEW, and query again. Then delete the row and refresh once more.
CREATE MATERIALIZED VIEW mv_driver_totals AS 
SELECT 
	driver_id, SUM(points) AS total_points
FROM practice_results
GROUP BY driver_id 

SELECT * FROM mv_driver_totals WHERE driver_id = 4 --The driver 4 value is 27

--By inserting this values Japanese GP get value of 88.
INSERT INTO practice_results VALUES (21, 'Japanese GP', 4, 4, 6, 8)

SELECT * FROM mv_driver_totals WHERE driver_id = 4 --The driver 4 value is 27

--MATERIALIZED VIEW refresh by this 
REFRESH MATERIALIZED VIEW mv_driver_totals;
SELECT * FROM mv_driver_totals WHERE driver_id = 4 --The driver 4 value is 35

--After checking delete the value
DELETE FROM practice_results WHERE result_id = 21

--MATERIALIZED VIEW refresh by this 
REFRESH MATERIALIZED VIEW mv_driver_totals;
SELECT * FROM mv_driver_totals WHERE driver_id = 4 --The driver 4 value is 27

--9.Conceptual, one line each: which would you use for (a) a query analysts run daily that must always be current, (b) one step inside a single query, (c) an intermediate result reused across several statements in one session, (d) an expensive summary that dashboards read every morning?
--(a) a query analysts run daily that must always be current - a VIEW
--(b) one step inside a single query - a CTE
--(c) an intermediate result reused across several statements in one session - a temp table
--(d) an expensive summary that dashboards read every morning? - a MATERIALIZED VIEW (or a CTAS table rebuilt on a schedule).


--10.Clean up. Drop everything you created, with no CASCADE.
DROP VIEW v_driver_totals
DROP VIEW v_race_totals
DROP VIEW v_results_named 
DROP MATERIALIZED VIEW mv_driver_totals
DROP TABLE driver_totals_snapshot
DROP TABLE tmp_constructor_totals