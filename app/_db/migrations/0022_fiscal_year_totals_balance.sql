-- Rename deficit_* columns to balance_* and flip the sign convention.
--
-- Old: deficit = expenditure − revenue   (positive = schodek, negative = přebytek)
-- New: balance = revenue − expenditure   (positive = přebytek, negative = schodek)
--
-- The new convention matches how MF reports saldo in tiskovky (e.g. SZÚ 2018 =
-- +2,9 mld přebytek, SZÚ 2019 = −28,5 mld schodek). Less confusing in UI.

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

  -- Pre-computed balances — revenue − expenditure, SR scope.
  -- Positive = přebytek, negative = schodek (matches MF saldo convention).
  (COALESCE(SUM(bf.value_approved) FILTER (
    WHERE ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ), 0) - COALESCE(SUM(bf.value_approved) FILTER (
    WHERE ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ), 0)) AS balance_approved,

  (COALESCE(SUM(bf.value_actual) FILTER (
    WHERE ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ), 0) - COALESCE(SUM(bf.value_actual) FILTER (
    WHERE ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ), 0)) AS balance_actual

FROM budget_facts bf
JOIN economic_items   ei ON ei.id = bf.item_id
JOIN economic_groups  eg ON eg.id = ei.group_id
JOIN economic_classes ec ON ec.id = eg.class_id
GROUP BY bf.fiscal_year
WITH DATA;
