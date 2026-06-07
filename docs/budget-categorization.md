# Plán: Kategorizace státního rozpočtu ČR pro laickou veřejnost

## Kontext

Aplikace gov-budget-cz zobrazuje data státního rozpočtu ČR a má ambici napojit se na reálná data
z Monitor Státní Pokladny. Cílem je vybrat kategorizaci výdajů/příjmů, která bude:

1. Věcně správná (odpovídá reálné struktuře českého státního rozpočtu)
2. Srozumitelná laické veřejnosti
3. Technicky implementovatelná z dostupných datových zdrojů

---

## Klíčový poznatek: Kapitoly NEJSOU vhodné jako primární pohled

Český státní rozpočet má 3 dimenze třídění:

| Dimenze                                                           | Co popisuje                                                                            | Vhodné pro laiky? |
| ----------------------------------------------------------------- | -------------------------------------------------------------------------------------- | ----------------- |
| **Kapitolové (odpovědnostní) třídění** (47 kapitol v SR 2025)     | KDO peníze spravuje (ministerstvo/úřad)                                                | ❌ Ne – primárně  |
| **Druhové třídění** (třída/seskupení/položka)                     | CO se za ně kupuje a jaká je ekonomická povaha (platy, investice, dávky, transfery...) | ❌ Ne – primárně  |
| **Odvětvové (funkční) třídění** (skupina/oddíl/pododdíl/paragraf) | NA CO se peníze využívají (vzdělání, obrana...)                                        | ✅ Ano            |

> Rozpočtová skladba má dle vyhlášky **412/2021 Sb.** ve skutečnosti **12 dimenzí
> třídění** — výše uvedené tři jsou hlavní, ostatní jsou technické (konsolidační,
> programové, účelové, …). Viz sekce _Rozpočtová skladba — kompletní přehled_.

**Proč kapitoly nestačí jako hlavní pohled:**

- Kapitola 313 (MPSV) = sociální věci a zaměstnanost a sociální péče – laik nerozlišuje
- Kapitola "Všeobecná pokladní správa" – veřejnost neví co to je
- Jedna agenda (výzkum) je roztažená přes více kapitol

**Kapitoly ale využít jako sekundární pohled** – viz sekce níže.

→ **Současná aplikace to dělá správně.** Kategorie jako socialWelfare, healthcare, education...
jsou funkčním tříděním – správný přístup, jen je potřeba aktualizovat/zpřesnit.

---

## Datový model: tři oficiální dimenze plus jedna vlastní

Z 12 dimenzí třídění dle vyhlášky 412/2021 Sb. ukládá aplikace **tři jako primární** —
všechny jsou v DB **1:1 s vyhláškou**. K nim přidává **jednu vlastní vrstvu** (UI
kategorizace), která existuje jen v aplikaci a slouží srozumitelné prezentaci veřejnosti.

| Dimenze                | Zdroj pravdy                           | Tabulky v DB                                                               | Vztah k vyhlášce                         | K čemu slouží                                             |
| ---------------------- | -------------------------------------- | -------------------------------------------------------------------------- | ---------------------------------------- | --------------------------------------------------------- |
| **Kapitolové třídění** | zákon č. 434/2024 Sb.                  | `chapters`, `chapter_org_units`                                            | 1:1 s vyhláškou                          | Sekundární pohled „Ministerstva" — kdo peníze spravuje    |
| **Druhové třídění**    | vyhláška č. 412/2021 Sb.               | `economic_classes`, `economic_groups`, `economic_items`                    | 1:1 s vyhláškou                          | Pomocný pohled — ekonomická povaha (platy vs. investice)  |
| **Odvětvové třídění**  | vyhláška č. 412/2021 Sb., příloha č. 3 | `functional_divisions`, `functional_subdivisions`, `functional_paragraphs` | 1:1 s vyhláškou                          | Datový základ pro UI kategorie                            |
| **UI kategorie**       | vlastní specifikace tohoto dokumentu   | `categories`, `category_paragraph_map`                                     | aplikační vrstva nad odvětvovým tříděním | Primární pohled veřejnosti — laicky srozumitelná škatulka |

### Co tento model umožňuje

- **Vyhláškovou strukturu kdykoli prezentovat 1:1.** Pokud bude potřeba ukázat oficiální
  pohled (např. budoucí stránka „Ministerstva" nebo „Kam jdou platy"), data jsou v DB
  v původní vyhláškové formě a stačí jiná query.
- **UI kategorie měnit jako data, ne jako schema.** Přejmenování, přesun oddílu, sloučení
  kategorií — vše jsou operace na úrovni řádků v `category_paragraph_map`. Žádný
  `ALTER TABLE`, žádné dotčení vyhláškové vrstvy.
- **Vyhláškové dimenze nelze upravovat ad hoc.** Pokud vyhláška přibude paragraf nebo
  přejmenuje oddíl, projeví se to versioned migrací (`drizzle-kit generate`), ne ručním
  editem.

### Vztah mezi odvětvovým tříděním a UI kategoriemi

UI kategorie se vědomě **odchylují od skupin vyhlášky** v některých případech (viz sekce
_Doporučené kategorie pro aplikaci_ níže). Odchylka se ale nikdy nedotýká vyhláškové
hierarchie (paragraf → pododdíl → oddíl → skupina) — pohybuje se výhradně v rovině
„který paragraf dostane kterou UI nálepku". Vyhláška je v DB nedotčená, odchylky jsou
v tabulce `category_paragraph_map`.

---

## Rozpočtová skladba — kompletní přehled (vyhláška 412/2021 Sb.)

Rozpočtová skladba je závazný systém třídění příjmů, výdajů a financujících operací
veřejných rozpočtů. Účinná od 1. 1. 2022 (nahradila vyhlášku 323/2002 Sb.), průběžně
novelizovaná — pro rok 2025 platí znění s pokynem MF z 1. 1. 2024.

Vyhláška definuje **12 dimenzí třídění**. Každý záznam v Monitor datech má _současně_
všechny dimenze, lze tedy z jednoho datasetu vytvořit více pohledů.

| #   | Třídění                        | Co popisuje                                            | Relevance pro aplikaci             |
| --- | ------------------------------ | ------------------------------------------------------ | ---------------------------------- |
| 1   | **Odpovědnostní** (kapitolové) | KDO peníze spravuje                                    | ✅ Sekundární pohled               |
| 2   | **Druhové**                    | Jaká je ekonomická povaha (plat, investice, transfer…) | ⚠️ Pomocné — viz níže              |
| 3   | **Odvětvové** (funkční)        | NA CO peníze jdou                                      | ✅ Primární pohled                 |
| 4   | Konsolidační                   | Mezi kterými rozpočty peníze tečou                     | ❌ Technické                       |
| 5   | Podkladové                     | Typ rozpočtového opatření                              | ❌ Technické                       |
| 6   | Prostorové                     | Tuzemsko/zahraničí jako zdroj                          | ❌ Technické                       |
| 7   | Nástrojové                     | EU fondy, mezinárodní smlouvy                          | ⚠️ Možná pro EU transfery          |
| 8   | Doplňkové                      | Zvlášť sledované celky                                 | ❌ Technické                       |
| 9   | Programové                     | Programy a akce (EDS/SMVS)                             | ⚠️ Možná pro investiční drill-down |
| 10  | Účelové                        | Účel transferů (mzdy, ICT…)                            | ❌ Technické                       |
| 11  | Strukturní                     | Věcná podstata operací                                 | ❌ Technické                       |
| 12  | Transferové                    | Účel transferů příjemcům                               | ❌ Technické                       |

> **Číselník:** Závazný číselník rozpočtové skladby je publikován MF ČR v IISSP
> (informační systém státní pokladny). Před implementací mapování vždy ověřit
> aktuální verzi proti zdroji monitor.statnipokladna.gov.cz nebo
> mfcr.cz/cs/rozpoctova-politika/statni-rozpocet/legislativa-statniho-rozpoctu.

### Druhové třídění — struktura tříd 1–8

Hierarchie: **třída** (1 číslice) → **seskupení položek** (2 číslice)
→ **podseskupení položek** (3 číslice) → **položka** (4 číslice).

Třída 7 v systému neexistuje (rezervováno do budoucna).

| Třída | Název             | Typ operace | Příklady položek                                                                                                                                       |
| ----- | ----------------- | ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| **1** | Daňové příjmy     | Příjmy      | DPH (1211), DPFO (1111–1113), DPPO (1121–1123), spotřební daně (1221–1229), energetické daně (1231–1234), pojistné na sociální zabezpečení (1611–1618) |
| **2** | Nedaňové příjmy   | Příjmy      | Vlastní činnost (2111), sankční platby (2211, 2212), prodej krátkodobého majetku (2310), splátky půjček (2411–2414)                                    |
| **3** | Kapitálové příjmy | Příjmy      | Prodej dlouhodobého majetku (3111–3113), prodej akcií a podílů (3201)                                                                                  |
| **4** | Přijaté transfery | Příjmy      | Neinvestiční (4111–4116) i investiční (4211–4216) transfery — typicky z EU rozpočtu, mezi rozpočty                                                     |
| **5** | Běžné výdaje      | Výdaje      | Platy (5011), povinné pojistné (5031–5032), nákup materiálu (5139), energie (5154), sociální dávky (5410), neinvestiční dotace (5311–5343)             |
| **6** | Kapitálové výdaje | Výdaje      | Stavební investice (6121), stroje a zařízení (6122), nákup akcií/podílů (6201), investiční transfery (6311–6359)                                       |
| **8** | Financování       | Financování | Emise/splátky státních dluhopisů (8111–8128), změna stavu na účtech (8115), půjčky od/k subjektům                                                      |

**Proč druhové třídění v aplikaci aktivně nepoužívat jako hlavní pohled:**

- Odpovídá na „jaká je ekonomická povaha výdaje" — laika typicky nezajímá tolik
  jako „na co peníze jdou".
- Hodí se ale jako **agregace v rámci kategorie** — např. u Vzdělávání ukázat,
  kolik z toho jsou platy učitelů (tř. 5) vs. investice do budov (tř. 6).
  Informačně silné, technicky levné (Monitor data tuto dimenzi obsahují).
- Třída 8 (financování) je samostatný okruh — _nepatří_ do příjmů ani výdajů,
  ale do bilance schodku/přebytku.

### Vztah dimenzí v datech Monitor SP

Každý záznam má současně kapitolu, paragraf (funkční), položku (druhové):

```
kapitola=333 (MŠMT) a paragraf=3113 (ZŠ) a položka=5011 (platy)
→ výdaj 50 mld. Kč
```

Z jednoho datasetu lze tedy postavit:

- **funkční pohled** — agregace přes paragraf
- **kapitolový pohled** — agregace přes kapitolu
- **ekonomický pohled** (volitelný) — agregace přes položku/třídu

---

## Reálná data: Monitor Státní Pokladny

**Datový zdroj:** https://monitor.statnipokladna.gov.cz (open data API a CSV/JSON soubory)

**Co je dostupné:**

- Data státního rozpočtu po letech (i měsících)
- Dimenze: paragraf (funkční třídění), položka (druhové třídění), kapitola
- Sloupce: budget_adopted, budget_amended, budget_spending

**Jak funguje funkční třídění (dle vyhlášky 412/2021 Sb., příloha č. 3):**

> Názvy skupin, oddílů, pododdílů a paragrafů jsou v této sekci uvedeny **doslovně
> dle přílohy č. 3 vyhlášky 412/2021 Sb.** (znění od 1. 1. 2026). Listing níže je
> **ilustrativní výběr** pro čitelnost dokumentu — kompletní strom obsahuje 27 oddílů,
> 152 pododdílů a 527 paragrafů. Pro úplný seznam viz e-sbirka.gov.cz/sb/2021/412
> nebo zakonyprolidi.cz/cs/2021-412.
>
> **DB stav:** úplný strom je seedován v migracích `0002_seed_static_dimensions.sql`
> (počáteční výběr odpovídající textu níže) a `0003_extend_functional_tree_from_vyhlaska.sql`
>
> - `0004_complete_category_paragraph_map.sql` (doplnění do plné vyhláškové úrovně).
>   Tabulky `functional_*` jsou tedy 1:1 s vyhláškou; tento dokument zůstává čtenou
>   referencí, ne zdrojem pravdy.

```
Skupina (1 číslice) → Oddíl (2 číslice) → Pododdíl (3 číslice) → Paragraf (4 číslice)

Sk. 1 – Zemědělství, lesní hospodářství a rybářství
  10 (jediný oddíl — skupina 1 nemá oddílovou úroveň)
    101  Zemědělská a potravinářská činnost a rozvoj
    102  Regulace zemědělské produkce, organizace trhu a poskytování podpor
    103  Lesní hospodářství
    106  Správa v zemědělství
    107  Rybářství a myslivost
    108  Zemědělský a lesnický výzkum a vývoj

Sk. 2 – Průmyslová a ostatní odvětví hospodářství
  21  Průmysl, stavebnictví, obchod a služby
    211  Záležitosti těžebního průmyslu a energetiky
    212  Ostatní odvětvové a oborové záležitosti v průmyslu a stavebnictví
    213  Zahraniční obchod
    214  Vnitřní obchod, služby a cestovní ruch
  22  Doprava
    221  Pozemní komunikace
      2211  Dálnice                    ← pozor: 2211 je DÁLNICE, ne silnice
      2212  Silnice
      2219  Ostatní záležitosti pozemních komunikací
    222  Silniční doprava
      2221  Provoz veřejné silniční dopravy
      2223  Bezpečnost silničního provozu
    224  Železniční doprava
      2241  Železniční dráhy
      2242  Provoz veřejné železniční dopravy
    225  Civilní letecká doprava
      2251  Letiště
      2252  Zabezpečení letového provozu
    226  Správa v dopravě
      2269  Činnost Státního fondu dopravní infrastruktury (SFDI)
  23  Vodní hospodářství
    231  Pitná voda
    232  Odvádění a čistění odpadních vod
    233  Vodní toky a vodohospodářská díla
  24  Spoje
  25  Všeobecné hospodářské záležitosti a ostatní ekonomické funkce
    251  Podpora podnikání

Sk. 3 – Služby pro fyzické osoby
  31 a 32  Vzdělávání a školské služby
    311  Předškolní a základní vzdělávání
      3111  Mateřské školy
      3112  Mateřské školy pro děti se speciálními vzdělávacími potřebami
      3113  Základní školy
      3114  Základní školy pro žáky se speciálními vzdělávacími potřebami
      3117  První stupeň základních škol
      3118  Druhý stupeň základních škol
    312  Střední vzdělávání a vzdělávání v konzervatořích
      3121  Gymnázia
      3122  Střední odborné školy
      3123  Střední školy poskytující střední vzdělání s výučním listem
      3126  Konzervatoře
    313  Školská zařízení pro výkon ústavní a ochranné výchovy
      3131  Výchovné ústavy a dětské domovy se školou
      3133  Dětské domovy
    314  Ostatní zařízení související s výchovou a vzděláváním mládeže
      3141  Školní stravování
      3143  Školní družiny a kluby
    315  Vyšší odborné vzdělávání
      3150  Vyšší odborné školy
    321  Vysokoškolské vzdělávání
      3211  Vysoké školy
      3212  Výzkum, vývoj a inovace na vysokých školách
      3213  Bakalářské studium
      3214  Magisterské a doktorské studium
    322  Zařízení související s vysokoškolským vzděláváním
      3221  Vysokoškolské koleje a menzy
    323  Základní umělecké, jazykové a zájmové vzdělávání
      3231  Základní umělecké školy
    326  Správa ve vzdělávání
    329  Ostatní činnost a nespecifikované výdaje
      3299  Ostatní záležitosti vzdělávání
  33  Kultura, církve a sdělovací prostředky
    331  Kultura
      3311  Divadelní činnost
      3312  Hudební činnost
      3313  Filmová tvorba, distribuce, kina a shromažďování audiovizuálních archiválií
      3314  Činnosti knihovnické
      3315  Činnosti muzeí a galerií
      3319  Ostatní záležitosti kultury
    332  Ochrana památek a péče o kulturní dědictví a národní a historické povědomí
      3322  Zachování a obnova kulturních památek
      3325  Pražský hrad
    333  Činnosti registrovaných církví a náboženských společností
      3330  Činnosti registrovaných církví a náboženských společností
    334  Sdělovací prostředky
      3341  Rozhlas a televize
  34  Sport a zájmová činnost
    341  Sport
      3411  Státní sportovní reprezentace
      3412  Sportovní zařízení ve vlastnictví obce
      3419  Ostatní sportovní činnost
    342  Zájmová činnost a rekreace
      3421  Využití volného času dětí a mládeže
      3429  Ostatní zájmová činnost a rekreace
  35  Zdravotnictví
    351  Ambulantní péče
      3511  Všeobecná ambulantní péče
      3512  Stomatologická péče
      3513  Lékařská služba první pomoci
      3514  Transfúzní služba a tkáňová zařízení
      3515  Specializovaná ambulantní zdravotní péče
      3516  Péče v mateřství
      3519  Ostatní ambulantní péče
    352  Lůžková péče
      3521  Fakultní nemocnice
      3522  Ostatní nemocnice
      3523  Odborné léčebné ústavy
      3524  Léčebny dlouhodobě nemocných
      3525  Hospice
      3526  Lázeňské léčebny, ozdravovny, sanatoria
      3527  Vysoce specializovaná pracoviště a jednooborové zařízení lůžkové péče
    353  Zvláštní zdravotnická zařízení a služby pro zdravotnictví
      3531  Hygienická služba a ochrana veřejného zdraví
      3532  Lékárenská služba
      3533  Zdravotnická záchranná služba
      3534  Doprava ve zdravotnictví
    354  Zdravotnické programy
      3541  Prevence před drogami, alkoholem, nikotinem a jinými závislostmi
      3543  Pomoc zdravotně postiženým
      3544  Národní program zdraví
      3545  Programy paliativní péče
    356  Správa ve zdravotnictví
  36  Bydlení, komunální služby a územní rozvoj
    361  Rozvoj bydlení a bytové hospodářství
    363  Komunální služby a územní rozvoj
  37  Ochrana životního prostředí
    371  Ochrana ovzduší a klimatu
      3711  Odstraňování tuhých emisí
      3712  Odstraňování plynných emisí
      3714  Opatření ke snižování produkce skleníkových plynů a plynů poškozujících ozónovou vrstvu
      3716  Monitoring ochrany ovzduší
    372  Nakládání s odpady
      3722  Sběr a svoz komunálních odpadů
      3725  Využívání a zneškodňování komunálních odpadů
    373  Ochrana a sanace půdy a podzemní vody
    374  Ochrana přírody a krajiny
      3741  Ochrana druhů a stanovišť
      3742  Chráněné části přírody
  38  Ostatní výzkum a vývoj
  39  Ostatní činnosti související se službami pro fyzické osoby

Sk. 4 – Sociální věci a politika zaměstnanosti
  41  Dávky a podpory v sociálním zabezpečení
    411  Dávky důchodového pojištění
      4111  Starobní důchody                        ← největší položka celého SR
                                                       (~580 mld. Kč; celkem důchody
                                                        2025 ~700 mld. Kč)
      4112  Invalidní důchody pro invaliditu třetího stupně
      4113  Invalidní důchody pro invaliditu druhého stupně
      4114  Vdovské důchody
      4115  Vdovecké důchody
      4116  Sirotčí důchody
      4117  Invalidní důchody pro invaliditu prvního stupně
    412  Dávky nemocenského pojištění
      4121  Nemocenské
      4122  Ošetřovné
      4124  Peněžitá pomoc v mateřství
      4125  Dávky otcovské poporodní péče
      4126  Dlouhodobé ošetřovné
    413 a 414  Dávky státní sociální podpory a dávky pěstounské péče
      4131  Přídavek na dítě
      4133  Porodné
      4134  Rodičovský příspěvek
      4136  Dávky pěstounské péče a zaopatřovací příspěvky
      4138  Pohřebné
      4141  Příspěvek na bydlení
    417  Dávky pomoci v hmotné nouzi
      4171  Příspěvek na živobytí
      4172  Doplatek na bydlení
      4173  Mimořádná okamžitá pomoc
    418  Dávky osobám se zdravotním postižením
      4187  Příspěvek na mobilitu
      4188  Příspěvek na zvláštní pomůcku
    419  Ostatní dávky povahy sociálního zabezpečení
      4195  Příspěvek na péči
  42  Politika zaměstnanosti
    421  Podpory v nezaměstnanosti
      4210  Podpory v nezaměstnanosti
    422  Aktivní politika zaměstnanosti
      4221  Rekvalifikace
      4222  Veřejně prospěšné práce
      4223  Společensky účelná pracovní místa
      4227  Cílené programy k řešení zaměstnanosti
  43  Sociální služby a společné činnosti v sociálním zabezpečení a politice zaměstnanosti
    431  Sociální poradenství
    432  Sociální péče a pomoc dětem a mládeži
      4324  Zařízení pro děti vyžadující okamžitou pomoc
    435  Sociální služby v oblasti sociální péče
      4350  Domovy pro seniory
      4351  Osobní asistence, pečovatelská služba a podpora samostatného bydlení
      4354  Chráněné bydlení
      4356  Denní stacionáře a centra denních služeb
      4357  Domovy pro osoby se zdravotním postižením a domovy se zvláštním režimem
    437  Služby sociální prevence
      4374  Azylové domy, nízkoprahová denní centra a noclehárny

Sk. 5 – Bezpečnost státu a právní ochrana
  51  Obrana
    511  Vojenská obrana
      5111  Armáda
      5112  Ostatní ozbrojené síly
      5113  Bezpečnostní složky ozbrojených sil
      5119  Podpůrné složky ozbrojených sil
    517  Zabezpečení potřeb ozbrojených sil
      5171  Zabezpečení potřeb ozbrojených sil
  52  Civilní připravenost na krizové stavy
    521  Ochrana fyzických osob
    522  Hospodářská opatření pro krizové stavy
    527  Krizové řízení
  53  Bezpečnost a veřejný pořádek
    531  Bezpečnost a veřejný pořádek
      5311  Bezpečnost a veřejný pořádek (Policie ČR)
      5312  Opatření proti legalizaci výnosů z trestné činnosti a financování terorismu
      5317  Hraniční přechody
  54  Právní ochrana                                ← justice, ne bezpečnost
    541  Ústavní soudnictví
      5410  Ústavní soud
    542  Soudnictví
    543  Státní zastupitelství
      5430  Státní zastupitelství
    544  Vězeňství
      5441  Činnost Generálního ředitelství Vězeňské služby a věznic
    545  Probační a mediační služba
      5450  Činnost probační a mediační služby
    547  Veřejná ochrana
      5470  Kancelář veřejného ochránce práv a ochránce práv dětí
  55  Požární ochrana a integrovaný záchranný systém
    551  Požární ochrana
      5511  Požární ochrana – profesionální část (HZS)
      5512  Požární ochrana – dobrovolná část (SDH)
      5517  Vzdělávací a technická zařízení požární ochrany
    552  Ostatní složky a činnosti integrovaného záchranného systému
      5521  Operační a informační střediska integrovaného záchranného systému

Sk. 6 – Všeobecná veřejná správa a služby
  61  Státní moc, státní správa, územní samospráva a politické strany
    611  Zastupitelské orgány a volby
      6111  Parlament
      6112  Zastupitelstva obcí
      6113  Zastupitelstva krajů
      6114  Volby do Parlamentu ČR
      6115  Volby do zastupitelstev územních samosprávných celků
      6117  Volby do Evropského parlamentu
      6118  Volba prezidenta republiky
    612  Kancelář prezidenta republiky
      6120  Kancelář prezidenta republiky
    613  Nejvyšší kontrolní úřad
      6130  Nejvyšší kontrolní úřad
    614  Všeobecná vnitřní státní správa nezařazená v jiných funkcích
      6141  Ústřední orgány vnitřní státní správy a jejich dislokovaná pracoviště
      6142  Orgány Finanční správy České republiky
      6143  Orgány Celní správy České republiky
      6145  Úřad vlády
      6146  Český statistický úřad
    615  Zahraniční služba a záležitosti nezařazené v jiných funkcích
      6151  Činnost ústředního orgánu státní správy v zahraniční službě (MZV)
      6152  Zastupitelství a stálé mise ČR v zahraničí
    617  Regionální a místní správa
      6171  Činnost místní správy
      6172  Činnost regionální správy
    619  Politické strany a hnutí
      6190  Politické strany a hnutí
  62  Jiné veřejné služby a činnosti
    621  Ostatní veřejné služby
      6211  Archivní činnost
    622  Zahraniční pomoc a mezinárodní spolupráce jinde nezařazená
      6222  Rozvojová zahraniční pomoc
      6224  Humanitární zahraniční pomoc prostřednictvím mezinárodních organizací
  63  Finanční operace
    631  Obecné příjmy a výdaje z finančních operací
      6310  Obecné příjmy a výdaje z finančních operací   ← sem patří obsluha státního
                                                            dluhu (úroky z dluhopisů);
                                                            kapitola 396 ~110 mld. (2025)
    632  Pojištění funkčně nespecifikované
      6320  Pojištění funkčně nespecifikované
    633  Převody vlastním fondům v rozpočtech územní úrovně
      6330  Převody vlastním fondům v rozpočtech územní úrovně
  64  Ostatní činnosti
    640  Ostatní činnosti
```

---

## Doporučené kategorie pro aplikaci

### Filozofie kategorizace: hybridní přístup

Kategorie aplikace **se v některých případech vědomě odchylují od skupin vyhlášky
412/2021 Sb.** Důvodem je primární cíl aplikace — srozumitelnost pro laickou
veřejnost (viz Kontext, řádky 5–9).

**Co dodržujeme striktně dle vyhlášky:**

- Názvy a kódy oddílů, pododdílů a paragrafů (viz strom výše, sekce _Jak funguje
  funkční třídění_)
- Datový model (každý paragraf má jednoznačný oddíl)
- Mapování `paragraf → oddíl` přejímá vyhlášku 1:1

**Kde se UI kategorie odchylují od skupin vyhlášky:**

- **Oddíl 54 (Právní ochrana — soudy, státní zastupitelství, vězeňství, ombudsman)**
  je ve vyhlášce ve skupině 5 („Bezpečnost a právní ochrana"). V UI ho řadíme do
  `publicAdministration`, protože laik mentálně řadí justici ke „státní správě",
  ne k „obraně a bezpečnosti".
- **Oddíly 33 (Kultura, církve, sdělovací prostředky) a 34 (Sport a zájmová činnost)**
  jsou ve vyhlášce oddělené. V UI je spojujeme do `cultureAndSport`, protože každý
  samostatně má malý objem (~1 % SR) a v běžné komunikaci je veřejnost vnímá společně.
- Důvod obou: vyhláška reflektuje _byrokratickou_ organizaci (kdo to spravuje, kdo
  dělá legislativu), ne _mentální model_ občana sledujícího kam jdou jeho daně.

**Implementace:** Mapování `paragraf → CategoryKey` je uloženo v DB tabulce
`category_paragraph_map`. Vyhláškové dimenze (`functional_divisions`,
`functional_subdivisions`, `functional_paragraphs`) zůstávají nedotčené — UI
kategorie tvoří separátní vrstvu nad nimi. Změna mapování (přesun oddílu, sloučení
nebo rozdělení kategorie) je krátká data migrace na pár řádků v
`category_paragraph_map`; přechod na strict variantu odpovídající 1:1 skupinám
vyhlášky je při změně preferencí triviální.

### Výdaje – 11 kategorií (funkční třídění → veřejné skupiny)

| Kategorie (key)             | Název pro veřejnost             | Podkategorie                                                                                                       | Pokrývá oddíly                        | ~% 2025 | Hlavní kapitoly                |
| --------------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------ | ------------------------------------- | ------- | ------------------------------ |
| `socialProtection`          | Sociální péče                   | Starobní a invalidní důchody, Nemocenská a mateřská, Rodičovský příspěvek, Podpora nezaměstnaných, Sociální služby | 41, 42, 43 (celá sk. 4)               | 35 %    | MPSV (313)                     |
| `healthcare`                | Zdravotnictví\*                 | Přísp. pojišťovnám za st. pojištěnce, Ambulantní péče, Nemocniční péče, Veřejné zdraví                             | **35**                                | 6 %     | MZd (335)                      |
| `education`                 | Vzdělávání                      | MŠ a ZŠ, Střední školy, Vysoké školy, Věda a výzkum                                                                | **31, 32**                            | 11 %    | MŠMT (333), AV ČR (361)        |
| `defenseAndSecurity`        | Obrana a bezpečnost             | Armáda, Policie, Hasiči a IZS, Krizové řízení, Zpravodajské služby                                                 | 51, 52, 53, 55 (sk. 5 bez 54)         | 8 %     | MO (307), MV (314)             |
| `transport`                 | Doprava a infrastruktura        | Silnice a dálnice, Železnice, Vodohospodářství                                                                     | 22, 23                                | 9 %     | MD (327), SFDI                 |
| `debtService`               | Obsluha státního dluhu          | Úroky ze dluhopisů, Splátky půjček                                                                                 | 63 (paragraf 6310)                    | 4 %     | Státní dluh (396)              |
| `publicAdministration`      | Státní správa a justice         | Ministerstva, Parlament a prezident, Soudy, Vězeňství, Ombudsman                                                   | 61, 62, **54** (Právní ochrana)       | ~5 %    | MF (312), MSp (336), PSP (302) |
| `municipalTransfers`        | Podpora obcí a krajů            | Sdílené daně, Dotace obcím a krajům                                                                                | napříč funkcemi (dle účelu transferu) | ~6–7 %  | **kap. 398 (VPS)**             |
| `environmentAndAgriculture` | Zemědělství a životní prostředí | Zemědělství a lesy, Ochrana přírody a ovzduší, Vodní hospodářství                                                  | sk. 1 (oddíl 10), 37                  | 4 %     | MZe (329), MŽP (315)           |
| `cultureAndSport`           | Kultura a sport                 | Kulturní dědictví, Muzea a divadla, Sport a tělovýchova                                                            | **33, 34**                            | 2 %     | MK (334), NSA (362)            |
| `industryAndEconomy`        | Hospodářství a energetika       | Energetika a OZE, Dotace podnikatelům, Podpora exportu, Spoje                                                      | 21, 24, 25                            | 3–4 %   | MPO (322)                      |

> **Pozn. k drobným oddílům:** Oddíl 36 (Bydlení, komunální služby, územní rozvoj),
> 38 (Ostatní výzkum a vývoj), 39 (Ostatní činnosti služeb pro FO) a 64 (Ostatní
> činnosti) mají minoritní objemy a vyhláška je nezařazuje jednoznačně. Při
> implementaci `budgetMapper.ts` je nasazovat do nejbližší kategorie podle obsahu
> konkrétního paragrafu (např. paragrafy 363x → `municipalTransfers` pro komunální
> služby, 361x → `publicAdministration` pro bytovou politiku státu), nebo vytvořit
> samostatný fallback „Ostatní".

> \*Zdravotnictví: Zdravotní pojišťovny (VZP atd.) jsou MIMO státní rozpočet.
> Státní rozpočet hradí jen příspěvky za „státní pojištěnce" (~140 mld. Kč).
> Celkové výdaje na zdravotnictví v ČR jsou ~700 mld. Kč přes systém zdravotního pojištění.
> → V UI zobrazit prominentní kontextový banner nebo tooltip s tímto vysvětlením.

> **Vizualizace:**
>
> - **Stránka Overview:** Pie chart zobrazí pouze top 6 kategorií podle objemu; zbývající 5
>   se seskupí pod "Ostatní". Kliknutím na "Ostatní" nebo na odkaz pod grafem přejde uživatel
>   na stránku Výdaje, kde jsou všechny kategorie.
> - **Stránka Výdaje:** Bar chart (sestupně seřazený) zobrazí všech 11 kategorií.

> **Podpora obcí vs. státní správa:** Záměrně rozděleny – laik asociuje "obec" s veřejnými službami
> (škola, hřiště, oprava cest), ne s "byrokracií".

### Příjmy – 6 kategorií

| Kategorie (key)   | Název                        | Podkategorie                                                   | ~hodnota 2025 |
| ----------------- | ---------------------------- | -------------------------------------------------------------- | ------------- |
| `vat`             | DPH                          | Základní sazba 21 %, Snížené sazby 12 %, DPH z dovozu          | ~520 mld.     |
| `incomeTax`       | Daně z příjmů                | DPFO zaměstnanci, DPFO OSVČ, DPPO                              | ~390 mld.     |
| `socialInsurance` | Pojistné soc. zabezpečení    | Důchodové poj., Nemocenské poj., Přísp. politika zam.          | ~810 mld.     |
| `exciseDuties`    | Spotřební a energetické daně | Pohonné hmoty, Tabák, Alkohol, Energetické daně                | ~200 mld.     |
| `euTransfers`     | Transfery EU                 | Příjmy z fondů EU, Odvody do EU (záporné)                      | variabilní    |
| `otherRevenue`    | Ostatní příjmy               | Dividendy st. firem (ČEZ...), Správní poplatky, Prodej majetku | ~150 mld.     |

---

## Kapitolové třídění: kde a jak ho zapojit

**Doporučený hybridní model (2 vstupní body a 1 cross-reference):**

### 1. Výchozí pohled: funkční kategorie

URL: `/expenses`, `/incomes` — 11 resp. 6 skupin, srozumitelné laiku

### 2. Stránka kategorie: inline „Kdo to spravuje"

URL: `/expenses/education`
Přidat sekci: „Správci výdajů na Vzdělávání"

```
MŠMT (333) ............ 85 %  → odkaz na detail kapitoly
AV ČR (361) ............ 8 %
Ostatní (kraje, fondy) . 7 %
```

Implementace: z Monitor dat agregovat kapitola-dimenzi filtrovanou na daný paragraf/oddíl.

### 3. Nová stránka: přehled kapitol (sekundární sekce)

URL: `/expenses/chapters` nebo `/ministries`

- Přehled všech 47 kapitol (SR 2025) seřazených sestupně podle objemu
- Pro každou kapitolu: název, celková výše, breakdown na funkční kategorie
- Kliknutím na kapitolu → detail: co ministerstvo dělá a na co výdaje jdou
- Cross-link zpět na funkční kategorie
- Kompletní seznam kapitol viz příloha na konci dokumentu

### Hierarchie v aplikaci (2 úrovně a cross-reference)

```
Výdaje
├── Sociální péče (funkční kategorie)         ← hlavní navigace
│   ├── Důchody
│   ├── Nemocenská a mateřská
│   └── [Správci: MPSV 95 %, ostatní 5 %]    ← inline cross-reference
├── Vzdělávání
│   ├── Základní a střední školy
│   └── [Správci: MŠMT 85 %, AV ČR 8 %...]
...

Ministerstva / Kapitoly                       ← sekundární sekce
├── MPSV (313) — 1 200 mld. Kč
│   ├── z toho Sociální péče: 95 %
│   └── z toho Zaměstnanost: 5 %
├── MŠMT (333) — 280 mld. Kč
│   └── z toho Vzdělávání: 100 %
...
```

3 úrovně hloubky by bylo pro laiky příliš komplexní.
Raději 2 úrovně (funkce a podkategorie) a 2 dimenze pohledu (funkce ↔ kapitola).

---

## Ověření

- **Vizuální kontrola UI**: spustit `npm run dev`, zkontrolovat že proporce odpovídají realitě
  (~35 % Sociální péče, ~11 % Vzdělávání, ~8 % Obrana a bezpečnost)
- **Reálná data po ETL**: ověřit proti oficiálním zprávám MF ČR k SR 2025:
  - **Schválený rozpočet** (zákon č. 434/2024 Sb.): příjmy 2 086,1 mld. Kč,
    výdaje 2 327,1 mld. Kč, schodek 241 mld. Kč
  - **Skutečné plnění** (TZ MF ČR z ledna 2026): schodek 290,7 mld. Kč
    (překročení schváleného o 49,7 mld. Kč)
- **Lokalizace**: zkontrolovat překlady na obou jazykových mutacích (cs a en)

---

## Příloha: Kompletní seznam kapitol státního rozpočtu (2025)

Zdroj: **Zákon č. 434/2024 Sb. o státním rozpočtu ČR na rok 2025**. Celkem
**47 kapitol** (počet v čase roste — např. 2024 přibyla kapitola 364
Digitální a informační agentura, dříve dokumenty zmiňovaly 42).

Kapitoly jsou seskupené tematicky pro snadnější orientaci — v zákoně samotném
jsou jen seznam dle čísel.

### Ústavní činitelé a kontrolní orgány

| Kód | Kapitola                         |
| --- | -------------------------------- |
| 301 | Kancelář prezidenta republiky    |
| 302 | Poslanecká sněmovna Parlamentu   |
| 303 | Senát Parlamentu                 |
| 304 | Úřad vlády České republiky       |
| 309 | Kancelář veřejného ochránce práv |
| 358 | Ústavní soud                     |
| 359 | Úřad Národní rozpočtové rady     |
| 381 | Nejvyšší kontrolní úřad          |

### Ministerstva (14)

| Kód | Kapitola                                     | Zkratka |
| --- | -------------------------------------------- | ------- |
| 306 | Ministerstvo zahraničních věcí               | MZV     |
| 307 | Ministerstvo obrany                          | MO      |
| 312 | Ministerstvo financí                         | MF      |
| 313 | Ministerstvo práce a sociálních věcí         | MPSV    |
| 314 | Ministerstvo vnitra                          | MV      |
| 315 | Ministerstvo životního prostředí             | MŽP     |
| 317 | Ministerstvo pro místní rozvoj               | MMR     |
| 322 | Ministerstvo průmyslu a obchodu              | MPO     |
| 327 | Ministerstvo dopravy                         | MD      |
| 329 | Ministerstvo zemědělství                     | MZe     |
| 333 | Ministerstvo školství, mládeže a tělovýchovy | MŠMT    |
| 334 | Ministerstvo kultury                         | MK      |
| 335 | Ministerstvo zdravotnictví                   | MZd     |
| 336 | Ministerstvo spravedlnosti                   | MSp     |

### Bezpečnostní a zpravodajské služby

| Kód | Kapitola                                                       |
| --- | -------------------------------------------------------------- |
| 305 | Bezpečnostní informační služba (BIS)                           |
| 308 | Národní bezpečnostní úřad (NBÚ)                                |
| 376 | Generální inspekce bezpečnostních sborů (GIBS)                 |
| 378 | Národní úřad pro kybernetickou a informační bezpečnost (NÚKIB) |

### Regulační a kontrolní úřady

| Kód | Kapitola                                                               |
| --- | ---------------------------------------------------------------------- |
| 328 | Český telekomunikační úřad (ČTÚ)                                       |
| 343 | Úřad pro ochranu osobních údajů (ÚOOÚ)                                 |
| 344 | Úřad průmyslového vlastnictví (ÚPV)                                    |
| 345 | Český statistický úřad (ČSÚ)                                           |
| 346 | Český úřad zeměměřický a katastrální (ČÚZK)                            |
| 348 | Český báňský úřad                                                      |
| 349 | Energetický regulační úřad (ERÚ)                                       |
| 353 | Úřad pro ochranu hospodářské soutěže (ÚOHS)                            |
| 371 | Úřad pro dohled nad hospodařením politických stran a politických hnutí |
| 372 | Rada pro rozhlasové a televizní vysílání (RRTV)                        |
| 375 | Státní úřad pro jadernou bezpečnost (SÚJB)                             |

### Věda, výzkum a inovace

| Kód | Kapitola                                       |
| --- | ---------------------------------------------- |
| 321 | Grantová agentura České republiky (GA ČR)      |
| 361 | Akademie věd České republiky (AV ČR)           |
| 377 | Technologická agentura České republiky (TA ČR) |

### Ostatní speciální orgány

| Kód | Kapitola                                    |
| --- | ------------------------------------------- |
| 355 | Ústav pro studium totalitních režimů (ÚSTR) |
| 362 | Národní sportovní agentura (NSA)            |
| 364 | Digitální a informační agentura (DIA)       |
| 374 | Správa státních hmotných rezerv (SSHR)      |

### Souhrnné kapitoly (státní finance)

| Kód | Kapitola                          | ~Výdaje 2025 | Co obsahuje                                                                                    |
| --- | --------------------------------- | ------------ | ---------------------------------------------------------------------------------------------- |
| 396 | Státní dluh                       | ~110 mld. Kč | Obsluha státního dluhu — úroky z dluhopisů, poplatky                                           |
| 397 | Operace státních finančních aktiv | ~10 mil. Kč  | Finanční transakce SFA                                                                         |
| 398 | Všeobecná pokladní správa         | ~271 mld. Kč | Vládní rozpočtová rezerva, transfery územním rozpočtům (sdílené daně), ostatní souhrnné výdaje |

> **Pozn. k zdravotnictví:** Zdravotní pojišťovny (VZP, ZPMV, OZP, VoZP, ČPZP,
> RBP, ZP Škoda) mají vlastní rozpočty **mimo státní rozpočet** — v seznamu
> kapitol nejsou. Státní rozpočet hradí jen platby za státní pojištěnce
> (přes kapitolu 398 / MZd).

> **Pozn. ke „kapitole 0":** Některé sumarizační reporty MF zmiňují „kapitolu 0"
> nebo „kapitolu OSFA" mimo seznam — jde o technické položky, ne o samostatnou
> rozpočtovou kapitolu ve smyslu zákona o SR.

### Mapování kapitola → primární funkční kategorie aplikace

Pro implementaci `ChapterBreakdown.tsx` (kdo spravuje danou kategorii):

| Funkční kategorie                                             | Hlavní kapitoly                                                    |
| ------------------------------------------------------------- | ------------------------------------------------------------------ |
| Sociální péče (`socialProtection`)                            | 313 (MPSV) — ~95 %, zbytek 398                                     |
| Zdravotnictví (`healthcare`)                                  | 335 (MZd) — drtivá většina, 398 (platba za st. pojištěnce)         |
| Vzdělávání (`education`)                                      | 333 (MŠMT) — ~85 %, 361 (AV ČR), 321/377 (GA/TA ČR)                |
| Obrana a bezpečnost (`defenseAndSecurity`)                    | 307 (MO), 314 (MV — Policie a IZS), 305/308/378 (zprav./kyber)     |
| Doprava a infrastruktura (`transport`)                        | 327 (MD) a SFDI                                                    |
| Obsluha státního dluhu (`debtService`)                        | 396                                                                |
| Státní správa a justice (`publicAdministration`)              | 312 (MF), 336 (MSp), 302/303 (Parlament), 304, 301, ústavní orgány |
| Podpora obcí a krajů (`municipalTransfers`)                   | 398 (VPS — sdílené daně, dotace)                                   |
| Zemědělství a životní prostředí (`environmentAndAgriculture`) | 329 (MZe), 315 (MŽP)                                               |
| Kultura a sport (`cultureAndSport`)                           | 334 (MK), 362 (NSA)                                                |
| Hospodářství a energetika (`industryAndEconomy`)              | 322 (MPO), 349 (ERÚ)                                               |
