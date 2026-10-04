-- Q4: On average, how many positions do drivers gain or lose from grid to finish?
SELECT
    d.forename,
    d.surname,
    ROUND(AVG(r.grid - r.positionOrder), 2) AS avg_positions_gained
FROM results r
JOIN drivers d ON r.driverId = d.driverId
JOIN races ra ON r.raceId = ra.raceId
WHERE r.laps > 0
  AND ra.year BETWEEN 2011 AND 2024
GROUP BY d.driverId, d.forename, d.surname
HAVING COUNT(*) >= 20
ORDER BY avg_positions_gained DESC
LIMIT 10;


-- Q5: Which drivers gain the most positions when starting from the front half of the grid?
SELECT
    d.forename,
    d.surname,
    CASE
        WHEN r.grid <= 10 THEN 'Front half (P1-P10)'
        ELSE 'Back half (P11+)'
    END AS start_group,
    COUNT(*) AS num_races,
    ROUND(AVG(r.grid - r.positionOrder), 2) AS avg_positions_gained
FROM results r
JOIN drivers d ON r.driverId = d.driverId
JOIN races ra ON r.raceId = ra.raceId
WHERE r.laps > 0
  AND ra.year BETWEEN 2011 AND 2024
GROUP BY d.driverId, d.forename, d.surname, start_group
HAVING COUNT(*) >= 15
ORDER BY start_group, avg_positions_gained DESC;


-- Q6: Does starting from the front row (P1-P2) mean more wins, or just more points?
SELECT
    CASE
        WHEN r.grid IN (1, 2) THEN 'Front row (P1-P2)'
        ELSE 'Rest of grid'
    END AS grid_group,
    COUNT(*) AS total_starts,
    ROUND(100.0 * SUM(CASE WHEN r.position = 1 THEN 1 ELSE 0 END) / COUNT(*), 2) AS win_pct,
    ROUND(100.0 * SUM(CASE WHEN r.points > 0 THEN 1 ELSE 0 END) / COUNT(*), 2) AS points_pct
FROM results r
JOIN races ra ON r.raceId = ra.raceId
WHERE r.laps > 0
  AND ra.year BETWEEN 2011 AND 2024
GROUP BY grid_group;


-- Q7: Which constructors have the best average finishing position per season?
SELECT
    ra.year,
    c.name AS constructor,
    COUNT(*) AS num_results,
    ROUND(AVG(r.positionOrder), 2) AS avg_finish_position
FROM results r
JOIN constructors c ON r.constructorId = c.constructorId
JOIN races ra ON r.raceId = ra.raceId
WHERE r.laps > 0
  AND ra.year BETWEEN 2011 AND 2024
GROUP BY ra.year, c.name
HAVING COUNT(*) >= 10
ORDER BY ra.year DESC, avg_finish_position ASC
LIMIT 20;


-- Q8: How does average number of pit stops per race compare across circuits?
SELECT
    c.name AS circuit,
    ROUND(AVG(stops_per_driver.num_stops), 2) AS avg_pit_stops
FROM (
    SELECT
        raceId,
        driverId,
        COUNT(*) AS num_stops
    FROM pit_stops
    GROUP BY raceId, driverId
) AS stops_per_driver
JOIN races ra ON stops_per_driver.raceId = ra.raceId
JOIN circuits c ON ra.circuitId = c.circuitId
WHERE ra.year BETWEEN 2011 AND 2024
GROUP BY c.name
HAVING COUNT(*) >= 20
ORDER BY avg_pit_stops DESC
LIMIT 15;


-- Q9: Is there a relationship between number of pit stops and final race position?
SELECT
    stops_per_driver.num_stops,
    COUNT(*) AS num_driver_races,
    ROUND(AVG(r.positionOrder), 2) AS avg_finish_position
FROM (
    SELECT
        raceId,
        driverId,
        COUNT(*) AS num_stops
    FROM pit_stops
    GROUP BY raceId, driverId
) AS stops_per_driver
JOIN results r
    ON stops_per_driver.raceId = r.raceId
    AND stops_per_driver.driverId = r.driverId
JOIN races ra ON r.raceId = ra.raceId
WHERE r.laps > 0
  AND ra.year BETWEEN 2011 AND 2024
GROUP BY stops_per_driver.num_stops
ORDER BY stops_per_driver.num_stops;


-- Q10: Which teams are fastest at pit stops on average, and how consistent are they?
SELECT
    c.name AS constructor,
    COUNT(*) AS num_stops,
    ROUND(AVG(ps.milliseconds) / 1000.0, 2) AS avg_stop_seconds,
    ROUND(STDDEV(ps.milliseconds) / 1000.0, 2) AS stddev_stop_seconds
FROM pit_stops ps
JOIN results r ON ps.raceId = r.raceId AND ps.driverId = r.driverId
JOIN constructors c ON r.constructorId = c.constructorId
JOIN races ra ON ps.raceId = ra.raceId
WHERE ra.year BETWEEN 2011 AND 2024
  AND ps.milliseconds IS NOT NULL
  AND ps.milliseconds < 60000
GROUP BY c.name
HAVING COUNT(*) >= 30
ORDER BY avg_stop_seconds ASC
LIMIT 15;