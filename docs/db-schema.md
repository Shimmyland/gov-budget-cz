# Datový model PostgreSQL pro gov-budget-cz

## Architektura — hvězdicové schéma (Star Schema)

Datový model vychází z principu **hvězdicového schématu (star schema)** — standardního přístupu pro analytické databáze a datové sklady (OLAP).

### Princip

Uprostřed je jedna velká **tabulka faktů** (`budget_facts`) obsahující číselné hodnoty.
Kolem ní jsou **dimenzionální tabulky** popisující kontext každého záznamu.

```
                    functional_paragraphs
                           ↑
chapters ← chapter_org_units ← budget_facts → economic_items
                                     ↑
                               fiscal_year (sloupec)
```

Tabulka faktů obsahuje pouze cizí klíče a hodnotu — žádné popisné texty. Ty jsou výhradně v dimenzích. Díky tomu lze data efektivně agregovat libovolným řezem:

| dotaz                                    | GROUP BY                                 |
| ---------------------------------------- | ---------------------------------------- |
| Kolik stát vydal na vzdělávání?          | `functional_paragraphs` → `categories`   |
| Kolik vydalo MŠMT celkem?                | `chapter_org_units` → `chapters`         |
| Jak rostly platy ve státní správě?       | `economic_items.code = '5011'` přes roky |
| Kolik dává každé ministerstvo na obranu? | `chapters` × `functional_paragraphs`     |

### Jeden řádek rozpočtu

Každý výdaj/příjem je identifikován kombinací čtyř dimenzí:

```
OSS × Paragraf × Položka × Rok = Hodnota
  rektorát ČVUT   3141     5011    2025    450 mil. Kč
     ↓               ↓       ↓
chapter_org_units  functional  economic
     ↓             _paragraphs  _items
  chapters
```

### Aplikační vrstva

Veřejné kategorie (`socialProtection`, `vat`…) **nejsou dimenze** — jsou to pojmenované agregační pohledy nad paragrafy definované v `category_paragraph_map`. Slouží pouze pro zjednodušené zobrazení v UI pro veřejnost.

---

## Přehled tabulek

```
SPRÁVNÍ TŘÍDĚNÍ          FUNKČNÍ TŘÍDĚNÍ           DRUHOVÉ TŘÍDĚNÍ
──────────────────       ──────────────────────    ──────────────────────
chapters                 functional_divisions      economic_classes
  └── chapter_org_units    └── functional_           └── economic_groups
                               subdivisions              └── economic_items
                               └── functional_
                                   paragraphs

TABULKA FAKTŮ
─────────────────────────────────────────────────────────────────────────
budget_facts  (chapter × org_unit × paragraph × item × year = value)

APLIKAČNÍ VRSTVA (veřejná app)
──────────────────────────────
categories  ←── category_paragraph_map ───→  functional_paragraphs
  └── (parent_id = podkategorie)
```

---

## 1. Správní třídění (kapitoly a org. jednotky)

```sql
CREATE TABLE chapters (
  id   SERIAL PRIMARY KEY,
  code VARCHAR(20)  NOT NULL UNIQUE,   -- "323", "313"
  slug VARCHAR(100) NOT NULL UNIQUE    -- klíč do JSON překladu
);

-- Organizační jednotky jsou vždy součástí kapitoly
CREATE TABLE chapter_org_units (
  id         SERIAL PRIMARY KEY,
  chapter_id INTEGER NOT NULL REFERENCES chapters(id) ON DELETE CASCADE,
  code       VARCHAR(20) NOT NULL,           -- interní kód OSS
  name_cs    TEXT NOT NULL,                  -- "Rektorát ČVUT"
  UNIQUE (chapter_id, code)
);
```

---

## 2. Funkční třídění (oddíl → pododdíl → paragraf)

Každá úroveň je vlastní tabulka — relace jsou explicitní, bez self-referential `parent_id`.

Každá tabulka má `slug` jako klíč do JSON slovníků. Cron periodicky propisuje `name_cs` do `cs.json`
pod sekci `classifications`; anglické překlady se doplňují ručně nebo importem z Eurostatu.

Anglické názvy COFOG kódů jsou dostupné z těchto oficiálních zdrojů (ke stažení jako Excel/CSV):

- **Eurostat RAMON** — Reference And Management Of Nomenclatures; hledej `eurostat RAMON COFOG classification`
- **UN Statistics Division** — COFOG je původně standard OSN; hledej `UN COFOG classification functions of government`

> **Poznámka:** `slug` může být v budoucnu redundantní vůči `code` — kódy jsou unikátní napříč
> celým slovníkem (různé tabulky se nepřekrývají). Pokud se to potvrdí, `slug` lze odstranit
> a jako klíč do slovníku použít přímo `code`.

```sql
-- Úroveň 1: oddíly (2 cifry) — "31" = Vzdělávání
CREATE TABLE functional_divisions (
  id      SERIAL PRIMARY KEY,
  code    VARCHAR(2)   NOT NULL UNIQUE,
  slug    VARCHAR(100) NOT NULL UNIQUE,  -- klíč do JSON slovníku
  name_cs TEXT NOT NULL
);

-- Úroveň 2: pododdíly (3 cifry) — "314" = Vzdělávání jinde nezařazené
CREATE TABLE functional_subdivisions (
  id          SERIAL PRIMARY KEY,
  division_id INTEGER NOT NULL REFERENCES functional_divisions(id) ON DELETE CASCADE,
  code        VARCHAR(3)   NOT NULL UNIQUE,
  slug        VARCHAR(100) NOT NULL UNIQUE,
  name_cs     TEXT NOT NULL
);

-- Úroveň 3: paragrafy (4 cifry) — "3141" = Vysoké školy  ← budget_facts reference
CREATE TABLE functional_paragraphs (
  id             SERIAL PRIMARY KEY,
  subdivision_id INTEGER NOT NULL REFERENCES functional_subdivisions(id) ON DELETE CASCADE,
  code           VARCHAR(4)   NOT NULL UNIQUE,
  slug           VARCHAR(100) NOT NULL UNIQUE,
  name_cs        TEXT NOT NULL
);
```

> **Poznámka — placeholder `00` / `000` / `0000`:**
> Příjmové položky (třídy 1–4 v druhovém třídění) typicky nemají v zdrojových MIS-RIS datech
> vyplněnou funkční oblast (`0FUNC_AREA = '000000'`). Protože `budget_facts.paragraph_id` je
> `NOT NULL`, byl migrací `0006` přidán synthetic placeholder řetězec:
> oddíl `00` → pododdíl `000` → paragraf `0000` (`name_cs = "Nezařazeno — příjmy bez funkčního třídění"`).
> Tyto kódy záměrně **nepocházejí** z vyhlášky 412/2021 Sb. (tam neexistují) a jejich slug obsahuje
> `-placeholder` aby je šlo bezpečně filtrovat v UI / agregátech.

---

## 3. Druhové třídění (třída → seskupení → položka)

> **Poznámka:** Stejně jako u funkčního třídění — `slug` může být v budoucnu redundantní vůči `code`
> a lze ho odstranit pokud se potvrdí, že kódy jsou unikátní napříč celým slovníkem.

```sql
-- Úroveň 1: třídy (1 cifra) — "5" = Běžné výdaje, "1" = Daňové příjmy
CREATE TABLE economic_classes (
  id      SERIAL PRIMARY KEY,
  code    CHAR(1)      NOT NULL UNIQUE,
  slug    VARCHAR(100) NOT NULL UNIQUE,
  name_cs TEXT NOT NULL
);

-- Úroveň 2: seskupení položek (2 cifry) — "50" = Výdaje na zboží a služby
CREATE TABLE economic_groups (
  id       SERIAL PRIMARY KEY,
  class_id INTEGER NOT NULL REFERENCES economic_classes(id) ON DELETE CASCADE,
  code     VARCHAR(2)   NOT NULL UNIQUE,
  slug     VARCHAR(100) NOT NULL UNIQUE,
  name_cs  TEXT NOT NULL
);

-- Úroveň 3: položky (4 cifry) — "5011" = Platy zaměstnanců  ← budget_facts reference
CREATE TABLE economic_items (
  id       SERIAL PRIMARY KEY,
  group_id INTEGER NOT NULL REFERENCES economic_groups(id) ON DELETE CASCADE,
  code     VARCHAR(4)   NOT NULL UNIQUE,
  slug     VARCHAR(100) NOT NULL UNIQUE,
  name_cs  TEXT NOT NULL
);
```

---

## 4. Tabulka faktů

Jeden řádek = jeden plně kvalifikovaný MIS-RIS záznam — kombinace 10 dimenzí
(rok, měsíc, OSS, paragraf, položka, podkladové, nástrojové, doplňkové, programové, účelové)

- 5 rozpočtových stavů side-by-side jako NULLable sloupce.

> **Design rationale:** Starší alternativou byl design "1 řádek per (rok, OSS, paragraf, položka)
> × 2 (schválený vs. skutečnost flag `is_approved`)". Tento projekt byl od počátku navržen s variantou A
> — jeden řádek per plný MIS-RIS tuple s 5 hodnotovými sloupci. Důvody: (a) `is_approved` by zachycoval
> jen 2 ze 4 rozpočtových stavů; (b) `nastroj_code` (EU/FM identifikace) a další dimenze vyžadují
> plný tuple jako klíč; (c) jednotná struktura je čistší pro analytické dotazy.

> **Proč zde není `chapter_id`:**
> V reálných datech z IISSP má každý řádek vždy vyplněnou organizační složku státu (OSS).
> OSS je vždy součástí konkrétní kapitoly (`chapter_org_units.chapter_id`), takže kapitola
> je vždy odvoditelná přes join — není třeba ji ukládat zvlášť.

```sql
CREATE TABLE budget_facts (
  id                   BIGSERIAL PRIMARY KEY,
  fiscal_year          SMALLINT NOT NULL,
  fiscal_month         SMALLINT NOT NULL,                              -- 1–12; měsíční granularita

  -- FK dimenze (vyhláška 412/2021 Sb. dimenze #1 přes OSS, #2 druhové, #3 odvětvové)
  org_unit_id          INTEGER NOT NULL REFERENCES chapter_org_units(id),
  paragraph_id         INTEGER NOT NULL REFERENCES functional_paragraphs(id),
  item_id              INTEGER NOT NULL REFERENCES economic_items(id),

  -- Inline dimenze (kódy z MIS-RIS přímo, bez separátních číselníků)
  funding_source_code  CHAR(1),       -- #5 podkladové (ZC_ZDROJA)
  nastroj_code         VARCHAR(20),   -- #7 nástrojové (ZC_NASTRJ) — EU/FM/NPO/SZP identifikace
  fund_code            VARCHAR(20),   -- #8 doplňkové (ZC_FUND) — účelově sledovaný celek
  eds_code             VARCHAR(20),   -- #9 programové (ZC_EDS) — EDS/SMVS program
  ucris_code           VARCHAR(20),   -- #10 účelové (ZC_UCRIS)

  -- Rozpočtové stavy z MIS-RIS — viz sekce "Hodnotové sloupce" níže
  value_approved       NUMERIC(14, 2),   -- ZU_ROZSCH
  value_amended        NUMERIC(14, 2),   -- ZU_ROZPZM
  value_final          NUMERIC(14, 2),   -- ZU_KROZP
  value_actual         NUMERIC(14, 2),   -- ZU_ROZKZ
  value_obligation     NUMERIC(14, 2)    -- ZU_OBLIG
);
```

### Hodnotové sloupce — co znamenají

Každý řádek `budget_facts` může mít až 5 různých Kč hodnot vedle sebe. Každá zachycuje stejný (rok, OSS, paragraf, položka, …) tuple, ale **v jiné fázi rozpočtového cyklu**.

| Sloupec            | MIS-RIS     | Český název             | Co to znamená                                                                       | Příklad pro 2024 výdaje SR celkem |
| ------------------ | ----------- | ----------------------- | ----------------------------------------------------------------------------------- | --------------------------------- |
| `value_approved`   | `ZU_ROZSCH` | **Schválený rozpočet**  | Co Sněmovna podepsala v zákoně o SR (před začátkem roku)                            | 2 222 mld                         |
| `value_amended`    | `ZU_ROZPZM` | **Rozpočet po změnách** | Po novelách zákona + rozpočtových opatřeních v průběhu roku                         | 2 242 mld                         |
| `value_final`      | `ZU_KROZP`  | **Konečný rozpočet**    | Po změnách **+ zapojení nároků z minulých let (NNV)** = maximum, co OSS smí utratit | 2 401 mld                         |
| `value_actual`     | `ZU_ROZKZ`  | **Skutečnost**          | Reálné cash plnění za rok                                                           | 2 234 mld                         |
| `value_obligation` | `ZU_OBLIG`  | **Obligace**            | Podepsané závazky, dosud nezaplacené (forward-looking)                              | —                                 |

**Důležité technické poznámky:**

- Všechny sloupce jsou **NULLable**. NULL = "tato hodnota není pro daný tuple v MIS-RIS přítomná" (např. paragraf nemá schválený rozpočet, ale měl by čerpání NNV → `value_approved IS NULL`, `value_actual IS NOT NULL`).
- `value_final` pro **příjmové třídy (1–4) je vždy NULL** — NNV se týkají jen výdajů, MIS-RIS pro příjmy `ZU_KROZP` nevyplňuje.
- Hodnoty mohou být záporné — ETL parser umí Czech "trailing minus" notation (`14822772561.30-` = −14.8 mld), což jsou typicky vratky a korekce.

### Které sloupce reálně používá aplikace?

V současné UI vrstvě **bere repository jen dva**:

| UI koncept                                                  | Sloupec          | Význam                |
| ----------------------------------------------------------- | ---------------- | --------------------- |
| **"Plán"** (např. "rozpočet 2024 = schodek 282 mld")        | `value_approved` | Co Sněmovna schválila |
| **"Realita"** (např. "skutečnost 2024 = schodek 271.5 mld") | `value_actual`   | Co se reálně utratilo |

Sloupce `value_amended`, `value_final`, `value_obligation` jsou v DB **pro budoucí analytické use cases**, ale **aktuální app je nečte**. Příklady kdy bychom je teprve začali používat:

- `value_amended` — pokud bychom chtěli ukázat "jak se rozpočet měnil v průběhu roku" (pro 2020/2021 covid roky to byl 10× nárůst — dramatická story).
- `value_final` — pokud bychom chtěli ukázat "kolik kapitola/program mohl maximálně utratit" vs. kolik utratil (poukáže na velikost NNV bufferů).
- `value_obligation` — forward-looking analýza fiscal commitments pro investory / credit rating.

### Které dimenze reálně používá aplikace?

| UI vrstva                    | Dimenze                                   | Sloupec                    |
| ---------------------------- | ----------------------------------------- | -------------------------- |
| 11 výdajových kategorií      | paragraph (přes `category_paragraph_map`) | `paragraph_id` FK          |
| 6 příjmových kategorií       | položka (regex pattern v repository)      | `item_id` FK               |
| Kapitoly (sekundární pohled) | kapitola přes OSS                         | `org_unit_id` → `chapters` |
| SR scope filter              | podkladové třídění                        | `funding_source_code`      |

Ostatní inline dimenze (`nastroj_code`, `fund_code`, `eds_code`, `ucris_code`) jsou v DB **pro budoucí analytic use cases**, aplikace na ně dnes nedotazuje:

- `nastroj_code` — EU/FM identifikace pro "po očištění" metodiku schodku.
- `fund_code` — topické cross-cuts (Ukrajina, covid, povodně).
- `eds_code` — drill-down do konkrétních programů (Modernizace ZŠ, NPO komponenty).
- `ucris_code` — účel transferů napříč kapitolami (ICT, mzdy).

---

## 5. Aplikační vrstva — veřejné kategorie

Kategorie nejsou dimenze — jsou to **pojmenované pohledy** nad paragrafy pro veřejnou app.
Podkategorie jsou kategorie s vyplněným `parent_id` (max. 2 úrovně pro MVP).

```sql
CREATE TYPE category_type AS ENUM ('expense', 'income');

CREATE TABLE categories (
  id           SERIAL PRIMARY KEY,
  parent_id    INTEGER REFERENCES categories(id),  -- NULL = kategorie, jinak podkategorie
  slug         VARCHAR(60) NOT NULL UNIQUE,
  type         category_type NOT NULL,
  is_mandatory BOOLEAN NOT NULL DEFAULT FALSE
);

-- Mapování: která kategorie agreguje které paragrafy
CREATE TABLE category_paragraph_map (
  category_id  INTEGER NOT NULL REFERENCES categories(id) ON DELETE CASCADE,
  paragraph_id INTEGER NOT NULL REFERENCES functional_paragraphs(id) ON DELETE CASCADE,
  PRIMARY KEY (category_id, paragraph_id)
);
```

---

## 6. Agregátní pohled na fiskální roky

Materialized view `fiscal_year_totals` — refresh po každém seedu/updatu dat.
Aktuální stav (migrace `0001`): **8 hodnotových sloupců** (revenue × 4 stavy, expenditure × 4 stavy) **+ 2 pre-computed salda** (approved, actual). Všechny v SR scope.

```sql
CREATE MATERIALIZED VIEW fiscal_year_totals AS
SELECT
  bf.fiscal_year,
  -- Příjmy ve všech 4 rozpočtových stavech (revenue_final je vždy NULL — NNV se týkají jen výdajů)
  SUM(bf.value_approved) FILTER (...) AS revenue_approved,
  SUM(bf.value_amended)  FILTER (...) AS revenue_amended,
  SUM(bf.value_final)    FILTER (...) AS revenue_final,
  SUM(bf.value_actual)   FILTER (...) AS revenue_actual,
  -- Výdaje ve všech 4 stavech
  SUM(bf.value_approved) FILTER (...) AS expenditure_approved,
  SUM(bf.value_amended)  FILTER (...) AS expenditure_amended,
  SUM(bf.value_final)    FILTER (...) AS expenditure_final,
  SUM(bf.value_actual)   FILTER (...) AS expenditure_actual,
  -- Pre-computed salda: revenue − expenditure (kladné = přebytek, záporné = schodek)
  revenue_approved - expenditure_approved AS balance_approved,
  revenue_actual   - expenditure_actual   AS balance_actual
FROM budget_facts bf JOIN economic_items ... JOIN economic_groups ... JOIN economic_classes ...
GROUP BY bf.fiscal_year WITH DATA;

-- Refresh:
-- REFRESH MATERIALIZED VIEW fiscal_year_totals;
```

**SR scope filter** baked do každé agregace: `funding_source_code IN ('1','4','5') OR IS NULL`. NULL pokrývá 2020–2023 MIS-RIS soubory, které tento sloupec nemají.

### Která salda NEJSOU v MV materializovaná

Pouze `balance_approved` a `balance_actual` — protože jen ty UI reálně zobrazuje. Pokud budeš chtít saldo _po změnách_ nebo _konečné_, spočítáš si je ad-hoc:

```sql
-- Saldo po změnách (rozpočet po novelách):
SELECT revenue_amended - expenditure_amended FROM fiscal_year_totals WHERE fiscal_year = 2024;
-- = −282 mld 2024 (záporné = schodek; změny v 2024 byly symetrické, schodek se nezměnil)

-- "Konečné" saldo nelze smysluplně počítat — revenue_final je vždy NULL.
```

### Validace proti MF SZÚ Sešit G Tabulka 1 (rok 2024)

| Metrika                 | MF SZÚ (mld) | Náš MV (mld)                  | Diff     |
| ----------------------- | ------------ | ----------------------------- | -------- |
| Příjmy schválené        | 1940.0       | `revenue_approved` 1940.0     | **0**    |
| Příjmy po změnách       | 1960.2       | `revenue_amended` 1960.2      | **0**    |
| Příjmy skutečnost       | 1965.4       | `revenue_actual` 1962.5       | −2.9     |
| Výdaje schválené        | 2222.0       | `expenditure_approved` 2222.0 | **0**    |
| Výdaje po změnách       | 2242.2       | `expenditure_amended` 2242.2  | **0**    |
| Výdaje konečný (po NNV) | 2403.9       | `expenditure_final` 2401.0    | −2.9     |
| Výdaje skutečnost       | 2236.8       | `expenditure_actual` 2234.0   | −2.8     |
| **Schodek schválený**   | **282.0**    | `balance_approved` −282.0     | **0**    |
| **Schodek skutečnost**  | **271.4**    | `balance_actual` −271.5       | **+0.1** |

Schválené stavy sedí **na haléř**. Skutečnost má diff −2.8/−2.9 na obou stranách, ale tyto diffy se vyruší → **saldo (schodek) sedí prakticky na 0.1 mld** (~0.04 %).

---

## Indexy

```sql
-- Nejčastější: všechna data pro daný rok
CREATE INDEX idx_facts_fiscal_year ON budget_facts(fiscal_year);

-- Time-series po měsících v rámci roku
CREATE INDEX idx_facts_year_month  ON budget_facts(fiscal_year, fiscal_month);

-- Pohled podle OSS (a tím nepřímo i podle kapitoly přes chapter_org_units.chapter_id)
CREATE INDEX idx_facts_org_unit    ON budget_facts(org_unit_id);

-- Pohled podle funkčního třídění
CREATE INDEX idx_facts_paragraph   ON budget_facts(paragraph_id);

-- Pohled podle druhového třídění
CREATE INDEX idx_facts_item        ON budget_facts(item_id);

-- Composite: rok + OSS (nejčastější analytický dotaz, např. „kolik vydala kapitola X v roce Y")
CREATE INDEX idx_facts_year_org    ON budget_facts(fiscal_year, org_unit_id);

-- Nástrojové třídění (EU/FM/NPO/SZP filter — "po očištění" metodika)
CREATE INDEX idx_facts_nastroj     ON budget_facts(nastroj_code);
```

---

## Příklady dotazů

> **Poznámka:** schema vždy pracuje s konkrétním hodnotovým sloupcem (`value_actual` pro skutečnost,
> `value_approved` pro schválený, atd.) — obecný sloupec `bf.value` neexistuje.

```sql
-- Veřejná app: skutečné výdaje per kategorie pro rok 2025
SELECT c.slug, SUM(bf.value_actual) AS total
FROM budget_facts bf
JOIN category_paragraph_map m ON m.paragraph_id = bf.paragraph_id
JOIN categories c ON c.id = m.category_id
WHERE bf.fiscal_year = 2025
  AND c.parent_id IS NULL   -- jen top-level kategorie
  AND bf.value_actual IS NOT NULL
GROUP BY c.slug;

-- Analýza: skutečnost kapitoly 333 (MŠMT) podle paragrafů
SELECT fp.code, fp.name_cs, SUM(bf.value_actual) AS total
FROM budget_facts bf
JOIN chapter_org_units cou ON cou.id = bf.org_unit_id
JOIN chapters ch ON ch.id = cou.chapter_id
JOIN functional_paragraphs fp ON fp.id = bf.paragraph_id
WHERE ch.code = '333'
  AND bf.fiscal_year = 2025
GROUP BY fp.code, fp.name_cs
ORDER BY total DESC;

-- Schválený rozpočet (plán) per kapitola, 2025
SELECT ch.code, SUM(bf.value_approved) AS plan_2025
FROM budget_facts bf
JOIN chapter_org_units cou ON cou.id = bf.org_unit_id
JOIN chapters ch ON ch.id = cou.chapter_id
WHERE bf.fiscal_year = 2025
GROUP BY ch.code
ORDER BY plan_2025 DESC;

-- Analytický příklad (future): EU/FM výdaje per kapitola
-- nastroj_code != '0000' → nějaký nástroj (EU OP, NPO, FM EHP, SZP...)
SELECT ch.code, SUM(bf.value_actual) AS eu_spend
FROM budget_facts bf
JOIN chapter_org_units cou ON cou.id = bf.org_unit_id
JOIN chapters ch ON ch.id = cou.chapter_id
WHERE bf.fiscal_year = 2024
  AND bf.nastroj_code IS NOT NULL
  AND bf.nastroj_code != '0000'
GROUP BY ch.code
ORDER BY eu_spend DESC;
```

---

## Mapování na stávající TypeScript typy (MVP)

| TypeScript (`types.ts`)     | DB                                                             |
| --------------------------- | -------------------------------------------------------------- |
| `BudgetYear`                | `budget_facts.fiscal_year`                                     |
| `YearData.totalRevenue`     | `fiscal_year_totals.revenue_actual`                            |
| `YearData.totalExpenditure` | `fiscal_year_totals.expenditure_actual`                        |
| `YearData.balance`          | `fiscal_year_totals.balance_actual`                            |
| `PieSlice.name`             | `categories.slug`                                              |
| `PieSlice.value`            | `SUM(budget_facts.value_actual)` přes `category_paragraph_map` |
| `PieSlice.mandatory`        | `categories.is_mandatory`                                      |
| `PieSlice.cofogCodes`       | `functional_paragraphs.code` přes `category_paragraph_map`     |
| `SubCategory.name`          | funkční pododdíl (`functional_subdivisions.name_cs`) nebo `economic_items.name_cs` |
| `SubCategory.value`         | `SUM(budget_facts.value_actual)` per pododdíl/položka          |

---

## Granularita dat

Schema zachycuje plnou granularitu MIS-RIS — 10 ze 12 dimenzí vyhlášky 412/2021 Sb. + 5 hodnotových stavů.

| Dimenze                                | V `budget_facts`                                            | MIS-RIS sloupec                                 |
| -------------------------------------- | ----------------------------------------------------------- | ----------------------------------------------- |
| Rok                                    | `fiscal_year SMALLINT`                                      | `0FISCPER[0:4]`                                 |
| Měsíc                                  | `fiscal_month SMALLINT`                                     | `0FISCPER[4:7]`                                 |
| #1 Odpovědnostní (OSS → kapitola)      | `org_unit_id` (NOT NULL) → `chapter_org_units` → `chapters` | `ZC_UCJED` + `0FM_AREA`                         |
| #2 Druhové (položka)                   | `item_id` → `economic_items`                                | `ZCMMT_ITM`                                     |
| #3 Odvětvové (paragraf)                | `paragraph_id` → `functional_paragraphs`                    | `0FUNC_AREA[0:4]` (income = placeholder `0000`) |
| #5 Podkladové (zdroj)                  | `funding_source_code CHAR(1)`                               | `ZC_ZDROJA` (2024+ only, NULL pro 2020–2023)    |
| #7 Nástrojové (EU/FM/NPO/SZP)          | `nastroj_code VARCHAR(20)`                                  | `ZC_NASTRJ`                                     |
| #8 Doplňkové (účelově sledovaný celek) | `fund_code VARCHAR(20)`                                     | `ZC_FUND`                                       |
| #9 Programové (EDS/SMVS)               | `eds_code VARCHAR(20)`                                      | `ZC_EDS`                                        |
| #10 Účelové (purpose)                  | `ucris_code VARCHAR(20)`                                    | `ZC_UCRIS`                                      |
| Hodnota — schválený                    | `value_approved NUMERIC(14,2)`                              | `ZU_ROZSCH`                                     |
| Hodnota — po změnách                   | `value_amended NUMERIC(14,2)`                               | `ZU_ROZPZM`                                     |
| Hodnota — konečný (po NNV)             | `value_final NUMERIC(14,2)`                                 | `ZU_KROZP`                                      |
| Hodnota — skutečnost                   | `value_actual NUMERIC(14,2)`                                | `ZU_ROZKZ`                                      |
| Hodnota — obligace                     | `value_obligation NUMERIC(14,2)`                            | `ZU_OBLIG`                                      |

**Dimenze ze vyhlášky které nezachycujeme:** #4 Konsolidační (neaplikovatelné na SR-only data), #6 Prostorové (tuzemsko/zahraničí; pro SR málo variace), #11 Strukturní, #12 Transferové. Lze přidat v budoucí migraci, pokud vznikne use case.

### Proč jeden řádek per tuple, ne dva

Alternativní design "2 řádky per MIS-RIS záznam (jeden s `value=ZU_ROZSCH, is_approved=TRUE`, druhý s `value=ZU_ROZKZ, is_approved=FALSE`)" byl odmítnut: **nemohl zachytit `ZU_ROZPZM` ani `ZU_KROZP`** — byl by ztracen 50 % obsahu MIS-RIS hodnot.

Výsledný design = jeden řádek per (rok, měsíc, OSS, paragraf, položka, dimenze) tuple, všech 5 hodnot side-by-side. ETL skipuje řádky kde všech 5 je 0. Důsledek: ~280k–400k řádků per rok.
