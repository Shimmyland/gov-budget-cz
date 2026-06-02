-- Add pre-computed deficit columns to fiscal_year_totals so the repository
-- doesn't need to derive them at query time.
--
-- Two deficits are materialized (approved, actual) — those are what the app
-- displays as "plán vs realita". The _amended and _final value columns stay
-- in the MV for future analytical drill-down, but their derived deficits
-- aren't materialized until a use case asks for them.
--
-- Deficit sign convention: positive = schodek (expenditure > revenue),
-- negative = přebytek. Matches MF reporting.

DROP MATERIALIZED VIEW IF EXISTS fiscal_year_totals;

CREATE MATERIALIZED VIEW fiscal_year_totals AS
SELECT
  bf.fiscal_year,

  -- Revenue, all four budget states (revenue_final is always NULL because
  -- ZU_KROZP applies only to the expenditure side in MIS-RIS).
  SUM(bf.value_approved) FILTER (
    WHERE ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS revenue_approved,
  SUM(bf.value_amended) FILTER (
    WHERE ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS revenue_amended,
  SUM(bf.value_final) FILTER (
    WHERE ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS revenue_final,
  SUM(bf.value_actual) FILTER (
    WHERE ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS revenue_actual,

  -- Expenditure, all four budget states
  SUM(bf.value_approved) FILTER (
    WHERE ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS expenditure_approved,
  SUM(bf.value_amended) FILTER (
    WHERE ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS expenditure_amended,
  SUM(bf.value_final) FILTER (
    WHERE ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS expenditure_final,
  SUM(bf.value_actual) FILTER (
    WHERE ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS expenditure_actual,

  -- Pre-computed deficits — expenditure − revenue, SR scope. Positive = schodek.
  (COALESCE(SUM(bf.value_approved) FILTER (
    WHERE ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ), 0) - COALESCE(SUM(bf.value_approved) FILTER (
    WHERE ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ), 0)) AS deficit_approved,

  (COALESCE(SUM(bf.value_actual) FILTER (
    WHERE ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ), 0) - COALESCE(SUM(bf.value_actual) FILTER (
    WHERE ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ), 0)) AS deficit_actual

FROM budget_facts bf
JOIN economic_items   ei ON ei.id = bf.item_id
JOIN economic_groups  eg ON eg.id = ei.group_id
JOIN economic_classes ec ON ec.id = eg.class_id
GROUP BY bf.fiscal_year
WITH DATA;
