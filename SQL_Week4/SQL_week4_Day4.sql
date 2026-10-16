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



--1. [practice_results] Total points per driver_id in a CTE. In the outer query, show the top 5 by total.
WITH ctes AS(
SELECT 
	driver_id,
	SUM(points) AS total_points
FROM practice_results
GROUP BY driver_id
)
SELECT 
driver_id,
total_points
FROM ctes
ORDER BY total_points DESC 
LIMIT 5


--2. [practice_results] Find drivers whose total is above the average of all driver totals, with the average computed from the CTE itself.
WITH total AS(
SELECT 
driver_id,
SUM(points) AS total_points
FROM practice_results
GROUP BY driver_id
)
SELECT 
	driver_id,
	total_points
FROM total 
WHERE total_points > (SELECT AVG(total_points) FROM total)


--3. [practice_results + practice_drivers] Totals per driver in a CTE, then join to get driver names. Pick the join type so driver 99 isn’t lost.
WITH total AS(
SELECT 
driver_id, 
SUM(points) AS total_points
FROM practice_results
GROUP BY driver_id
)
SELECT 
t.driver_id,
d.driver_name,
d.nationality,
t.total_points
FROM total AS t
LEFT JOIN practice_drivers AS d
ON t.driver_id = d.driver_id
ORDER BY t.total_points


--4. [practice_results] Each driver’s best single result (highest points) using ROW_NUMBER() in a CTE. Add a tie-breaker so the pick isn’t arbitrary.
WITH ctes AS(
SELECT 
*,
ROW_NUMBER() OVER(PARTITION BY driver_id ORDER BY points DESC, result_id) AS rnk
FROM practice_results
ORDER BY driver_id
)
SELECT 
result_id, race_name, driver_id, constructor_id, position, points
FROM ctes
WHERE rnk = 1


--5. [practice_results + practice_drivers] A CTE of race winners (position = 1), then show each winner’s name and number of wins.
WITH win AS(
SELECT driver_id FROM practice_results
WHERE position = 1
)
SELECT 
p.driver_name,
COUNT(*) AS wins
FROM win AS w
LEFT JOIN practice_drivers AS p
ON w.driver_id = p.driver_id
GROUP BY p.driver_name 


--6. [practice_results + practice_constructors] Chained CTEs: constructor totals, then a ranking, then the top 3 with names.
--Approach 1
WITH cte1 AS(
SELECT DISTINCT
pc.*,
SUM(pr.points) OVER(PARTITION BY pc.constructor_id) AS constructors_total
FROM practice_constructors AS pc 
LEFT JOIN practice_results AS pr
ON pc.constructor_id = pr.constructor_id
ORDER BY pc.constructor_id
), 
cte2 AS(
SELECT 
ct.*,
RANK() OVER(ORDER BY ct.constructors_total DESC) AS rnk_of_constructors
FROM cte1 AS ct
),
cte3 AS(
SELECT * FROM cte2
WHERE rnk_of_constructors < 4
)
SELECT * FROM cte3

--Approach 2
WITH totals AS (
SELECT constructor_id, SUM(points) AS total_points FROM practice_results GROUP BY constructor_id
), ranked AS(
SELECT *, RANK() OVER(ORDER BY total_points DESC) As rnk FROM totals
)
SELECT 
c.constructor_name,
r.total_points,
r.rnk
FROM ranked AS r
LEFT JOIN practice_constructors AS c ON r.constructor_id = c.constructor_id
WHERE rnk <= 3
ORDER BY rnk 


--7. [practice_results + practice_constructors] Each constructor’s points as a percentage of all points.
WITH cte1 AS(
SELECT
pc.constructor_id,
SUM(pr.points) AS constructors_total
FROM practice_constructors AS pc 
LEFT JOIN practice_results AS pr
ON pc.constructor_id = pr.constructor_id
GROUP BY pc.constructor_id
)
SELECT 
pc.constructor_name,
c.constructors_total,
ROUND(100.0 * c.constructors_total / SUM(c.constructors_total) OVER() , 1)  AS percentage
FROM cte1 AS c
LEFT JOIN practice_constructors AS pc
ON c.constructor_id = pc.constructor_id
ORDER by percentage DESC

	
--8. [practice_results + practice_drivers] A CTE joining results to drivers, average points per nationality, and only the nationalities above the overall average.
WITH a AS(
SELECT 
d.nationality,
r.points
FROM practice_results AS r
RIGHT JOIN practice_drivers AS d
ON r.driver_id = d.driver_id
),
by_nation AS(
SELECT 
nationality, 
AVG(points) AS avg_points
FROM a
GROUP BY nationality 
)
SELECT 
nationality,
ROUND(avg_points,2) AS avg_points
FROM by_nation 
WHERE avg_points > (SELECT AVG(points) FROM a)


--9. [practice_results + practice_lap_times] Join results to lap times and SUM(points) per race. Notice the inflated totals, then fix it by aggregating lap times in a CTE first. Every race should come out at 80.
WITH lap AS(
SELECT 
	result_id,
	COUNT(*) AS lap_count
FROM practice_lap_times
GROUP BY result_id
)
SELECT 
	r.race_name,
	SUM(r.points) AS total_points,
	SUM(COALESCE(l.lap_count,0)) AS total_laps
FROM practice_results AS r
LEFT JOIN lap AS l 
ON l.result_id = r.result_id
GROUP BY r.race_name


--10.Stretch: a recursive CTE that generates the numbers 1 to 10.
WITH RECURSIVE ctes AS(
SELECT 
1 AS mynumber
UNION ALL
SELECT 
mynumber + 1
FROM ctes
WHERE mynumber < 15
)
SELECT * FROM ctes