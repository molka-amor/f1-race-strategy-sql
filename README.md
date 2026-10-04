# What Makes a Successful Formula 1 Race Strategy?

A SQL project where I dig into what actually makes an F1 race strategy work — starting position vs where you finish, pit stop timing, driver and team performance, DNFs, and how qualifying pace compares to race day.

## Context

I'm a 3rd-year E-business / Informatique de Gestion student at ESSECT (Tunisia), interested in BI and data analytics, and a big F1 fan. I already did a Power BI project comparing Leclerc vs Hamilton in the 2025 season — this one's the SQL side, built to show I can take real relational data, structure it properly, and actually query it to answer real questions, not just run a tutorial dataset.

## Dataset

Using the "Formula 1 World Championship (1950–2024)" dataset from Kaggle (Rohan Rao), originally pulled from the Ergast API. It comes as 14 CSVs — I used 9 of them: circuits, drivers, constructors, status, races, results, qualifying, pit_stops, lap_times. The other 5 (driver_standings, constructor_standings, constructor_results, sprint_results, seasons) are more about season-long totals than race strategy, so I left them out on purpose.

## Scoping decision (2011–2024)

Pit stop data only goes back to 2011, and lap time data to 1996. Since this whole project is about pit stop strategy, I scoped everything to 2011–2024 so every query is working off the same consistent window instead of mixing eras with missing data.

## Limitations

- No tire compound data — so "strategy" here means stop count/timing, not tire choice.
- No weather or safety car data, which obviously affect real strategy calls a lot.
- A few old rows have a null `position` even though the driver technically finished — a small quirk in the older data, not something I'm treating as an error.

## Schema

9 tables. `results` is basically the spine of the whole project — one row per driver per race, with grid position, finish position, points, laps, and status (why they retired, if they did). Everything else (drivers, constructors, circuits, qualifying, pit stops, lap times) connects back to it. Full table definitions are in `schema/schema.sql`.

## Data cleaning

Before writing any analysis query, I checked row counts against the original CSVs to make sure nothing silently failed on import (the lap_times file alone is 589K rows). I also found that `grid = 0` means a pit lane start, not missing data, and that some drivers have a `results` row even though they never actually started the race (did not qualify, withdrew, etc). For any query about strategy outcomes, I filter with `WHERE laps > 0` to exclude those non-starters. Full checks in `data-cleaning/data_cleaning_checks.sql`.

## Analytical questions

15 questions, organized beginner → advanced, split across 3 files in `/sql`. Sample results for each one are saved as CSV.

**Beginner** (`01_beginner_queries.sql`)
1. Which circuits have hosted the most races? → [Q1.csv](sample-results/Q1.csv)
2. Which drivers have the most wins (2011–2024)? → [Q2.csv](sample-results/Q2.csv)
3. What are the most common reasons for not finishing? → [Q3.csv](sample-results/Q3.csv)

**Intermediate** (`02_intermediate_queries.sql`)
4. Average positions gained/lost, grid to finish? → [Q4.csv](sample-results/Q4.csv)
5. Who gains the most starting from the front half of the grid? → [Q5.csv](sample-results/Q5.csv)
6. Does starting front row mean more wins, or just more points? → [Q6.csv](sample-results/Q6.csv)
7. Best constructor average finish, per season? → [Q7.csv](sample-results/Q7.csv)
8. Average pit stops per race, by circuit? → [Q8.csv](sample-results/Q8.csv)
9. Relationship between pit stop count and finish position? → [Q9.csv](sample-results/Q9.csv)
10. Fastest, most consistent pit crews? → [Q10.csv](sample-results/Q10.csv)

**Advanced** (`03_advanced_queries.sql`)
11. Lap 1 position vs final lap position, per driver per race? → [Q11.csv](sample-results/Q11.csv)
12. Ideal pit stop timing window (as % of race distance)? → [Q12.csv](sample-results/Q12.csv)
13. Each driver's best-ever season, ranked? → [Q13.csv](sample-results/Q13.csv)
14. Who most outperforms their qualifying position? → [Q14.csv](sample-results/Q14.csv)
15. Each race's "strategy MVP" — biggest grid-to-finish gain? → [Q15.csv](sample-results/Q15.csv)

## Key insights

- Starting front row (P1–P2) wins 39.25% of races vs just 1.24% from everywhere else — a huge gap. But it only bumps your chance of scoring points by about 2x (90.4% vs 44.8%). So qualifying well matters way more if your goal is winning than if your goal is just points.
- First pit stops taken mid-race (34–66% of race distance) correlate with the best average finish — better than stopping very early or very late.
- More pit stops doesn't really correlate with a worse finish in any clean way — 3–4 stop races finish only slightly worse than 1–2 stop races, and that's probably because extra stops are a symptom of trouble (damage, issues) rather than a bad strategy choice in itself.
- Raw "positions gained" stats are biased toward drivers who start near the back, since there's just more room to gain. Splitting by starting half (front vs back) fixes this and shows Hamilton and Verstappen as the real standout "recovery" drivers.
- Verstappen's 2023 season (1.27 average finish position) comes out as the most dominant season in the whole dataset window — checks out, he won 19 of 22 races that year.

## SQL skills demonstrated

- SELECT, WHERE, ORDER BY, LIMIT
- JOINs (2-table, 3-table, and composite-key joins)
- GROUP BY, HAVING, aggregate functions (COUNT, AVG, SUM, STDDEV)
- CASE WHEN (including conditional aggregation with SUM(CASE WHEN...))
- Subqueries
- CTEs (including chained CTEs)
- Window functions: RANK(), FIRST_VALUE(), LAST_VALUE()
- PARTITION BY
- Composite primary keys / multi-column foreign keys
- Data cleaning and validation queries

## How to run it

1. Install PostgreSQL + pgAdmin.
2. Create a database.
3. Run `schema/schema.sql` to create the 9 tables.
4. Download the CSVs from the Kaggle link above and import each into its matching table (header row on, null string set to `\N`).
5. Run `data-cleaning/data_cleaning_checks.sql` to confirm the import worked.
6. Run the queries in `/sql`, in order.
