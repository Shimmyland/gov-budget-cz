-- Materialized view: per-year totals of revenue, expenditure and deficit.
-- Refresh after every seed/import via:
--   REFRESH MATERIALIZED VIEW fiscal_year_totals;
CREATE MATERIALIZED VIEW fiscal_year_totals AS
SELECT
  bf.fiscal_year,
  SUM(bf.value) FILTER (WHERE ec.code IN ('1','2','3','4')) AS total_revenue,
  SUM(bf.value) FILTER (WHERE ec.code IN ('5','6'))         AS total_expenditure,
  SUM(bf.value) FILTER (WHERE ec.code IN ('5','6')) -
  SUM(bf.value) FILTER (WHERE ec.code IN ('1','2','3','4')) AS deficit
FROM budget_facts bf
JOIN economic_items   ei ON ei.id = bf.item_id
JOIN economic_groups  eg ON eg.id = ei.group_id
JOIN economic_classes ec ON ec.id = eg.class_id
GROUP BY bf.fiscal_year
WITH DATA;