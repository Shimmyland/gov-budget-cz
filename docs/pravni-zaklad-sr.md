# Právní základ a datové zdroje státního rozpočtu ČR

Tento dokument inventarizuje prameny, ze kterých státní rozpočet (SR) České republiky právně vychází a ze kterých se odvozují data o jeho plnění. Účel je čistě referenční: poskytnout přehled „co se kde řeší" pro práci na projektu gov-budget-cz, ne nahradit odbornou literaturu ani komentář k jednotlivým předpisům.

Každá položka obsahuje krátký popis předmětu úpravy a odkaz na primární text. Detailní práce s konkrétními paragrafy je mimo rozsah tohoto dokumentu — pro mapování rozpočtové skladby na UI kategorie viz [`budget-categorization.md`](budget-categorization.md), pro DB schéma [`db-schema.md`](db-schema.md), pro popis vstupních CSV souborů [`monitor-data-sources.md`](monitor-data-sources.md), pro výpočet schodku [`deficit-methodology.md`](deficit-methodology.md).

## §1 Hierarchie pramenů

Vertikála od ústavního rámce po konkrétní datové výstupy:

```
Ústava ČR (úst. zák. č. 1/1993 Sb.) / Listina (usn. č. 2/1993 Sb.)
    └── kdo schvaluje SR, kdo ukládá daně
           │
           ▼
Zákony (rámcové, trvalé)
    ├── č. 218/2000 Sb. — rozpočtová pravidla (hlavní)
    ├── č. 23/2017 Sb. — rozpočtová odpovědnost
    ├── č. 166/1993 Sb. — NKÚ
    ├── č. 320/2001 Sb. — finanční kontrola
    └── č. 563/1991 Sb. — účetnictví
           │
           ▼
Roční zákony o státním rozpočtu
    └── jeden zákon pro každý rozpočtový rok
        (např. zákon o státním rozpočtu na rok 2024)
           │
           ▼
Prováděcí vyhlášky
    ├── č. 412/2021 Sb. — rozpočtová skladba (od 2022)
    ├── č. 419/2001 Sb. — rozsah a termíny předkládání údajů
    ├── č. 5/2014 Sb. — FIN výkazy
    └── č. 367/2015 Sb. — zásady zaúčtování
           │
           ▼
Metodika MF
    └── číselníky, pokyny pro IISSP / RIS
           │
           ▼
Datové výstupy
    ├── MONITOR / MIS-RIS CSV — operativní data plnění
    ├── Závěrečný účet SR — autoritativní souhrn za uplynulý rok
    └── Pokladní plnění SR — čtvrtletní zprávy MF
```

Vedle této vnitrostátní vertikály existuje paralelní **EU reportovací linie**, která pracuje s vlastními klasifikacemi:

```
Nařízení EU 549/2013 — ESA 2010 (národní účty)
    ├── COFOG — funkční třídění výdajů
    ├── GFS 2014 — IMF government finance statistics
    └── EDP — Excessive Deficit Procedure
           │
           ▼
Eurostat (transmisse z ČSÚ a MF)
```

Důsledek pro projekt: **„český schodek" (dle zák. č. 218/2000 Sb.) a „EDP schodek" (dle ESA 2010) jsou různá čísla** — vznikají odlišnou metodikou a obecně si nejsou rovny. Detailněji viz §7.

Následující sekce jdou v tomto pořadí shora dolů.

## §2 Ústavní rámec

Dva dokumenty ústavního pořádku, ze kterých se odvíjí celá soustava níže — kdo schvaluje SR a podle čeho lze vůbec ukládat daně.

### 2.1 Ústava ČR (ústavní zákon č. 1/1993 Sb.), čl. 42

> (1) Návrh zákona o státním rozpočtu a návrh státního závěrečného účtu podává vláda.
> (2) Tyto návrhy projednává na veřejné schůzi a usnáší se o nich jen Poslanecká sněmovna.

Důsledky: SR a SZÚ jsou výhradně v působnosti Poslanecké sněmovny (Senát se k nim nevyjadřuje), návrh vždy podává vláda. Z čl. 42 vyplývá i forma — SR musí být schválen zákonem, ne usnesením.

### 2.2 Listina základních práv a svobod (usn. č. 2/1993 Sb.), čl. 11 odst. 5

> Daně a poplatky lze ukládat jen na základě zákona.

Důsledky: žádný podzákonný předpis (vyhláška, nařízení vlády) nemůže ukládat daně či poplatky. Definuje příjmovou stranu SR jako oblast vyhrazenou zákonu.

## §3 Zákony

Trvalé, rámcové zákony, které definují co je státní rozpočet, jak vzniká a jak se kontroluje. Tvoří právní podklad pro roční zákony o SR (§4) i pro prováděcí vyhlášky (§5).

### 3.1 Zákon č. 218/2000 Sb., o rozpočtových pravidlech (rozpočtová pravidla)

Hlavní zákon upravující rozpočtový systém státu. Definuje státní rozpočet a jeho strukturu (kapitoly, organizační složky státu, příspěvkové organizace, státní fondy), rozpočtový proces (sestavení návrhu, schvalování, plnění, závěrečný účet), pravidla pro rozpočtová opatření v průběhu roku, rozpočtové provizorium a vztah SR ke státním finančním aktivům a Národnímu fondu. Obsahuje rovněž zákonné zmocnění, podle kterého MF vydává prováděcí vyhlášky — vč. vyhlášky o rozpočtové skladbě (§5).

### 3.2 Zákon č. 23/2017 Sb., o pravidlech rozpočtové odpovědnosti

Stanoví fiskální pravidla pro hospodaření veřejných institucí ČR — zejména pravidlo dluhové brzdy (limit státního dluhu vázaný na HDP), pravidla pro výdajový rámec a střednědobý výhled. Zřizuje Národní rozpočtovou radu (NRR) jako nezávislý dohledový orgán. Implementuje do českého práva požadavky unijního fiskálního rámce (mj. směrnice Rady 2011/85/EU); definice schodku zde vychází z ESA 2010, nikoli z pojmu schodku v zák. č. 218/2000 Sb.

### 3.3 Zákon č. 166/1993 Sb., o Nejvyšším kontrolním úřadu

Zřizuje a upravuje působnost NKÚ — nezávislého kontrolního orgánu, který kontroluje hospodaření se státním majetkem a plnění SR. Výstupem jsou kontrolní závěry k jednotlivým akcím a každoroční stanovisko k návrhu státního závěrečného účtu.

### 3.4 Zákon č. 320/2001 Sb., o finanční kontrole / zákon č. 231/2025 Sb.

- **č. 320/2001 Sb.** — Zákon o finanční kontrole ve veřejné správě. Upravuje vnitřní řídicí a kontrolní systémy u organizačních složek státu, územních samosprávných celků a dalších veřejnoprávních subjektů. Účinný do 31. 12. 2026.
- **č. 231/2025 Sb.** — Zákon o řízení a kontrole veřejných financí. Účinný od 1. 1. 2027, nahrazuje 320/2001 Sb. (reforma systému vnitřní kontroly).

### 3.5 Zákon č. 563/1991 Sb., o účetnictví

Obecný zákon upravující účetnictví všech účetních jednotek včetně organizačních složek státu, příspěvkových organizací a územních samospráv. Pro veřejný sektor je doplněn prováděcí vyhláškou č. 410/2009 Sb. a Českými účetními standardy pro veřejný sektor.

### 3.6 Zákon č. 250/2000 Sb., o rozpočtových pravidlech územních rozpočtů (kontext)

Analog zákona č. 218/2000 Sb. pro územní úroveň — upravuje rozpočtová pravidla obcí, krajů a dobrovolných svazků obcí. Není přímo součástí právního rámce SR, ale tvoří paralelní systém pro územní rozpočty, jejichž data se objevují ve stejných datových zdrojích MF (MIS-RIS, MONITOR) jako data za SR.

## §4 Roční zákony o státním rozpočtu

Každý rozpočtový rok je vyhlašován samostatným zákonem o státním rozpočtu. Návrh předkládá vláda, schvaluje Poslanecká sněmovna (čl. 42 Ústavy). Zákon obsahuje celkovou výši příjmů, výdajů a salda SR, rozdělení na kapitoly a programy, limit počtu zaměstnanců v jednotlivých kapitolách, podmínky pro státní záruky a další specifické úpravy pro daný rok; podrobné rozpisy jsou v přílohách. Pokud zákon není schválen do začátku roku, hospodaří SR podle pravidel rozpočtového provizoria (§ 9 zákona č. 218/2000 Sb.).

V průběhu roku se zákon zpravidla mění jednou nebo více novelami (typicky úprava výdajových limitů, reakce na ekonomický vývoj).

### 4.1 Tabulka 2018–2026

| Rok  | Zákon         | Pozn.                                              |
| ---- | ------------- | -------------------------------------------------- |
| 2018 | 474/2017 Sb.  |                                                    |
| 2019 | 336/2018 Sb.  |                                                    |
| 2020 | 355/2019 Sb.  | Novela 129/2020 Sb. (covid)                        |
| 2021 | 600/2020 Sb.  | Novela 92/2021 Sb.                                 |
| 2022 | 57/2022 Sb.   | Účinnost od 19. 3. 2022, do té doby rozpočtové provizorium. Novela 344/2022 Sb. |
| 2023 | 449/2022 Sb.  |                                                    |
| 2024 | 433/2023 Sb.  | Novela 294/2024 Sb.                                |
| 2025 | 434/2024 Sb.  |                                                    |
| 2026 | 38/2026 Sb.   | Účinnost od 21. 3. 2026, do té doby rozpočtové provizorium |

Plný název každého zákona má formát „Zákon č. XXX/YYYY Sb., o státním rozpočtu České republiky na rok YYYY+1". Aktuální znění a přílohy viz `zakonyprolidi.cz/cs/{rok}-{číslo}` nebo `e-sbirka.cz/sb/{rok}/{číslo}`.

## §5 Prováděcí vyhlášky

Vyhlášky vydané podle zmocnění v zákoně č. 218/2000 Sb. a souvisejících zákonech. Definují technické provedení — jak se rozpočet klasifikuje, v jakém formátu se vykazuje, kdy a komu se předkládá.

### 5.1 Vyhláška č. 412/2021 Sb., o rozpočtové skladbě

Účinná od 1. 1. 2022. Stanoví závaznou klasifikaci rozpočtových operací (celkem 12 dimenzí třídění — druhové, odvětvové, konsolidační, zdrojové, prostorové, programové, účelové, transferové, strukturní, dokladové, nástrojové a doplňkové) pro státní rozpočet, státní fondy, územní rozpočty a další subjekty veřejných financí. Nahradila vyhlášku č. 323/2002 Sb. a rozšířila skladbu o nové dimenze. Jádrový předpis pro interpretaci dat MIS-RIS od roku 2022.

Detail mapování na UI kategorie aplikace viz [`budget-categorization.md`](budget-categorization.md), použití v DB schématu viz [`db-schema.md`](db-schema.md).

### 5.2 Vyhláška č. 323/2002 Sb., o rozpočtové skladbě (zrušená)

Vydaná Ministerstvem financí, účinná od 1. 1. 2003 do 31. 12. 2021. Předchůdce vyhlášky 412/2021 Sb., relevantní pro interpretaci historických dat před rokem 2022. Pracovala s užším počtem dimenzí třídění než navazující vyhláška.

### 5.3 Vyhláška č. 419/2001 Sb., o předkládání údajů pro vypracování návrhu státního závěrečného účtu

Definuje, které subjekty (kapitoly SR, státní fondy, územní rozpočty a další), jaké údaje a v jakých termínech předkládají Ministerstvu financí jako podklady pro sestavení návrhu státního závěrečného účtu. Vymezuje proces přípravy ZÚ jako dokumentu.

### 5.4 Vyhláška č. 5/2014 Sb., o způsobu, termínech a rozsahu údajů předkládaných pro hodnocení plnění státního rozpočtu

Plný název: „o způsobu, termínech a rozsahu údajů předkládaných pro hodnocení plnění státního rozpočtu, rozpočtů státních fondů, rozpočtů územních samosprávných celků a rozpočtů dobrovolných svazků obcí". Vymezuje obsah a strukturu výkazů FIN, kterými subjekty veřejných rozpočtů reportují MF stav svého hospodaření v průběhu roku. Výstupy z této pipeline tvoří operativní data v IISSP / MONITORu.

Popis konkrétních CSV souborů, které z této pipeline pocházejí, viz [`monitor-data-sources.md`](monitor-data-sources.md).

### 5.5 Vyhlášky o finančním vypořádání: č. 367/2015 Sb. a č. 433/2024 Sb.

Stanoví zásady a lhůty finančního vypořádání vztahů se státním rozpočtem, státními finančními aktivy a Národním fondem — tj. proces, při kterém příjemci dotací po skončení rozpočtového roku vracejí nevyčerpané prostředky zpět do SR nebo prokazují jejich oprávněné použití.

- **č. 367/2015 Sb.** — účinná od 1. 1. 2016 do 31. 12. 2024 (zrušena vyhláškou 433/2024 Sb.)
- **č. 433/2024 Sb.** — účinná od 1. 1. 2025, nahradila 367/2015 Sb. ve věcně shodném rozsahu

### 5.6 Mini-tabulka: rok → účinná vyhláška o rozpočtové skladbě

| Rok          | Vyhláška o rozpočtové skladbě                        |
| ------------ | ---------------------------------------------------- |
| 2010 – 2021  | č. 323/2002 Sb. (v platném znění daného roku)        |
| 2022 – dnes  | č. 412/2021 Sb. (v platném znění daného roku)        |

Pro období před rokem 2003 platily starší vyhlášky MF, které jsou mimo scope tohoto dokumentu.

## §6 Metodika MF

Vedle závazných předpisů (§3 – §5) publikuje Ministerstvo financí provozní materiály, které upřesňují aplikaci jednotlivých ustanovení v praxi — číselníky, výkladové pokyny a interní metodiky systémů státní pokladny. Tyto materiály nejsou samy o sobě právně závazné, ale fakticky určují podobu reportovaných dat.

Pro tento projekt jsou nejrelevantnější:

- **Číselníky MF** — strojově čitelné seznamy kapitol SR, paragrafů funkčního třídění, položek druhového třídění a dalších dimenzí dle vyhlášky 412/2021 Sb. Distribuované prostřednictvím MONITORu (§8.1) a NKOD (§8.7).
- **Pokyn k vyhlášce č. 412/2021 Sb.** — interpretační dokument MF k vyhlášce o rozpočtové skladbě (operativní pokyny pro účtování edge case'ů). Aktuální verze zveřejněna na `mf.gov.cz`.
- **Provozní pokyny k IISSP / RIS** — technická dokumentace pro subjekty veřejných rozpočtů reportující data do státní pokladny. Specifikuje formáty výkazů, validační pravidla a termíny.

## §7 Mezinárodní klasifikace a EU reporting

Paralelně k vnitrostátní vertikále existuje druhá reportovací linie — povinné předávání dat o veřejných financích ČR do EU. Pracuje s jinými klasifikacemi a jinou metodikou než česká rozpočtová skladba, proto produkuje **jiná čísla** než SZÚ.

### 7.1 ESA 2010 — European System of National and Regional Accounts

Závazný metodologický rámec pro národní účty v EU, vydaný nařízením Evropského parlamentu a Rady (EU) č. 549/2013. Definuje sektor vládních institucí (S.13 — „general government"), pravidla pro účtování příjmů a výdajů (akruální princip, tj. časové rozlišení podle období vzniku, nikoli okamžiku platby) a metriky agregátního schodku a dluhu. ČR jej implementuje v zákoně č. 23/2017 Sb. o pravidlech rozpočtové odpovědnosti.

### 7.2 COFOG — Classification of the Functions of Government

Funkční klasifikace výdajů vlády podle UN, převzatá Eurostatem. Členění do 10 hlavních funkcí (`01` Všeobecné veřejné služby, `02` Obrana, … `10` Sociální věci). Pojmově blízká českému odvětvovému (funkčnímu) třídění z vyhlášky 412/2021 Sb., ale **není s ním 1:1 totožná** — agregační logika i hranice jednotlivých skupin se liší. Pro ČR transmisse COFOG dat zajišťuje ČSÚ.

### 7.3 GFS 2014 — Government Finance Statistics Manual (IMF)

Mezinárodní metodika MMF pro statistiku vládních financí, harmonizovaná s ESA 2010 a SNA 2008. ČR formálně reportuje primárně do ESA 2010, GFS 2014 je relevantní pro mezinárodní srovnání mimo EU kontext.

### 7.4 EDP — Excessive Deficit Procedure

Procedura zavedená Smlouvou o fungování EU (čl. 126) a tzv. Maastrichtskými kritérii: schodek vládního sektoru ≤ 3 % HDP a dluh vládního sektoru ≤ 60 % HDP. ČR čtvrtletně předkládá Eurostatu **EDP notifikaci** s aktualizovanými hodnotami podle ESA 2010.

### 7.5 Proč „český schodek" ≠ „EDP schodek"

Dvě hlavní příčiny rozdílu:

1. **Pokrytí** — český schodek dle zákona č. 218/2000 Sb. je schodek **státního rozpočtu** (SR). EDP schodek je schodek sektoru **vládních institucí (S.13)**, tj. SR + státní fondy + zdravotní pojišťovny + obce + kraje + většina příspěvkových organizací a veřejných vysokých škol.
2. **Princip účtování** — český schodek se reportuje na **hotovostním (cash) základě** (kdy peníze fakticky odešly/přišly). EDP schodek je na **akruálním základě** (kdy závazek vznikl, bez ohledu na platbu).

Důsledek: agregát „schodek veřejných financí ČR" z médií (citovaný k 3 % HDP) je obvykle EDP číslo, zatímco aplikace gov-budget-cz pracuje s českým schodkem SR. Pro detailní rozbor výpočtu schodku v projektu viz [`deficit-methodology.md`](deficit-methodology.md).

## §8 Datové zdroje

Konkrétní výstupy, ze kterých projekt gov-budget-cz čerpá nebo proti nimž ověřuje vlastní data.

### 8.1 MONITOR / Státní pokladna

`monitor.statnipokladna.gov.cz`. Veřejný portál MF prezentující agregovaná data o hospodaření veřejných rozpočtů. Zdrojem jsou systémy IISSP (Integrovaný informační systém státní pokladny) a CSÚIS (Centrální systém účetních informací státu). Publikuje měsíční CSV extrakty MIS-RIS (Manažerský informační systém — Rozpočtový informační systém) i REST API se stejnými daty v JSON. Primární datový zdroj aplikace; detail formátů viz [`monitor-data-sources.md`](monitor-data-sources.md).

### 8.2 Státní závěrečný účet (SZÚ)

Autoritativní souhrnný dokument o plnění SR za uplynulý rok. Vláda jej předkládá Poslanecké sněmovně podle § 30 zákona č. 218/2000 Sb. Obsahuje textovou hodnotící zprávu, tabulkové přílohy s podrobným členěním příjmů, výdajů a salda i stanovisko NKÚ. Publikuje MF v sekci `mfcr.cz` „Státní rozpočet / Plnění státního rozpočtu". V projektu se používá jako ground truth pro validaci ročních agregátů.

### 8.3 Pokladní plnění SR (čtvrtletní)

Operativní čtvrtletní zprávy MF o plnění SR doplněné tiskovými zprávami a tabulkovými přílohami. Vycházejí dříve než SZÚ a slouží jako průběžná kontrola.

### 8.4 Nejvyšší kontrolní úřad (NKÚ)

`nku.gov.cz`. Publikuje kontrolní závěry k jednotlivým kontrolním akcím, výroční zprávy o své činnosti a každoroční stanovisko k návrhu SZÚ. Externí pohled na kvalitu reportingu MF.

### 8.5 Eurostat

`ec.europa.eu/eurostat`. Konsoliduje národní data v rámci ESA 2010 (mj. EDP notifikace, COFOG transmisse). Pro ČR transmisse zajišťuje ČSÚ ve spolupráci s MF. Slouží k mezinárodnímu srovnání a k pochopení rozdílů mezi českým a EU pojetím schodku (viz §7).

### 8.6 ARES (Administrativní registr ekonomických subjektů)

`ares.gov.cz`. Registr MF obsahující identifikační údaje všech ekonomických subjektů včetně organizačních složek státu, příspěvkových organizací a státních fondů. Referenční zdroj pro mapování IČO → název organizace.

### 8.7 Otevřená data ČR

`data.gov.cz` — Národní katalog otevřených dat (NKOD). Centrální katalog datových sad publikovaných státními úřady; obsahuje mj. číselníky MF a doplňková metadata. V projektu sekundární zdroj.

## §9 Reference

### 9.1 Sbírky zákonů a vyhlášek

- **e-Sbírka** — `e-sbirka.cz`. Oficiální portál Ministerstva vnitra; primární zdroj pro autoritativní znění.
- **Zákony pro lidi** — `zakonyprolidi.cz`. Vyhledávání s lepší podporou historických znění a metadat (datum vyhlášení / účinnosti). Provozováno AION CS.

### 9.2 Ministerstvo financí

- **MF — Státní rozpočet** — `mfcr.cz/cs/rozpoctova-politika/statni-rozpocet`. SZÚ, čtvrtletní pokladní plnění, návrhy SR, tiskové zprávy.
- **MONITOR / Státní pokladna** — `monitor.statnipokladna.gov.cz`. CSV extrakty MIS-RIS, REST API, číselníky.
- **ARES** — `ares.gov.cz`. Registr ekonomických subjektů.

### 9.3 Kontrolní a nezávislé orgány

- **Nejvyšší kontrolní úřad** — `nku.gov.cz`. Kontrolní závěry, stanoviska k SZÚ.
- **Národní rozpočtová rada** — `rozpoctovarada.cz`. Stanoviska a analýzy k fiskálnímu rámci.

### 9.4 EU a mezinárodní

- **Eurostat** — `ec.europa.eu/eurostat`. EDP notifikace, COFOG transmisse, ESA 2010 metadata.
- **EUR-Lex** — `eur-lex.europa.eu`. Primární zdroj evropské legislativy (např. nařízení 549/2013 o ESA 2010).
- **UN Statistics — COFOG** — `unstats.un.org/unsd/classifications/Family/Detail/4`. Oficiální specifikace COFOG.
- **IMF GFSM 2014** — `imf.org/external/pubs/ft/gfs/manual/2014`. Government Finance Statistics Manual.

### 9.5 Praktická poznámka k fetchování

Server `zakonyprolidi.cz` vrací při default User-Agent (např. `curl/8.x`) HTTP 403. Pro automatizovaný fetch je nutné nastavit běžný browser UA:

```bash
curl -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36" \
     "https://www.zakonyprolidi.cz/cs/{rok}-{číslo}"
```

Portál `e-sbirka.cz` na default UA odpovídá normálně. Stránky MONITORu (`monitor.statnipokladna.gov.cz`) také nepotřebují speciální UA.
