# Druhá úroveň hierarchie (subkategorie) — odložená feature

> **Status:** Tato úroveň **není implementována v MVP**. Dokument popisuje koncept a důvody odložení. Bude řešena samostatně až MVP poběží v produkci a budeme mít zpětnou vazbu od uživatelů a hlubší pochopení dat státního rozpočtu.

## Záměr a kontext

UI aplikace pracuje se dvěma úrovněmi kategorizace státního rozpočtu:

```
Úroveň 1:  11 výdajových + 6 příjmových UI kategorií  (Sociální péče, Vzdělávání …)
            ↓
Úroveň 3:  ~528 paragrafů funkčního třídění            (4111 Starobní důchody, …)
```

Detail kategorie ukazuje úroveň 3 (paragrafy) přímo. Pro většinu kategorií je to ~30–80 položek seřazených podle objemu.

Mezi nimi **mohla** existovat **úroveň 2**: 4–7 ručně zakurátorovaných UI subkategorií per kategorie. Příklad pro Sociální péči:

```
Sociální péče (1 021 mld)
├── Důchody                            ~740 mld
├── Nemocenská a mateřská               ~50 mld
├── Rodinné dávky                       ~63 mld
├── Hmotná nouze a podpora postiženým   ~70 mld
├── Politika zaměstnanosti              ~32 mld
└── Sociální služby a správa            ~65 mld
```

Úroveň 2 by byla **most** mezi širokou kategorií a granulárním paragrafem — pro uživatele, který chce postupně proniknout, ne hned se ponořit do desítek čísel.

## Proč to není v MVP

### Pilot na `socialProtection` proběhl bez problémů

Migrace `0016` přidala 6 subkategorií pro Sociální péči s pravidlovým mapováním (`411_, 415_` → `pensions`, atd.). Hodnoty seděly. UX bylo příjemné.

### Pilot na `education` odhalil zásadní data-shape problém

Při migraci `0017` (Vzdělávání) se ukázalo, že státní rozpočet **nemá strukturu, kterou bychom intuitivně očekávali**:

```
329 "Ostatní činnost a nespecifikované výdaje"     224.6 mld  (73 % vzdělávání!)
321 Vysokoškolské vzdělávání                        64.0 mld
311 Předškolní a základní (přímé státní výdaje)      6.5 mld  ← jen drobné
312 Střední (přímé)                                  4.3 mld
[ostatní]                                            7.0 mld
```

**Proč 224 mld v "Ostatní":** Stát nefinancuje ZŠ/MŠ/SŠ přímo. Místo toho **transferuje peníze krajům**, kteří školy provozují. Tyto transfery se v účetnictví státního rozpočtu zaúčtují obvykle jako paragraf `3299` (Ostatní záležitosti vzdělávání) + položka `5323` (Transfery krajům). Detail, kolik šlo konkrétně na ZŠ vs MŠ vs SŠ, **není ve státním rozpočtu vidět** — je v krajských rozpočtech.

Důsledek: jakákoli intuitivní subkategorie typu "Mateřské a základní školy" obsahuje jen ~6 mld přímých státních výdajů, nikoli skutečnou výši financování. Pro laika **klamavé**.

### Stejný problém pravděpodobně postihne další kategorie

- **Healthcare**: státní rozpočet hradí jen ~140 mld z ~700 mld celkových výdajů na zdravotnictví (zbytek přes zdravotní pojišťovny mimo SR)
- **Doprava**: většina financování přes SFDI, transfery na kraje
- **Municipal Transfers**: 100 % je cross-cutting transfer logika

Intuitivní rozdělení (typ školy, typ pacientského zařízení, …) **nesedí na to, co stát skutečně reportuje**. Kurátorské subkategorie by lhaly o struktuře, nebo vyžadovaly přeshranní agregaci s dalšími datovými zdroji (krajské rozpočty, údaje zdravotních pojišťoven).

### Rozhodnutí: odložit, jít přímo z úrovně 1 do 3

Pro MVP:

- Detail stránka kategorie → ukazuje úroveň 3 (paragrafy) přímo
- Žádná "level 2" v mezi
- Migrace pilotu (0016, 0017) byla rollback'nuta v migraci `0018`
- Schema (`categories.parent_id`, `category_paragraph_map`) zůstává — připravené až bude úroveň 2 znovu na řadě

## Co znovu vyřešit, až bude MVP v produkci

Když přijde čas znovu zkusit úroveň 2:

1. **Pravdivě komunikovat strukturu dat** — uživateli vysvětlit, že státní rozpočet ukazuje transfery, ne přímé výdaje na školy
2. **Zvážit augmentaci dalšími zdroji** — pokud chceme reálné rozdělení "kolik na ZŠ", potřebujeme krajská data
3. **Zvážit alternativní level-2 axes** — místo "typ příjemce" (ZŠ/MŠ/SŠ) zkusit "typ výdaje" (transfery, platy, investice — to už máme přes druhové třídění)
4. **Per-kategorii rozhodnout, jestli má smysl** — některé kategorie se mohou ukázat jako přirozeně dělitelné (sociální péče byla), jiné ne (vzdělávání)
5. **Validovat s reálnými uživateli** — co od drill-downu očekávají? Žádá si UX studie

## Co zůstalo v repozitáři po pilotním pokusu

| Co                                                                  | Stav                                       |
| ------------------------------------------------------------------- | ------------------------------------------ |
| Migrace `0016` (socialProtection subkategorie)                      | Aplikovaná, data odstraněna migrací `0018` |
| Migrace `0017` (education subkategorie)                             | Aplikovaná, data odstraněna migrací `0018` |
| Migrace `0018` (DELETE FROM categories WHERE parent_id IS NOT NULL) | Aplikovaná                                 |
| Schema `categories.parent_id`                                       | Zachované — připravené pro budoucí use     |
| Schema `category_paragraph_map`                                     | Zachované                                  |
| Tento dokument                                                      | Aktualizován jako future-feature concept   |

## Související dokumentace

- `db-schema.md` — DB schema (kategorie hierarchie, category_paragraph_map)
- `budget-categorization.md` — úroveň 1 kategorií a jejich mapping na oddíly funkčního třídění
- `monitor-data-sources.md` — popis zdrojových dat
