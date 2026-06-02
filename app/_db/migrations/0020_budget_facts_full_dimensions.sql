-- Refactor budget_facts to capture full MIS-RIS dimensionality (variant A).
--
-- Background:
-- Prior schema kept only 6 of the 12 vyhláška 412/2021 Sb. dimensions and
-- two of the four budget value states (ZU_ROZSCH, ZU_ROZKZ), splitting each
-- (year, month, OSS, paragraf, item) tuple into two rows by `is_approved`.
-- This prevents:
--   - Identifying EU/FM-funded transactions (needs ZC_NASTRJ, dimenze #7)
--   - Distinguishing "schválený / po změnách / konečný" budget states,
--     which MF reports separately (covid-era novely add up to >450 mld diff)
--   - Tracking forward-looking commitments (ZU_OBLIG)
--
-- New design (variant A):
--   - One row per fully-qualified MIS-RIS tuple (10 dimensions retained)
--   - All five budget value states held side-by-side as NULLable columns
--   - is_approved column dropped — queries select the desired value_* column
--
-- Data must be reseeded via ETL after this migration. The drop is intentional;
-- there's no salvageable in-place transformation because we're adding columns
-- the source CSV has that the prior ETL discarded.

DROP MATERIALIZED VIEW IF EXISTS fiscal_year_totals;
DROP TABLE IF EXISTS budget_facts;

CREATE TABLE budget_facts (
  id                   BIGSERIAL    PRIMARY KEY,
  fiscal_year          SMALLINT     NOT NULL,
  fiscal_month         SMALLINT     NOT NULL,

  -- Existing FK dimensions (vyhláška #1 odpovědnostní via org_unit, #2 druhové, #3 odvětvové)
  org_unit_id          INTEGER      NOT NULL REFERENCES chapter_org_units(id),
  paragraph_id         INTEGER      NOT NULL REFERENCES functional_paragraphs(id),
  item_id              INTEGER      NOT NULL REFERENCES economic_items(id),

  -- Inline dimensions captured as raw codes (no separate lookup tables — small,
  -- limited cardinality, not user-facing names).
  -- #5 podkladové (ZC_ZDROJA): '1' základní, '2'-'3' mimorozp., '4' kryté nároky, '5' překročení.
  -- 2020–2023 MIS-RIS lacked this column → NULL.
  funding_source_code  CHAR(1),

  -- #7 nástrojové (ZC_NASTRJ): identifies funding instrument. '0000' = no instrument,
  -- '01xx' = EU operational programs, '04xx' = FM EHP/Norway, '05xx' = Swiss,
  -- '0143'/'0186' = NPO, '0170' = SZP. Critical for "po očištění o EU/FM" methodology.
  nastroj_code         VARCHAR(20),

  -- #8 doplňkové (ZC_FUND): účelově sledovaný celek. Tail encodes specific earmarked bucket
  -- (e.g., Ukraine aid, covid compensation, flood relief). Leading digit duplicates
  -- funding_source_code (verified 100% match in 2024 sample) — stored as full string for
  -- now, leading-digit redundancy is benign.
  fund_code            VARCHAR(20),

  -- #9 programové (ZC_EDS): EDS/SMVS program identifier. Drill-down into specific
  -- programs/akce ("Modernizace ZŠ", NPO components, OP Doprava projects).
  eds_code             VARCHAR(20),

  -- #10 účelové (ZC_UCRIS): purpose of transfer (mzdy / ICT / vybavení / specific agenda).
  -- Enables cross-cutting analysis like "ICT spending across all chapters".
  ucris_code           VARCHAR(20),

  -- Budget value states from MIS-RIS — all five held side-by-side, NULL when absent.
  -- ZU_ROZSCH — schválený rozpočet (original, per zákon o SR).
  value_approved       NUMERIC(14, 2),
  -- ZU_ROZPZM — rozpočet po změnách (after amendments / rozpočtových opatření).
  value_amended        NUMERIC(14, 2),
  -- ZU_KROZP — konečný rozpočet (after changes + NNV from previous years).
  value_final          NUMERIC(14, 2),
  -- ZU_ROZKZ — skutečnost (actual cash execution).
  value_actual         NUMERIC(14, 2),
  -- ZU_OBLIG — obligace (signed but not yet paid commitments — forward-looking).
  value_obligation     NUMERIC(14, 2)
);

-- Indexes mirror the prior schema's analytical access patterns.
CREATE INDEX idx_facts_fiscal_year ON budget_facts(fiscal_year);
CREATE INDEX idx_facts_year_month  ON budget_facts(fiscal_year, fiscal_month);
CREATE INDEX idx_facts_org_unit    ON budget_facts(org_unit_id);
CREATE INDEX idx_facts_paragraph   ON budget_facts(paragraph_id);
CREATE INDEX idx_facts_item        ON budget_facts(item_id);
CREATE INDEX idx_facts_year_org    ON budget_facts(fiscal_year, org_unit_id);

-- New: nástroj filter is heavily used for EU/FM methodology cuts.
CREATE INDEX idx_facts_nastroj     ON budget_facts(nastroj_code);

-- Materialized view for year-level totals. Follows the post-0019 SR-only
-- convention: only one variant of each metric (SR scope), without the _sr suffix.
-- SR scope filter: funding_source_code IN ('1','4','5') OR IS NULL (NULL handles
-- pre-2024 MIS-RIS files that lack the column).
CREATE MATERIALIZED VIEW fiscal_year_totals AS
SELECT
  bf.fiscal_year,
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
  ) AS expenditure_actual
FROM budget_facts bf
JOIN economic_items   ei ON ei.id = bf.item_id
JOIN economic_groups  eg ON eg.id = ei.group_id
JOIN economic_classes ec ON ec.id = eg.class_id
GROUP BY bf.fiscal_year
WITH DATA;
