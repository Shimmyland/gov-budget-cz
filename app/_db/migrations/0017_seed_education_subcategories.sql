-- Subcategories for education (oddíly 31, 32). See docs/subcategories.md for reasoning.
--
-- 4 subkategorií, code prefix pattern mapping:
--   preschoolBasic         → 311x               (MŠ + ZŠ)
--   secondaryEducation     → 312x, 315x         (Střední + VOŠ)
--   higherEducation        → 321x, 322x         (VŠ + koleje/menzy)
--   otherEducationServices → 313x, 314x, 323x,
--                            326x, 329x         (výchovné ústavy, stravování, ZUŠ, správa, ostatní)
--
-- Pozn.: subcategory "researchAndDevelopment" záměrně vynechána. Paragraf 3212
-- (V&V na VŠ) jde do higherEducation. Oddíl 38 (Ostatní V&V) není mapovaný na
-- education vůbec — řešitelné samostatně později.

-- ── Subkategorie ──────────────────────────────────────────────────────────
INSERT INTO categories (slug, type, parent_id, is_mandatory) VALUES
  ('preschoolBasic',         'expense',
    (SELECT id FROM categories WHERE slug = 'education'), FALSE),
  ('secondaryEducation',     'expense',
    (SELECT id FROM categories WHERE slug = 'education'), FALSE),
  ('higherEducation',        'expense',
    (SELECT id FROM categories WHERE slug = 'education'), FALSE),
  ('otherEducationServices', 'expense',
    (SELECT id FROM categories WHERE slug = 'education'), FALSE);

-- ── Mapování paragrafů ────────────────────────────────────────────────────

-- preschoolBasic: pododdíl 311 (Předškolní a základní vzdělávání)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'preschoolBasic'), id
FROM functional_paragraphs
WHERE code LIKE '311_';

-- secondaryEducation: pododdíly 312 (Střední vzdělávání) + 315 (VOŠ)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'secondaryEducation'), id
FROM functional_paragraphs
WHERE code LIKE '312_' OR code LIKE '315_';

-- higherEducation: pododdíly 321 (Vysokoškolské vzdělávání) + 322 (Zařízení související s VŠ)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'higherEducation'), id
FROM functional_paragraphs
WHERE code LIKE '321_' OR code LIKE '322_';

-- otherEducationServices: 313 (výchovné ústavy), 314 (stravování, družiny),
-- 323 (ZUŠ, jazykové), 326 (správa), 329 (ostatní)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'otherEducationServices'), id
FROM functional_paragraphs
WHERE code LIKE '313_' OR code LIKE '314_' OR code LIKE '323_'
   OR code LIKE '326_' OR code LIKE '329_';
