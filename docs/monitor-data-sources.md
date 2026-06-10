# Monitor — datový zdroj

## URL pattern

```
https://monitor.statnipokladna.cz/data/extrakty/csv/FinOSS/{rok}_{měsíc}_Data_CSUIS_MISRIS.zip
```

- Zpoždění ~3 měsíce
- Každý měsíční ZIP obsahuje **všechny periody od ledna do daného měsíce** (není kumulativní — každý řádek = přírůstek za daný měsíc)
- Prosinec = kompletní roční data

---

## Soubory uvnitř ZIP

### `ZU01_*.csv` — jen 2024 (v 2025+ ZIPech chybí), ~830 KB

Nejmenší a nejčistší soubor. Agregát po ministerstvech a průřezových ukazatelích.

> **Pozor:** V 2025_12 ZIPu (ověřeno při A1 discovery) tento soubor **není přítomen** —
> ZIP obsahuje pouze `MIS-RIS`, `ZU-MIS-RIS` a `PU3241_05`. ZU01 byl pravděpodobně
> zařazený do ZU-MIS-RIS nebo přesunut do jiného balíčku. Při budoucí ZU01 pipeline
> ověřit, zda je dostupný v aktuálních datech.

| Sloupec     | Popis                                                |
| ----------- | ---------------------------------------------------- |
| `0FISCPER`  | Perioda (`2024001`–`2024012`)                        |
| `0FM_AREA`  | Kód ministerstva (`0313` = MPSV)                     |
| `ZC_PSUK`   | Průřezový ukazatel (`SU1010000000`, `SU5010000000`…) |
| `ZU_ROZSCH` | Schválený rozpočet (vyplněno jen v lednu)            |
| `ZU_ROZPZM` | Rozpočet po změnách                                  |
| `ZU_KROZP`  | Konečný rozpočet                                     |
| `ZU_ROZKZ`  | **Skutečnost** (první výskyt = KYF_0004)             |

⚠️ Sloupec `ZU_ROZKZ` se v hlavičce opakuje 3× (skutečnost, mimorozpočtové prostředky, čerpání nároků) — brát vždy **první výskyt**.

---

### `ZU-MIS-RIS_*.csv` — 2020–2023, 2025, ~15 MB

Stejná struktura jako ZU01, ale navíc obsahuje detail po organizacích.

| Sloupec     | Popis                                         |
| ----------- | --------------------------------------------- |
| `0FISCPER`  | Perioda                                       |
| `0FM_AREA`  | Kód ministerstva                              |
| `ZC_UCJED`  | Organizační jednotka                          |
| `ZC_ICO`    | IČO organizace                                |
| `ZFUNDS_CT` | Fond                                          |
| `ZC_PSUK`   | Průřezový ukazatel (stejné SU kódy jako ZU01) |
| `ZC_POLVK2` | Položka v2 — **vždy prázdná, nepoužívat**     |
| `ZU_ROZSCH` | Schválený rozpočet                            |
| `ZU_ROZPZM` | Rozpočet po změnách                           |
| `ZU_KROZP`  | Konečný rozpočet                              |
| `ZU_OBLIG`  | Obligace                                      |
| `ZU_ROZKZ`  | **Skutečnost** (jen jeden výskyt, čistější)   |

---

### `MIS-RIS-ZU_*.csv` — 2018–2019

Identická struktura jako ZU-MIS-RIS, jen jiný název souboru.

---

### `PU3241_05_*.csv` — 2020+, ~870 KB

Výdaje filtrované na průřezový ukazatel 3241. Obsahuje položkové kódy.

| Sloupec     | Popis                                                              |
| ----------- | ------------------------------------------------------------------ |
| `0FISCPER`  | Perioda                                                            |
| `0FM_AREA`  | Kód ministerstva                                                   |
| `ZC_ICO`    | IČO                                                                |
| `ZC_ZREUZ`  | Účelový znak                                                       |
| `ZC_LAU`    | Územní celek                                                       |
| `ZCMMT_ITM` | **Položka rozpočtové skladby** (5xxx = výdaje, 1xxx–4xxx = příjmy) |
| `ZU_ROZKZ`  | **Skutečnost**                                                     |

---

### `MIS-RIS_*.csv` — všechny roky, ~226 MB

Plná granularita — **všechny dimenze + 5 hodnotových stavů** vedle sebe. Toto je primární zdroj pro náš ETL (`app/_services/mis-ris-parser.service.ts`).

| Sloupec      | Použití v ETL                                                  | DB sloupec                                    |
| ------------ | -------------------------------------------------------------- | --------------------------------------------- |
| `0FISCPER`   | Required — rok a měsíc (7-digit `YYYYMMM`)                     | `fiscal_year`, `fiscal_month`                 |
| `ZC_UCJED`   | Required — kód organizační jednotky                            | `org_unit_id` (přes FK)                       |
| `ZC_ICO`     | Required — IČO (info-only, název OSS)                          | derivováno do `chapter_org_units.name_cs`     |
| `0FM_AREA`   | Required — kapitola (4-digit s leading zero)                   | `chapter` přes `chapter_org_units.chapter_id` |
| `ZFUNDS_CT`  | **Ignorováno** — redundantní s kapitolou (prefix = `0FM_AREA`) | —                                             |
| `ZCMMT_ITM`  | Required — položka (druhové)                                   | `item_id` (přes FK)                           |
| `0FUNC_AREA` | Required — paragraf (odvětvové)                                | `paragraph_id` (přes FK)                      |
| `ZC_FUND`    | Optional — doplňkové třídění (účelově sledovaný celek)         | `fund_code VARCHAR(20)`                       |
| `ZC_ZDROJA`  | Optional — podkladové třídění (zdroj)                          | `funding_source_code CHAR(1)`                 |
| `ZC_ZDROJ`   | **Ignorováno** — prostorové, pro SR data málo užitečné         | —                                             |
| `ZC_NASTRJ`  | Optional — **nástrojové třídění (EU/FM identifikace)**         | `nastroj_code VARCHAR(20)`                    |
| `ZC_NAST37`  | **Ignorováno** — dílčí analýza nástroje, niche                 | —                                             |
| `ZC_EDS`     | Optional — programové třídění (EDS/SMVS)                       | `eds_code VARCHAR(20)`                        |
| `ZC_UCRIS`   | Optional — účelové třídění (purpose)                           | `ucris_code VARCHAR(20)`                      |
| `ZC_PVS`     | **Ignorováno** — strukturní, niche                             | —                                             |
| `ZU_ROZSCH`  | Required — schválený rozpočet                                  | `value_approved NUMERIC(14,2)`                |
| `ZU_ROZPZM`  | Optional — rozpočet po změnách                                 | `value_amended NUMERIC(14,2)`                 |
| `ZU_KROZP`   | Optional — konečný rozpočet (po změnách + NNV)                 | `value_final NUMERIC(14,2)`                   |
| `ZU_OBLIG`   | Optional — obligace                                            | `value_obligation NUMERIC(14,2)`              |
| `ZU_ROZKZ`   | Required — skutečnost                                          | `value_actual NUMERIC(14,2)`                  |

> **2020–2023 soubory mají jen 16 sloupců** (chybí ZC_ZDROJA, ZC_NASTRJ, ZC_NAST37, ZC_FUND atd.). Parser je vyrobený robustně — chybějící optional sloupce → DB NULL.

> **Czech accounting trailing minus**: hodnoty v MIS-RIS mohou mít minus na konci (`14822772561.30-` = −14.8 mld) místo na začátku. Toto jsou typicky vratky, korekce a opravy. ETL parser to umí — viz `parseDecimal` v `app/_services/mis-ris-parser.service.ts`.

---

## Logika průřezových ukazatelů (ZC_PSUK)

Kódy `SU1xx0000000` a `SU5xx0000000` jsou **top-level, nepřekrývají se**:

| Pattern              | Typ                            | Příklad                                                |
| -------------------- | ------------------------------ | ------------------------------------------------------ |
| `SU1[0-9]{2}0000000` | Příjmy                         | `SU1010000000` (~952 mld), `SU1020000000` (~756 mld)   |
| `SU5[0-9]{2}0000000` | Výdaje                         | `SU5010000000` (~1 196 mld), `SU5020000000` (~360 mld) |
| `SU1[0-9]{2}[^0]…`   | Sub-kategorie příjmů           | `SU1020010000` — **nesčítat s top-level**              |
| `SU5[0-9]{2}[^0]…`   | Sub-kategorie výdajů           | `SU5010010000` — **nesčítat s top-level**              |
| `PU10…`              | Specifické průřezové ukazatele | nelze jednoduše agregovat                              |

---

## Doporučení — který soubor pro co

| Účel                        | Soubor                         | Klíčové sloupce                       |
| --------------------------- | ------------------------------ | ------------------------------------- |
| Roční příjmy/výdaje/schodek | ZU01 / ZU-MIS-RIS / MIS-RIS-ZU | `ZC_PSUK` + `ZU_ROZKZ`                |
| Schválený rozpočet          | ZU01 / ZU-MIS-RIS (jen leden)  | `ZC_PSUK` + `ZU_ROZSCH`               |
| Výdaje po ministerstvech    | ZU01 / ZU-MIS-RIS              | `0FM_AREA` + `ZC_PSUK` + `ZU_ROZKZ`   |
| Výdaje po položkách (ETL)   | MIS-RIS                        | `ZCMMT_ITM` + `0FM_AREA` + `ZU_ROZKZ` |
| Příjmy po položkách (ETL)   | MIS-RIS                        | `ZCMMT_ITM` (1xxx–4xxx) + `ZU_ROZKZ`  |
