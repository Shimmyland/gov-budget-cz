-- Roll back level-2 subcategory pilot (migrations 0016 + 0017).
--
-- Decision: Level-2 subcategories (curated app-defined groupings between
-- top-level categories and vyhláška paragraphs) defer until post-MVP.
-- Reason: state budget data structure ("transfery krajům" lumped into
-- pododdíl 329 representing 73 % of education) makes intuitive subcategory
-- groupings divergent from reported data. Rather than ship a confusing
-- middle layer, we go directly from level 1 (UI category) → level 3
-- (paragraf). Level 2 design becomes a post-MVP feature once the team has
-- experience with real data shape.
--
-- See docs/subcategories.md for the preserved conceptual design.

-- Delete all subcategory rows (those with parent_id IS NOT NULL).
-- category_paragraph_map cleanup is automatic via ON DELETE CASCADE.
DELETE FROM categories WHERE parent_id IS NOT NULL;
