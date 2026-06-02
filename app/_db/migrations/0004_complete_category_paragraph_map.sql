-- Refresh category_paragraph_map for remaining expense categories.
-- Migration 0003 added ~370 new paragrafy across the tree but only refreshed
-- the map for 4 categories (socialProtection, transport, environment, industry).
-- This migration completes the refresh for the rest, idempotent via
-- ON CONFLICT (category_id, paragraph_id) DO NOTHING.

-- healthcare ← oddíl 35
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'healthcare'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id = (SELECT id FROM functional_divisions WHERE code = '35')
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

-- education ← oddíly 31, 32
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'education'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (SELECT id FROM functional_divisions WHERE code IN ('31', '32'))
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

-- cultureAndSport ← oddíly 33, 34
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'cultureAndSport'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (SELECT id FROM functional_divisions WHERE code IN ('33', '34'))
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

-- defenseAndSecurity ← oddíly 51, 52, 53, 55
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'defenseAndSecurity'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (SELECT id FROM functional_divisions WHERE code IN ('51', '52', '53', '55'))
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

-- publicAdministration ← oddíly 61, 62, 54
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'publicAdministration'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (SELECT id FROM functional_divisions WHERE code IN ('61', '62', '54'))
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

-- debtService ← paragraf 6310 (single paragraph, already mapped, but safe to retry)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'debtService'), id
FROM functional_paragraphs WHERE code = '6310'
ON CONFLICT (category_id, paragraph_id) DO NOTHING;
