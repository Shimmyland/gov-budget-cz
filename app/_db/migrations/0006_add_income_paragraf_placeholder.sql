-- Placeholder oddíl/pododdíl/paragraf for income rows where 0FUNC_AREA = '000000'.
-- Income items (třídy 1–4 v druhovém třídění) typically have no functional area
-- assigned in MIS-RIS source data. Schema requires paragraph_id NOT NULL, so we
-- route those rows to a synthetic '0000' paragraf marked as placeholder.
--
-- This is intentionally a non-vyhláška entry — code '00'/'000'/'0000' don't
-- appear in vyhláška 412/2021 Sb. The name_cs clearly flags it as placeholder.

INSERT INTO functional_divisions (code, slug, name_cs) VALUES
  ('00', 'division-00-placeholder', 'Bez funkčního třídění (placeholder pro příjmy)');

INSERT INTO functional_subdivisions (division_id, code, slug, name_cs) VALUES
  (
    (SELECT id FROM functional_divisions WHERE code = '00'),
    '000',
    'subdivision-000-placeholder',
    'Bez funkčního třídění (placeholder pro příjmy)'
  );

INSERT INTO functional_paragraphs (subdivision_id, code, slug, name_cs) VALUES
  (
    (SELECT id FROM functional_subdivisions WHERE code = '000'),
    '0000',
    'paragraph-0000-placeholder',
    'Nezařazeno — příjmy bez funkčního třídění'
  );
