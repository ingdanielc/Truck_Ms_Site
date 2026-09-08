-- ============================================================
-- CashTruck - Annual Toll Rate Update
-- Purpose:
--   Load the official tariff file for a new year without modifying
--   historical rates.
--
-- Usage:
--   1. Update @new_year and @effective_date.
--   2. Replace the rows in tmp_toll_rates_2027 with the official
--      tariff data.
--   3. Execute the script in MySQL Workbench.
--
-- Required columns in the temporary data:
--   toll_key, category, rate
-- ============================================================

SET NAMES utf8mb4;

SET @new_year = 2027;
SET @effective_date = '2027-01-01';

START TRANSACTION;

-- ------------------------------------------------------------
-- 1. Temporary table for the official tariff file
-- ------------------------------------------------------------

DROP TEMPORARY TABLE IF EXISTS tmp_toll_rates;

CREATE TEMPORARY TABLE tmp_toll_rates (
    toll_key VARCHAR(150) NOT NULL,
    category VARCHAR(20) NOT NULL,
    rate INT UNSIGNED NOT NULL,
    source VARCHAR(255),
    source_entity VARCHAR(100),

    PRIMARY KEY (toll_key, category)
) ENGINE=InnoDB;


-- ------------------------------------------------------------
-- 2. LOAD NEW OFFICIAL RATES HERE
--
-- Example only:
--
-- INSERT INTO tmp_toll_rates
-- (toll_key, category, rate, source, source_entity)
-- VALUES
-- ('PEAJE_X', 'I', 18500, 'ANI', 'ANI'),
-- ('PEAJE_X', 'II', 22000, 'ANI', 'ANI');
--
-- Replace the examples with the official 2027 data.
-- ------------------------------------------------------------


-- ------------------------------------------------------------
-- 3. Validate that every toll exists
-- ------------------------------------------------------------

SELECT
    r.toll_key,
    r.category,
    r.rate
FROM tmp_toll_rates r
LEFT JOIN toll t
    ON t.toll_key = r.toll_key
WHERE t.id IS NULL;


-- ------------------------------------------------------------
-- 4. Validate missing categories / duplicated data
-- ------------------------------------------------------------

SELECT
    toll_key,
    category,
    COUNT(*) AS occurrences
FROM tmp_toll_rates
GROUP BY toll_key, category
HAVING COUNT(*) > 1;


-- ------------------------------------------------------------
-- 5. Close the currently active rate
--
-- Only rates that have a new 2027 value are closed.
-- Historical rates remain unchanged.
-- ------------------------------------------------------------

UPDATE toll_rate tr
INNER JOIN toll t
    ON t.id = tr.toll_id
INNER JOIN tmp_toll_rates r
    ON r.toll_key = t.toll_key
   AND r.category = tr.category
SET tr.end_date = DATE_SUB(@effective_date, INTERVAL 1 DAY)
WHERE tr.start_date < @effective_date
  AND (tr.end_date IS NULL OR tr.end_date >= @effective_date);


-- ------------------------------------------------------------
-- 6. Insert the new rates
-- ------------------------------------------------------------

INSERT INTO toll_rate (
    toll_id,
    category,
    rate,
    start_date,
    end_date,
    source,
    source_entity
)
SELECT
    t.id,
    r.category,
    r.rate,
    @effective_date,
    NULL,
    r.source,
    r.source_entity
FROM tmp_toll_rates r
INNER JOIN toll t
    ON t.toll_key = r.toll_key
ON DUPLICATE KEY UPDATE
    rate = VALUES(rate),
    end_date = VALUES(end_date),
    source = VALUES(source),
    source_entity = VALUES(source_entity);


-- ------------------------------------------------------------
-- 7. Verification
-- ------------------------------------------------------------

SELECT
    t.name,
    tr.category,
    tr.rate,
    tr.start_date,
    tr.end_date,
    tr.source
FROM toll_rate tr
INNER JOIN toll t
    ON t.id = tr.toll_id
WHERE tr.start_date = @effective_date
ORDER BY t.name, tr.category;


COMMIT;


-- ============================================================
-- 8. Check historical integrity
--
-- Example:
-- A 2026 trip must continue using the 2026 rate.
-- A 2027 trip must use the 2027 rate.
-- ============================================================

-- SELECT *
-- FROM toll_rate
-- WHERE toll_id = ?
--   AND category = ?
--   AND start_date <= '2027-05-15'
--   AND (end_date IS NULL OR end_date >= '2027-05-15');


-- ============================================================
-- IMPORTANT
-- ============================================================
-- Do NOT update the rate value directly in the existing 2026 row.
-- Always create a new row for the new effective date.
--
-- This preserves CashTruck's historical reports and allows:
--
--   2026 trip -> 2026 toll price
--   2027 trip -> 2027 toll price
--   2028 trip -> 2028 toll price
--
-- The same script can be reused every year by changing:
--
--   @new_year
--   @effective_date
--   tmp_toll_rates
-- ============================================================
