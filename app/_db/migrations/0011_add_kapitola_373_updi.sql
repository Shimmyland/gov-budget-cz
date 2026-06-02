-- Add kapitola 373 (Úřad pro přístup k dopravní infrastruktuře, ÚPDI).
-- Zrušená k 1.1.2024 (agenda převedena na ÚOHS), proto chybí v zákoně 434/2024 Sb.,
-- který je zdroj naší seed listy pro rok 2025.
--
-- Pro rok 2024 ale kapitola ještě existovala se schváleným rozpočtem
-- 22 354 tis Kč (skutečnost 0). Bez tohoto řádku ETL pro 2024 skipoval 31
-- řádků s chapter_code=373 (FK violation) → schválené výdaje SR 2024 nám chyběly
-- o 22 354 064 Kč oproti oficiálnímu závěrečnému účtu.

INSERT INTO chapters (code, slug) VALUES ('373', 'updi');
