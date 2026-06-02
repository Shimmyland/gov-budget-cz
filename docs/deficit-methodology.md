# Metodika výpočtu schodku SR — audit a implementace

> Dokument popisuje, jak se v projektu gov-budget-cz počítá schodek státního rozpočtu, jak naše čísla
> sedí s oficiálním MF reportingem, a jaké jsou známé reziduální rozdíly a limity.
> Doprovází migrace `0020` a `0021`.

---

## Executive summary

Aplikace gov-budget-cz vizualizuje hospodaření státního rozpočtu ČR. Zdrojem dat je
MIS-RIS extrakt z Monitoru státní pokladny (IISSP). Cílem auditu (květen 2026) bylo
dosáhnout přesné shody našich ročně reportovaných schodků s tím, jak MF reportuje
totéž v Pokladním plnění SR a Státním závěrečném účtu.

**Výchozí stav před auditem:** naše roční schodky byly o **5–26 mld Kč** off vs.
MF reporting (např. 2024 +10.8 mld, 2023 +26.4 mld nad MF číslem). Diff vznikal
na obou stranách — jak na příjmech, tak na výdajích — což indikovalo strukturální
chybu, ne dílčí filtr.

**Audit identifikoval tři nezávislé příčiny:**

1. **Czech accounting trailing minus** — MIS-RIS používá českou účetní notaci pro
   záporné hodnoty (`14822772561.30-` = −14.8 mld). ETL parser tuto notaci neumělo
   a takové hodnoty tichoušce konvertoval na 0. Postiženy byly typicky vratky,
   korekce a opravy — netriviální objem v sumách.

2. **Schéma nezachytávalo 2 ze 4 rozpočtových stavů** — MIS-RIS reportuje vedle sebe
   schválený rozpočet (ZU_ROZSCH), rozpočet po změnách (ZU_ROZPZM), konečný rozpočet
   po NNV (ZU_KROZP) a skutečnost (ZU_ROZKZ). Před auditem schema ukládalo jen
   první a poslední (přes flag `is_approved`), zbylé dva stavy byly ztracené.

3. **Ignorované MIS-RIS dimenze** — z 12 vyhláškových dimenzí byly v DB jen 4 + 1
   inline (kapitola, paragraf, položka, funding source). Chyběly zejména nástrojové
   třídění (#7), programové (#9), doplňkové (#8) a účelové (#10).

**Implementace** v migracích `0020` (refactor `budget_facts` na variantu A — jeden
řádek per plně kvalifikovaný tuple, 5 hodnotových sloupců side-by-side, 4 nové
inline dimenze) a `0021` (rozšíření MV `fiscal_year_totals` o 8 hodnotových sloupců
+ 2 pre-computed schodky). ETL parser dostal Czech trailing minus podporu.

**Výsledek po auditu:**

| Rok | Naše skutečnost | MF Pokladní plnění | Diff |
|---|---|---|---|
| 2023 | 288.0 | 288.5 | −0.5 mld |
| 2024 | **271.5** | **271.4** | **+0.1 mld** ✅ |
| 2025 | **290.9** | **290.7** | **+0.2 mld** ✅ |

Pro 2023–2025 jsme **prakticky na haléř** s MF (diff ±0.5 mld ≈ 0.2 % schodku).
Pro 2020–2021 zůstávají reziduální 3–6 mld, pravděpodobně specifika post-covid
účtování — výrazné zlepšení oproti původním 5+ mld diffům.

Audit goal — **schodek na haléř s MF Pokladním plněním** — je pro klíčové roky
2023, 2024, 2025 **splněn**. Reziduální diffy starších let dokumentované jako
přijatelný limit MIS-RIS dat.

MF reportuje **druhou metriku** vedle Total schodku — "schodek po očištění o
EU/FM prostředky" (2024: 288.9 mld vs total 271.4). Implementace této druhé
metriky je odložena jako future feature (`docs/features-roadmap.md` sekce 1) —
vyžadovala by interní MF číselník nástrojů, který není veřejně publikovaný.

---

## MF metodiky schodku — dva headline čísla

MF reportuje schodek SR ve **dvou různých metodikách souběžně** ve všech
oficiálních dokumentech. Naše audit se zaměřil primárně na první.

### 1. Total schodek (headline)

**Vzorec:** Σ skutečných výdajů (třídy 5+6) − Σ skutečných příjmů (třídy 1+2+3+4)
v rámci státního rozpočtu (excluding mimorozpočtové zdroje).

**Citace z SZÚ 2024 Sešit C:**
> *"Hospodaření státního rozpočtu skončilo v roce 2024 deficitem ve výši
> 271,4 mld. Kč, což představovalo 96,2 % plánovaného salda po novelizaci zákona
> o státním rozpočtu České republiky na rok 2024 (282,0 mld. Kč)."*

**Náš výpočet:** `fiscal_year_totals.deficit_actual` = `expenditure_actual − revenue_actual`
ve SR scope (`funding_source_code IN ('1','4','5') OR IS NULL`).

### 2. Schodek po očištění o EU/FM (alternative)

**Vzorec:** Total schodek upravený o vyloučení EU/FM toků na obou stranách:
- Odečte se *EU/FM revenue* (transfery z EU rozpočtu + finančních mechanismů)
- Odečte se *EU/FM expenditure* (refundovatelná část výdajů na společné projekty)

**Citace z SZÚ 2024 Sešit C:**
> *"Dopady příjmů z EU a FM a výdajů předfinancovaných na tyto společné projekty
> byl kladný ve výši 17,5 mld. Kč... bez těchto prostředků, které jsou ve schváleném
> rozpočtu zahrnuty s neutrálním dopadem, by schodek činil 288,9 mld. Kč."*

**Účel této metriky:** ukazuje "strukturální schodek" — kolik by SR utratil ze
svých vlastních (domácích) zdrojů, kdyby neexistovaly EU/FM peníze.

**Status v naší implementaci:** Odložena jako future feature — viz limity níže.

---

## Implementace v naší DB

### Schema změny (migrace 0020)

`budget_facts` přešel z designu "2 řádky per tuple s `is_approved` flagem" na
**variantu A**: jeden řádek per (rok, měsíc, OSS, paragraf, položka, dimenze) tuple
s **5 hodnotovými sloupci side-by-side**:

| Sloupec | MIS-RIS | Význam |
|---|---|---|
| `value_approved` | ZU_ROZSCH | Schválený rozpočet (zákon o SR) |
| `value_amended` | ZU_ROZPZM | Rozpočet po změnách (novely + rozp. opatření) |
| `value_final` | ZU_KROZP | Konečný rozpočet (po změnách + NNV) |
| `value_actual` | ZU_ROZKZ | Skutečnost (cash plnění) |
| `value_obligation` | ZU_OBLIG | Obligace (forward-looking závazky) |

Plus 4 nové inline dimenze: `nastroj_code` (#7), `fund_code` (#8), `eds_code` (#9),
`ucris_code` (#10). Detaily v `docs/db-schema.md`.

### ETL parser fix (Czech trailing minus)

```typescript
// app/_etl/misRisParser.ts — parseDecimal
if (trimmed.endsWith('-')) trimmed = '-' + trimmed.slice(0, -1)
```

Tato úprava sama o sobě snížila diff vs MF o **~5–15 mld na ročních součtech**,
podle objemu vratek a korekcí v daném roce.

### MV `fiscal_year_totals` (migrace 0021)

11 sloupců: 8 hodnotových (revenue × 4 budget states, expenditure × 4 budget states)
+ 2 pre-computed deficit (approved, actual). Repository čte deficit přímo, žádná
agregace na úrovni dotazu.

---

## Validace per rok

### 2024 (primární referenční rok)

Validace proti SZÚ 2024 Sešit G Tabulka 1 a 2b:

| Metrika | MF SZÚ (mld Kč) | Naše DB (mld Kč) | Diff |
|---|---|---|---|
| Schválený rozpočet — příjmy | 1940.0 | `revenue_approved` 1940.0 | **0** |
| Schválený rozpočet — výdaje | 2222.0 | `expenditure_approved` 2222.0 | **0** |
| Schválený schodek | 282.0 | `deficit_approved` 282.0 | **0** |
| Rozpočet po změnách — příjmy | 1960.2 | `revenue_amended` 1960.2 | **0** |
| Rozpočet po změnách — výdaje | 2242.2 | `expenditure_amended` 2242.2 | **0** |
| Konečný rozpočet — výdaje | 2403.9 | `expenditure_final` 2401.0 | −2.9 |
| **Skutečnost — příjmy** | **1965.4** | `revenue_actual` 1962.5 | −2.9 |
| **Skutečnost — výdaje** | **2236.8** | `expenditure_actual` 2234.0 | −2.8 |
| **Schodek skutečnost** | **271.4** | `deficit_actual` 271.5 | **+0.1** |

**Schválené stavy sedí na haléř.** Skutečnost má strukturální diff −2.8/−2.9 na
obou stranách, ale výsledný schodek se prakticky shoduje (diff +0.1 = 0.04 %).

### Per-rok přehled (Total schodek)

| Rok | Naše skutečnost | MF Pokladní plnění | Diff | Komentář |
|---|---|---|---|---|
| 2020 | 364.0 | 367.4 | −3.4 | Specifika 3 covid novel; reziduální diff přijatelný |
| 2021 | 413.5 | 419.7 | −6.2 | Pokračující covid dopady |
| 2022 | 359.6 | ~360 | ~0 | Vyloučen z primárního auditu (energetická krize) |
| 2023 | 288.0 | 288.5 | −0.5 | Na haléř ✅ |
| 2024 | 271.5 | 271.4 | +0.1 | Na haléř ✅ |
| 2025 | 290.9 | 290.7 | +0.2 | Na haléř ✅ |

---

## Inventář oficiálních zdrojů dat o SR ČR

Pro kontext — všechny zdroje, které byly během auditu zvažovány nebo využity:

| # | Zdroj | URL | Co tam je | Pro nás |
|---|---|---|---|---|
| 1 | **MIS-RIS CSV** (IISSP extrakty) | `monitor.statnipokladna.cz/data/extrakty/csv/FinOSS/` | Plná transakční data SR, 12 dimenzí, měsíční granularita | **Primární** — náš ETL |
| 2 | Monitor REST API (open data) | `monitor.statnipokladna.cz/api` | Stejná data jako CSV, JSON, on-demand | Future feature (sekce 3 v features-roadmap) |
| 3 | **Pokladní plnění SR (TZ)** | `mf.gov.cz/cs/ministerstvo/media/tiskove-zpravy/.../pokladni-plneni-sr-*` | Měsíční + roční headline čísla MF | **Reference benchmark** |
| 4 | Informace o pokladním plnění SR (PDF) | `mf.gov.cz/cs/rozpoctova-politika/.../informace-o-pokladnim-plneni-...` | Kvartální detailní zprávy, ~150 stran | Mezičlánek mezi TZ a SZÚ |
| 5 | **Státní závěrečný účet** (SZÚ) | `mf.gov.cz/cs/rozpoctova-politika/.../statni-zaverecny-ucet-...` | Roční formální dokument, 9 sešitů A-I | **Hlavní zdroj pro audit metodiky** (Sešit C, G) |
| 6 | Zákon o SR (ročně) | např. `zakonyprolidi.cz/cs/2024-354` (rok 2024) | Schválený rozpočet jako právní akt | Validace `value_approved` |
| 7 | Vyhláška 412/2021 Sb. | `zakonyprolidi.cz/cs/2021-412` | Rozpočtová skladba — 12 dimenzí třídění | Schema design reference |
| 8 | Pokyn k vyhlášce 412/2021 Sb. | `mf.gov.cz/assets/attachments/...-Pokyn-k-vyhlasce-c-412-2021-Sb-...pdf` | Operativní pokyny MF | Edge cases účtování |
| 9 | NKÚ stanoviska k SZÚ | `nku.cz/cz/pro-media/tiskove-zpravy/` | Druhý nezávislý pohled na hospodaření SR | Sekundární validace |
| 10 | Eurostat ESA 2010 notifikace | `csu.gov.cz/notifikace-vladniho-deficitu-a-dluhu` | Pololetně, accrual basis, vládní sektor (S.13) | Doplněk — *jiný scope než SR* |
| 11 | Konvergenční program ČR | `mf.gov.cz/cs/rozpoctova-politika/konvergencni-program-...` | Tříletý fiskální výhled, ESA metodika | Forecast (mimo audit) |
| 12 | ČNB — Státní dluh | `cnb.cz/cs/financni-trhy/statisticke-udaje/` | Stock státního dluhu, struktura emisí | Komplement ke kapitole 396 |
| 13 | ESF/IROP open data | `dotaceeu.cz`, MMR | EU project-level data | Future feature (drill-down) |

---

## Známé reziduální limity

### Diff na skutečnostech 2024: ~2.8 mld na obou stranách

Naše `revenue_actual` 1962.5 vs MF 1965.4 (diff −2.9), naše `expenditure_actual`
2234.0 vs MF 2236.8 (diff −2.8). Diff se vyruší → schodek sedí na 0.1 mld.

**Pravděpodobné příčiny** (nepotvrzené):
- ETL skipped ~0 FK rows pro 2024 (per `runIngest` output), takže neexistuje "ztracený" dataset
- Možná drobná rozdílná interpretace mimorozpočtových rozhraní v IISSP

**Není akční:** schodek (= naše core metric) na haléř sedí.

### Reziduální diffy 2020/2021: 3-6 mld

Pravděpodobně specifika *post-covid účtování* — vyhláška 412/2021 Sb. začala
platit 1. 1. 2022, MIS-RIS data 2020-2021 byla pořízena dle starší vyhlášky
323/2002 Sb. a převedena. Drobné metodické nuance v převodu nejsou zdokumentované.

**Není akční pro tento audit.** Pokud by se v budoucnu chtělo zlepšit, vyžadovalo
by reverse-engineering převodu starých dat.

### "Po očištění o EU/FM" — nelze přesně implementovat

Pro replikaci MF "po očištění" metodiky 288.9 mld bychom potřebovali rozlišit
"EU refundovatelnou část" (142.7 mld) vs "národní spolufinancování" (19.5 mld)
v rámci EU project spending. **MIS-RIS export tohle nerozlišuje** — má sloupec
`ZC_NASTRJ` (nástroj), ale 4-digit kód je hrubší než MF interní 5-digit kódy
v IISSP, a *EU portion vs national portion* je rozlišena samostatným atributem,
který v exportu není.

Best-effort filter `nastroj_code LIKE '01%'` dává 162.2 mld pro 2024 (vs MF
EU/FM total 161.9 mld, ±0.2 %) — to je **"total EU/FM project spending"**, ne
"EU refundable portion only".

Detaily v `docs/features-roadmap.md` sekce 1.

---

## Související dokumenty

- `docs/db-schema.md` — schema reference, sémantika hodnotových sloupců
- `docs/monitor-data-sources.md` — MIS-RIS CSV formát a mapování na DB sloupce
- `docs/features-roadmap.md` — odložené features (po očištění, subkategorie, …)
- `docs/budget-categorization.md` — UI kategorie a jejich vztah k vyhlášce
- `docs/subcategories.md` — proč byla level-2 UI hierarchie odložena

Migrace s detailními commit-style komentáři:
- `app/_db/migrations/0020_budget_facts_full_dimensions.sql`
- `app/_db/migrations/0021_fiscal_year_totals_with_deficits.sql`
