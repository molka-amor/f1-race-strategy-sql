-- CHECK 1: Row counts per table
-- Confirms every CSV imported completely
-- Expected: circuits 77 | drivers 861 | constructors 212 | status 139
--           races 1125 | results 26759 | qualifying 10495
--           pit_stops 11372 | lap_times 589082
SELECT 'circuits' AS table_name, COUNT(*) FROM circuits
UNION ALL
SELECT 'drivers', COUNT(*) FROM drivers
UNION ALL
SELECT 'constructors', COUNT(*) FROM constructors
UNION ALL
SELECT 'status', COUNT(*) FROM status
UNION ALL
SELECT 'races', COUNT(*) FROM races
UNION ALL
SELECT 'results', COUNT(*) FROM results
UNION ALL
SELECT 'qualifying', COUNT(*) FROM qualifying
UNION ALL
SELECT 'pit_stops', COUNT(*) FROM pit_stops
UNION ALL
SELECT 'lap_times', COUNT(*) FROM lap_times;


-- CHECK 2: Understand the shape of "did not finish" data
-- Confirms DNF data is genuine (real mechanical/incident reasons),
-- not a bucket of unexplained nulls
SELECT
    s.status,
    COUNT(*) AS num_results
FROM results r
JOIN status s ON r.statusId = s.statusId
WHERE r.position IS NULL
GROUP BY s.status
ORDER BY num_results DESC;

-- FINDING: "Did not qualify" (1025), "Did not prequalify" (331), and
-- "Withdrew" (245) rows mean the driver never started the race.
-- DECISION: every strategy-related query uses WHERE laps > 0 to
-- exclude these, since that's a more robust filter than naming
-- every non-start status individually.


-- CHECK 3: Known valid edge cases in results (documented, not bugs)
-- grid = 0 means a pit lane start, not missing data
SELECT COUNT(*) AS pit_lane_starts
FROM results
WHERE grid = 0;
-- Result: 1,638 rows

-- positionOrder is NEVER NULL (unlike position), used for all
-- ranking/math in this project
SELECT COUNT(*) AS null_position_order
FROM results
WHERE positionOrder IS NULL;
-- Expected: 0


-- CHECK 4: Confirm pit_stops / lap_times date coverage limitation
-- Explains why this project is scoped to 2011-2024
SELECT MIN(ra.year) AS earliest_year, MAX(ra.year) AS latest_year
FROM pit_stops ps
JOIN races ra ON ps.raceId = ra.raceId;
-- Result: pit_stops data starts in 2011

SELECT MIN(ra.year) AS earliest_year, MAX(ra.year) AS latest_year
FROM lap_times lt
JOIN races ra ON lt.raceId = ra.raceId;
-- Result: lap_times data starts in 1996