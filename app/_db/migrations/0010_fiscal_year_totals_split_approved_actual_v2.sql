-- Recreate fiscal_year_totals materialized view to split approved vs actual.
--
-- The original MV (migration 0001) summed both schválený rozpočet AND skutečnost
-- into one bucket → after loading real MIS-RIS data via ETL, totals were 2× too
-- high (e.g., 4,721 mld výdaje instead of 2,327 mld schválený / 2,394 mld skutečnost).
--
-- New version separates them into 6 columns so UI can show planned vs actual
-- side by side.
--
-- (Migration 0009 was a no-op placeholder — this migration 0010 contains the
-- actual fix.)

DROP MATERIALIZED VIEW IF EXISTS fiscal_year_totals;

CREATE MATERIALIZED VIEW fiscal_year_totals AS
SELECT
  bf.fiscal_year,
  SUM(bf.value) FILTER (WHERE bf.is_approved = TRUE  AND ec.code IN ('1','2','3','4')) AS total_revenue_approved,
  SUM(bf.value) FILTER (WHERE bf.is_approved = FALSE AND ec.code IN ('1','2','3','4')) AS total_revenue_actual,
  SUM(bf.value) FILTER (WHERE bf.is_approved = TRUE  AND ec.code IN ('5','6'))         AS total_expenditure_approved,
  SUM(bf.value) FILTER (WHERE bf.is_approved = FALSE AND ec.code IN ('5','6'))         AS total_expenditure_actual,
  SUM(bf.value) FILTER (WHERE bf.is_approved = TRUE  AND ec.code IN ('5','6')) -
  SUM(bf.value) FILTER (WHERE bf.is_approved = TRUE  AND ec.code IN ('1','2','3','4')) AS deficit_approved,
  SUM(bf.value) FILTER (WHERE bf.is_approved = FALSE AND ec.code IN ('5','6')) -
  SUM(bf.value) FILTER (WHERE bf.is_approved = FALSE AND ec.code IN ('1','2','3','4')) AS deficit_actual
FROM budget_facts bf
JOIN economic_items   ei ON ei.id = bf.item_id
JOIN economic_groups  eg ON eg.id = ei.group_id
JOIN economic_classes ec ON ec.id = eg.class_id
GROUP BY bf.fiscal_year
WITH DATA;
