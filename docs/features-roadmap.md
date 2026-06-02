# Features roadmap

Seznam **odložených features** — věci, které během práce vyplynuly jako *užitečné, ale ne kritické* pro aktuální MVP. Každá má dost kontextu, aby se k ní šlo později vrátit bez ztráty paměti.

Formát: každá feature obsahuje (a) motivaci, (b) technické požadavky, (c) odhad práce, (d) blokátory pokud nějaké jsou.

---

## 1. Schodek SR po očištění o EU/FM (druhá metodika)

### Motivace

MF reportuje schodek SR **ve dvou metodikách vedle sebe** ve všech oficiálních dokumentech (Pokladní plnění TZ, Sešit C Závěrečného účtu):

| Metodika | 2024 hodnota | Co měří |
|---|---|---|
| **Total schodek SR** | 271.4 mld | Skutečný cash deficit za rok (headline) |
| **Schodek po očištění o EU/FM** | 288.9 mld | "Kolik by byl schodek, kdyby neexistovaly EU peníze" — ukazuje strukturální deficit financovaný z domácích zdrojů |

Aplikace dnes ukazuje **jen first metric**. Druhá by:
- Konzistentně s MF reportingem
- Edukativně — uživatel vidí roli EU peněz v SR
- Politicky relevantní — "po očištění" se cituje v ekonomické debatě (kolik bychom utratili sami za sebe)

### Co to vyžaduje technicky

DB schéma už je **připravené** — má sloupec `nastroj_code` (#7 nástrojové třídění z vyhlášky 412/2021 Sb.) v `budget_facts`. Co chybí:

1. **Lookup table `nastroj_codes`** — klasifikace každého kódu jako EU OP / NPO / SZP / FM / domestic.
   ```sql
   CREATE TABLE nastroj_codes (
     code      VARCHAR(20) PRIMARY KEY,
     category  VARCHAR(20) NOT NULL,
     name_cs   TEXT NOT NULL,
     is_eu_fm  BOOLEAN NOT NULL
   );
   ```
2. **Seed klasifikace** — manuální mapping cca 80 distinct `nastroj_code` hodnot z naší DB na výše uvedené kategorie. Pomocí cross-referencing s MF Sešit C Tabulkou 78.
3. **Repository funkce** `getYearTotalsCleanedEuFm(year)` — JOIN na lookup, vrátí celkovou EU/FM výši + cleaned deficit.
4. **UI** — buď přepínač "ukaž po očištění", nebo dva paralelní pruhy v grafu.

### Blokátor: přesné MF mapping

MF Sešit C Tabulka 78 používá **5-digit nástrojové kódy** (např. `14600` = OP Doprava CF 2021+, `17000` = NPO RRF). MIS-RIS CSV ovšem exportuje **4-digit kódy** (např. `0146`, `0170`). Vztah mezi nimi:
- **Empirický:** sum 01xx v naší DB pro 2024 = 162.2 mld → matches MF "EU+ČR programy + SZP" 161.9 mld (±0.2 %)
- **Per-program:** přesné 1:1 mapping není veřejně publikované. MF interní číselník nástrojů je v IISSP portálu jen pro registrované uživatele.

**Důsledek:** lze identifikovat "vše co je EU/FM tagováno" (~162 mld), ale **nelze přesně oddělit "EU refundovatelnou část" (142.7 mld) od "národního spolufinancování" (19.5 mld)**. Pro přesný match MF "po očištění" 288.9 mld by bylo potřeba toto rozlišení — vyžaduje:
- (a) Buď kontakt MF metodického oddělení o jejich číselník
- (b) Nebo přidat další MIS-RIS sloupec (pravděpodobně neexistuje s touto granularitou v exportu)

### Odhad práce

- **Best-effort 01xx classification** (přesnost ±20 mld vs MF "po očištění"): **2-3 hodiny**
- **Přesná MF-matching klasifikace**: dependentní na získání MF číselníku — **unknown**

### Status

**Odložena.** Audit goal byl matching MF *Total schodek*, který je splněn (2024 diff +0.1 mld). "Po očištění" je doplňková analytika, ne core feature.

---

## 2. Druhá úroveň UI kategorizace (subkategorie)

Detailní rozbor v `docs/subcategories.md`. Stručně:

- Aplikace má dnes 2 úrovně: 11 výdajových UI kategorií → 528 paragrafů
- Druhá úroveň by byla **most**: ~4-7 zakurátorovaných subkategorií per kategorie
- Pilot na `socialProtection` proběhl OK, pilot na `education` odhalil zásadní data-shape problém (~73 % výdajů na vzdělávání tečou přes "Ostatní záležitosti vzdělávání" jako transfery krajům)

**Status:** Odložena, schema připravené (`categories.parent_id`, `category_paragraph_map`).

---

## 3. Monitor REST API integrace (live data bez 3-měsíčního zpoždění)

### Motivace

Aktuální ETL stahuje měsíční CSV extrakt z Monitoru SP s ~3-měsíčním zpožděním (prosincová data jsou v únoru). Monitor SP má **REST API** (`monitor.statnipokladna.cz/api`) s aktuálnějšími daty — JSON odpovědi vhodné pro **on-demand UI queries**.

### Use case

- "Saldo SR za poslední měsíc" badge v UI — bez čekání na další ETL cycle
- Real-time fiscal observability — užitečné v krizových obdobích

### Co to vyžaduje

- REST klient pro Monitor API (existující `monitorClient.ts` rozšířit)
- Cache layer (Redis nebo in-memory) — API má rate limity
- API endpoint v Next.js app pro UI consumption

### Odhad práce

~1-2 dny vč. UI prezentace.

### Status

Odložena. MVP používá batch ETL, který stačí. Live data má smysl až s aktivními uživateli.

---

## 4. Forward-looking fiscal commitments (využití value_obligation)

### Motivace

DB ukládá `value_obligation` (ZU_OBLIG z MIS-RIS) = **podepsané závazky státu, dosud nezaplacené**. Toto je forward-looking metrika důležitá pro:
- Credit rating analytici (Moody's, S&P, Fitch sledují fiscal commitments)
- Investoři do CZK sovereign debt
- Fiscal advisory consulting firmy

### Use case

- "Pipeline výdajů na příští 3-5 let z aktuálního rozpočtu" graf
- Per-kapitola: "kolik už je zazávazkováno, kolik volné kapacity"
- Cross-year forecast

### Co to vyžaduje

- Repository functions pro `value_obligation` aggregations
- Time-series UI komponenta s rolling commitment window
- (Volitelně) Premium tier — komerční hodnota viz docs/commercial-roadmap.md (TODO)

### Status

Odložena. Datová vrstva připravená (sloupec v `budget_facts`), čeká na use case definition.

---

## 5. Topické cross-cuts (Pomoc Ukrajině, Covid, Povodně 2024)

### Motivace

DB ukládá `fund_code` (ZC_FUND, doplňkové třídění #8 z vyhlášky 412/2021 Sb.). Toto identifikuje **účelově sledované celky** — specifické topické okruhy napříč kapitolami:
- Pomoc Ukrajině (válka 2022+)
- Covid kompenzace 2020-22 (specifické fondy)
- Povodňové škody 2024
- Energetická krize 2022-23

V Sešitu G Tabulce 16 MF reportuje "Přímé peněžní dopady válečného konfliktu na Ukrajině" — exact data, které lze v naší DB reprodukovat.

### Use case

Topické agregace často citované v médiích → potenciálně viditelná feature pro PR / public engagement.

### Co to vyžaduje

- Klasifikace `fund_code` hodnot na topické bucketsy
- UI sekce "Aktuální topické výdaje státu"
- Refresh logic — topiky se v čase mění

### Status

Odložena. Připravená data (`fund_code` sloupec), čeká na UI design.

---

## 6. Programový drill-down (využití eds_code)

### Motivace

`eds_code` (ZC_EDS) identifikuje **konkrétní programy v EDS/SMVS** — např. "Modernizace ZŠ 2021+", "Národní program zdraví", "Operační program Doprava 2021+ — projekt rekonstrukce D1". Granulárnější než vyhláškové paragrafy.

### Use case

"Kam šly peníze na vzdělávání? — z 263 mld pro 2024 šlo do programu 'Modernizace ZŠ' 8.4 mld, do 'NPO Adaptace školních programů' 4.0 mld..."

### Status

Odložena. Připravená data, čeká na UI design.

---

## Cross-reference

Datový základ pro features 1, 3, 4, 5, 6 byl vybudován v migracích **0020 + 0021** (full MIS-RIS column load). Features lze přidávat **bez dalšího reseed ETL** — jen nové repository funkce + UI komponenty.

Pro feature 2 (subkategorie) připravený schema `categories.parent_id` od `0000_initial_schema`.
