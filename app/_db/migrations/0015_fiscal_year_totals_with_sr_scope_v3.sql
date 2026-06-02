-- Recreate fiscal_year_totals to expose both "raw all sources" and "SR scope only" totals.
-- (Migrations 0013 and 0014 were no-op placeholders due to tooling slip — this 0015 is real.)
--
-- Background (from data validation against MF SZÚ 2024):
-- MIS-RIS includes both státní rozpočet (kódy 1, 4, 5 v ZC_ZDROJA) AND
-- mimorozpočtové zdroje (kódy 2, 3). MF official figures report only SR scope.
-- Our earlier raw totals (2022–2024) were 11–227 mld over MF because of this.
--
-- Filter rule for SR scope: funding_source_code IN ('1','4','5')  OR  IS NULL.
-- NULL handles 2020–2023 files where the column did not exist — we cannot
-- distinguish there, so we treat them as SR (this matches what MF reported for
-- those years — our raw exactly matched 2020/2021 figures).

DROP MATERIALIZED VIEW IF EXISTS fiscal_year_totals;

CREATE MATERIALIZED VIEW fiscal_year_totals AS
SELECT
  bf.fiscal_year,

  -- Raw (all sources: SR + mimorozpočtové)
  SUM(bf.value) FILTER (WHERE bf.is_approved AND ec.code IN ('1','2','3','4'))        AS total_revenue_approved,
  SUM(bf.value) FILTER (WHERE NOT bf.is_approved AND ec.code IN ('1','2','3','4'))    AS total_revenue_actual,
  SUM(bf.value) FILTER (WHERE bf.is_approved AND ec.code IN ('5','6'))                AS total_expenditure_approved,
  SUM(bf.value) FILTER (WHERE NOT bf.is_approved AND ec.code IN ('5','6'))            AS total_expenditure_actual,
  SUM(bf.value) FILTER (WHERE bf.is_approved AND ec.code IN ('5','6')) -
  SUM(bf.value) FILTER (WHERE bf.is_approved AND ec.code IN ('1','2','3','4'))        AS deficit_approved,
  SUM(bf.value) FILTER (WHERE NOT bf.is_approved AND ec.code IN ('5','6')) -
  SUM(bf.value) FILTER (WHERE NOT bf.is_approved AND ec.code IN ('1','2','3','4'))    AS deficit_actual,

  -- SR scope only (excludes funding_source_code '2' and '3' = mimorozpočtové)
  SUM(bf.value) FILTER (
    WHERE bf.is_approved AND ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS total_revenue_approved_sr,
  SUM(bf.value) FILTER (
    WHERE NOT bf.is_approved AND ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS total_revenue_actual_sr,
  SUM(bf.value) FILTER (
    WHERE bf.is_approved AND ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS total_expenditure_approved_sr,
  SUM(bf.value) FILTER (
    WHERE NOT bf.is_approved AND ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) AS total_expenditure_actual_sr,
  (SUM(bf.value) FILTER (
    WHERE bf.is_approved AND ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) - SUM(bf.value) FILTER (
    WHERE bf.is_approved AND ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  )) AS deficit_approved_sr,
  (SUM(bf.value) FILTER (
    WHERE NOT bf.is_approved AND ec.code IN ('5','6')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  ) - SUM(bf.value) FILTER (
    WHERE NOT bf.is_approved AND ec.code IN ('1','2','3','4')
      AND (bf.funding_source_code IN ('1','4','5') OR bf.funding_source_code IS NULL)
  )) AS deficit_actual_sr
FROM budget_facts bf
JOIN economic_items   ei ON ei.id = bf.item_id
JOIN economic_groups  eg ON eg.id = ei.group_id
JOIN economic_classes ec ON ec.id = eg.class_id
GROUP BY bf.fiscal_year
WITH DATA;
