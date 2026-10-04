-- Q11: For each driver in each race, lap 1 position vs final lap position
WITH first_last_lap AS (
    SELECT
        raceId,
        driverId,
        lap,
        position,
        FIRST_VALUE(position) OVER (
            PARTITION BY raceId, driverId ORDER BY lap
        ) AS lap1_position,
        LAST_VALUE(position) OVER (
            PARTITION BY raceId, driverId ORDER BY lap
            ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
        ) AS final_lap_position
    FROM lap_times
)
SELECT DISTINCT
    raceId,
    driverId,
    lap1_position,
    final_lap_position,
    (lap1_position - final_lap_position) AS positions_gained_during_race
FROM first_last_lap
ORDER BY raceId, positions_gained_during_race DESC
LIMIT 20;


-- Q12: Ideal pit-stop timing (as % of race distance) vs finishing result
WITH race_lengths AS (
    SELECT raceId, MAX(lap) AS total_laps
    FROM lap_times
    GROUP BY raceId
),
stop_timing AS (
    SELECT
        ps.raceId,
        ps.driverId,
        ps.lap,
        rl.total_laps,
        ROUND(100.0 * ps.lap / rl.total_laps, 1) AS pct_of_race,
        CASE
            WHEN 100.0 * ps.lap / rl.total_laps <= 33 THEN 'Early (0-33%)'
            WHEN 100.0 * ps.lap / rl.total_laps <= 66 THEN 'Mid (34-66%)'
            ELSE 'Late (67-100%)'
        END AS stop_window
    FROM pit_stops ps
    JOIN race_lengths rl ON ps.raceId = rl.raceId
    WHERE ps.stop = 1
)
SELECT
    st.stop_window,
    COUNT(*) AS num_stops,
    ROUND(AVG(r.positionOrder), 2) AS avg_finish_position
FROM stop_timing st
JOIN results r ON st.raceId = r.raceId AND st.driverId = r.driverId
JOIN races ra ON st.raceId = ra.raceId
WHERE r.laps > 0
  AND ra.year BETWEEN 2011 AND 2024
GROUP BY st.stop_window
ORDER BY avg_finish_position;


-- Q13: Rank each driver's best-ever season by average finish position
WITH season_avg AS (
    SELECT
        d.driverId,
        d.forename,
        d.surname,
        ra.year,
        COUNT(*) AS num_races,
        ROUND(AVG(r.positionOrder), 2) AS avg_finish_position
    FROM results r
    JOIN drivers d ON r.driverId = d.driverId
    JOIN races ra ON r.raceId = ra.raceId
    WHERE r.laps > 0
      AND ra.year BETWEEN 2011 AND 2024
    GROUP BY d.driverId, d.forename, d.surname, ra.year
    HAVING COUNT(*) >= 10
),
ranked_seasons AS (
    SELECT
        *,
        RANK() OVER (PARTITION BY driverId ORDER BY avg_finish_position ASC) AS season_rank
    FROM season_avg
)
SELECT forename, surname, year, num_races, avg_finish_position
FROM ranked_seasons
WHERE season_rank = 1
ORDER BY avg_finish_position ASC
LIMIT 15;


-- Q14: Which drivers most consistently outperform their qualifying position?
WITH quali_vs_race AS (
    SELECT
        d.driverId,
        d.forename,
        d.surname,
        q.raceId,
        q.position AS quali_position,
        r.positionOrder AS race_position,
        (q.position - r.positionOrder) AS positions_beat_quali
    FROM qualifying q
    JOIN results r ON q.raceId = r.raceId AND q.driverId = r.driverId
    JOIN drivers d ON q.driverId = d.driverId
    JOIN races ra ON q.raceId = ra.raceId
    WHERE r.laps > 0
      AND q.position IS NOT NULL
      AND ra.year BETWEEN 2011 AND 2024
)
SELECT
    forename,
    surname,
    COUNT(*) AS num_races,
    ROUND(AVG(positions_beat_quali), 2) AS avg_positions_beat_quali
FROM quali_vs_race
GROUP BY driverId, forename, surname
HAVING COUNT(*) >= 20
ORDER BY avg_positions_beat_quali DESC
LIMIT 10;


-- Q15: Each race's "strategy MVP" - biggest grid-to-finish improvement
WITH race_gains AS (
    SELECT
        ra.raceId,
        ra.year,
        ra.name AS race_name,
        d.forename,
        d.surname,
        r.grid,
        r.positionOrder AS finish,
        (r.grid - r.positionOrder) AS positions_gained,
        RANK() OVER (
            PARTITION BY ra.raceId ORDER BY (r.grid - r.positionOrder) DESC
        ) AS gain_rank
    FROM results r
    JOIN drivers d ON r.driverId = d.driverId
    JOIN races ra ON r.raceId = ra.raceId
    WHERE r.laps > 0
      AND ra.year BETWEEN 2011 AND 2024
)
SELECT
    year, race_name, forename, surname, grid, finish, positions_gained
FROM race_gains
WHERE gain_rank = 1
ORDER BY positions_gained DESC
LIMIT 15;