-- Q1: Which circuits have hosted the most F1 races?
SELECT
    c.name AS circuit_name,
    c.country,
    COUNT(*) AS races_hosted
FROM races r
JOIN circuits c ON r.circuitId = c.circuitId
GROUP BY c.name, c.country
ORDER BY races_hosted DESC
LIMIT 10;


-- Q2: Which drivers have the most race wins (2011-2024)?
SELECT
    d.forename,
    d.surname,
    COUNT(*) AS wins
FROM results r
JOIN drivers d ON r.driverId = d.driverId
JOIN races ra ON r.raceId = ra.raceId
WHERE r.position = 1
  AND ra.year BETWEEN 2011 AND 2024
GROUP BY d.driverId, d.forename, d.surname
ORDER BY wins DESC
LIMIT 10;


-- Q3: What are the most common reasons drivers fail to finish a race?
SELECT
    s.status,
    COUNT(*) AS num_dnfs
FROM results r
JOIN status s ON r.statusId = s.statusId
JOIN races ra ON r.raceId = ra.raceId
WHERE r.position IS NULL
  AND r.laps > 0
  AND ra.year BETWEEN 2011 AND 2024
GROUP BY s.status
ORDER BY num_dnfs DESC
LIMIT 15;