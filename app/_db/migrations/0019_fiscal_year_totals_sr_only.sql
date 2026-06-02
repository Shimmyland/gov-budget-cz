-- Simplify fiscal_year_totals: keep only SR-scope columns (the raw / all-sources
-- variants weren't used anywhere). 12 columns → 6 columns, names without _sr
-- suffix since there's only one version now.
--
-- Filter rule baked into every aggregate: funding_source_code IN ('1','4','5')
-- OR IS NULL (NULL handles 2020–2023 files which don't carry ZC_ZDROJA).

DROP MATERIALIZED VIEW IF EXISTS fiscal_year_totals;

CREATE MATERIALIZED VIEW fiscal_year_totals AS
SELECT
  bf.fiscal_year,
  SUM(bf.value) FILTER (
    WHERE bf.is_approved AND ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS total_revenue_approved,
  SUM(bf.value) FILTER (
    WHERE NOT bf.is_approved AND ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS total_revenue_actual,
  SUM(bf.value) FILTER (
    WHERE bf.is_approved AND ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS total_expenditure_approved,
  SUM(bf.value) FILTER (
    WHERE NOT bf.is_approved AND ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS total_expenditure_actual,
  (SUM(bf.value) FILTER (
    WHERE bf.is_approved AND ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) - SUM(bf.value) FILTER (
    WHERE bf.is_approved AND ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  )) AS deficit_approved,
  (SUM(bf.value) FILTER (
    WHERE NOT bf.is_approved AND ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) - SUM(bf.value) FILTER (
    WHERE NOT bf.is_approved AND ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  )) AS deficit_actual
FROM budget_facts bf
JOIN economic_items   ei ON ei.id = bf.item_id
JOIN economic_groups  eg ON eg.id = ei.group_id
JOIN economic_classes ec ON ec.id = eg.class_id
GROUP BY bf.fiscal_year
WITH DATA;
