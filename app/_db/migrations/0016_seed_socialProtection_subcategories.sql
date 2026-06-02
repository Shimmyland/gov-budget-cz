-- Subcategories for socialProtection. Pilot implementation of level-2 UI hierarchy.
-- See docs/subcategories.md for design reasoning and decisions.
--
-- 6 subkategorií, code prefix pattern mapping:
--   pensions             → 411x, 415x  (~740 mld)
--   sicknessBenefits     → 412x        (~49 mld)
--   familyBenefits       → 413x, 414x  (~63 mld)
--   materialNeedBenefits → 417x, 418x, 419x  (~70 mld)
--   employmentSupport    → 42xx        (~16 mld)
--   socialServices       → 43xx        (~83 mld)
-- Total: ~1 021 mld (sedí na top-level socialProtection)

-- ── Subcategories (rows in `categories` with parent_id) ────────────────────
INSERT INTO categories (slug, type, parent_id, is_mandatory) VALUES
  ('pensions',             'expense',
    (SELECT id FROM categories WHERE slug = 'socialProtection'), TRUE),
  ('sicknessBenefits',     'expense',
    (SELECT id FROM categories WHERE slug = 'socialProtection'), TRUE),
  ('familyBenefits',       'expense',
    (SELECT id FROM categories WHERE slug = 'socialProtection'), FALSE),
  ('materialNeedBenefits', 'expense',
    (SELECT id FROM categories WHERE slug = 'socialProtection'), TRUE),
  ('employmentSupport',    'expense',
    (SELECT id FROM categories WHERE slug = 'socialProtection'), FALSE),
  ('socialServices',       'expense',
    (SELECT id FROM categories WHERE slug = 'socialProtection'), FALSE);

-- ── Paragraph mappings via code prefix patterns ───────────────────────────
-- `LIKE '411_'` matches 4-digit codes starting with '411' (e.g. 4111, 4112, …).
-- Underscore is single-char wildcard in SQL LIKE.

-- pensions: pododdíl 411 (důchody) + 415 (zvláštní soc. dávky ozbrojených sil)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'pensions'), id
FROM functional_paragraphs
WHERE code LIKE '411_' OR code LIKE '415_';

-- sicknessBenefits: pododdíl 412 (nemocenské pojištění)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'sicknessBenefits'), id
FROM functional_paragraphs
WHERE code LIKE '412_';

-- familyBenefits: pododdíl 413 (SSP) + 414 (pěstounská péče)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'familyBenefits'), id
FROM functional_paragraphs
WHERE code LIKE '413_' OR code LIKE '414_';

-- materialNeedBenefits: pododdíly 417 (hmotná nouze) + 418 (ZTP) + 419 (ostatní vč. příspěvku na péči)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'materialNeedBenefits'), id
FROM functional_paragraphs
WHERE code LIKE '417_' OR code LIKE '418_' OR code LIKE '419_';

-- employmentSupport: celý oddíl 42 (politika zaměstnanosti)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'employmentSupport'), id
FROM functional_paragraphs
WHERE code LIKE '42__';

-- socialServices: celý oddíl 43 (sociální služby vč. správy 436)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'socialServices'), id
FROM functional_paragraphs
WHERE code LIKE '43__';
