-- Seed of all static dimensions.
-- Squashed from original migrations 0002, 0003, 0004, 0006, 0007, 0011.
-- Sources:
--   * Functional + economic: vyhláška č. 412/2021 Sb., přílohy č. 2 a 3
--   * Chapters:              zákon č. 434/2024 Sb., příloha (47 kapitol SR 2025)
--   * Categories + mapping:  docs/budget-categorization.md (app layer)
-- All INSERTs are idempotent (ON CONFLICT DO NOTHING).

-- Seed of static dimensions.
-- Sources:
--   * Functional + economic: vyhláška č. 412/2021 Sb., příloha č. 3 (1:1)
--   * Chapters:              zákon č. 434/2024 Sb., příloha (47 kapitol SR 2025)
--   * Categories + mapping:  docs/budget-categorization.md (app layer)
--
-- FK references are resolved via subqueries (SELECT ... WHERE code = ...) so the
-- seed is independent of SERIAL ordering.

-- ===========================================================================
-- A. Functional classification (odvětvové třídění)
-- ===========================================================================

-- A.1 Oddíly (2-digit) — stored as functional_divisions per schema convention.
-- Skupiny (1-digit) z vyhlášky jsou jen organizační vrstva v textu, ne v DB.
INSERT INTO functional_divisions (code, slug, name_cs) VALUES
  ('10', 'division-10', 'Zemědělství, lesní hospodářství a rybářství'),
  ('21', 'division-21', 'Průmysl, stavebnictví, obchod a služby'),
  ('22', 'division-22', 'Doprava'),
  ('23', 'division-23', 'Vodní hospodářství'),
  ('24', 'division-24', 'Spoje'),
  ('25', 'division-25', 'Všeobecné hospodářské záležitosti a ostatní ekonomické funkce'),
  ('31', 'division-31', 'Vzdělávání a školské služby — předškolní, základní, střední, vyšší odborné'),
  ('32', 'division-32', 'Vzdělávání a školské služby — vysokoškolské a ostatní'),
  ('33', 'division-33', 'Kultura, církve a sdělovací prostředky'),
  ('34', 'division-34', 'Sport a zájmová činnost'),
  ('35', 'division-35', 'Zdravotnictví'),
  ('36', 'division-36', 'Bydlení, komunální služby a územní rozvoj'),
  ('37', 'division-37', 'Ochrana životního prostředí'),
  ('38', 'division-38', 'Ostatní výzkum a vývoj'),
  ('39', 'division-39', 'Ostatní činnosti související se službami pro fyzické osoby'),
  ('41', 'division-41', 'Dávky a podpory v sociálním zabezpečení'),
  ('42', 'division-42', 'Politika zaměstnanosti'),
  ('43', 'division-43', 'Sociální služby a společné činnosti v sociálním zabezpečení a politice zaměstnanosti'),
  ('51', 'division-51', 'Obrana'),
  ('52', 'division-52', 'Civilní připravenost na krizové stavy'),
  ('53', 'division-53', 'Bezpečnost a veřejný pořádek'),
  ('54', 'division-54', 'Právní ochrana'),
  ('55', 'division-55', 'Požární ochrana a integrovaný záchranný systém'),
  ('61', 'division-61', 'Státní moc, státní správa, územní samospráva a politické strany'),
  ('62', 'division-62', 'Jiné veřejné služby a činnosti'),
  ('63', 'division-63', 'Finanční operace'),
  ('64', 'division-64', 'Ostatní činnosti');

-- A.2 Pododdíly (3-digit) — stored as functional_subdivisions.
INSERT INTO functional_subdivisions (division_id, code, slug, name_cs) VALUES
  -- oddíl 10
  ((SELECT id FROM functional_divisions WHERE code = '10'), '101', 'subdivision-101', 'Zemědělská a potravinářská činnost a rozvoj'),
  ((SELECT id FROM functional_divisions WHERE code = '10'), '102', 'subdivision-102', 'Regulace zemědělské produkce, organizace trhu a poskytování podpor'),
  ((SELECT id FROM functional_divisions WHERE code = '10'), '103', 'subdivision-103', 'Lesní hospodářství'),
  ((SELECT id FROM functional_divisions WHERE code = '10'), '106', 'subdivision-106', 'Správa v zemědělství'),
  ((SELECT id FROM functional_divisions WHERE code = '10'), '107', 'subdivision-107', 'Rybářství a myslivost'),
  ((SELECT id FROM functional_divisions WHERE code = '10'), '108', 'subdivision-108', 'Zemědělský a lesnický výzkum a vývoj'),
  -- oddíl 21
  ((SELECT id FROM functional_divisions WHERE code = '21'), '211', 'subdivision-211', 'Záležitosti těžebního průmyslu a energetiky'),
  ((SELECT id FROM functional_divisions WHERE code = '21'), '212', 'subdivision-212', 'Ostatní odvětvové a oborové záležitosti v průmyslu a stavebnictví'),
  ((SELECT id FROM functional_divisions WHERE code = '21'), '213', 'subdivision-213', 'Zahraniční obchod'),
  ((SELECT id FROM functional_divisions WHERE code = '21'), '214', 'subdivision-214', 'Vnitřní obchod, služby a cestovní ruch'),
  -- oddíl 22
  ((SELECT id FROM functional_divisions WHERE code = '22'), '221', 'subdivision-221', 'Pozemní komunikace'),
  ((SELECT id FROM functional_divisions WHERE code = '22'), '222', 'subdivision-222', 'Silniční doprava'),
  ((SELECT id FROM functional_divisions WHERE code = '22'), '224', 'subdivision-224', 'Železniční doprava'),
  ((SELECT id FROM functional_divisions WHERE code = '22'), '225', 'subdivision-225', 'Civilní letecká doprava'),
  ((SELECT id FROM functional_divisions WHERE code = '22'), '226', 'subdivision-226', 'Správa v dopravě'),
  -- oddíl 23
  ((SELECT id FROM functional_divisions WHERE code = '23'), '231', 'subdivision-231', 'Pitná voda'),
  ((SELECT id FROM functional_divisions WHERE code = '23'), '232', 'subdivision-232', 'Odvádění a čistění odpadních vod'),
  ((SELECT id FROM functional_divisions WHERE code = '23'), '233', 'subdivision-233', 'Vodní toky a vodohospodářská díla'),
  -- oddíl 25
  ((SELECT id FROM functional_divisions WHERE code = '25'), '251', 'subdivision-251', 'Podpora podnikání'),
  -- oddíl 31
  ((SELECT id FROM functional_divisions WHERE code = '31'), '311', 'subdivision-311', 'Předškolní a základní vzdělávání'),
  ((SELECT id FROM functional_divisions WHERE code = '31'), '312', 'subdivision-312', 'Střední vzdělávání a vzdělávání v konzervatořích'),
  ((SELECT id FROM functional_divisions WHERE code = '31'), '313', 'subdivision-313', 'Školská zařízení pro výkon ústavní a ochranné výchovy'),
  ((SELECT id FROM functional_divisions WHERE code = '31'), '314', 'subdivision-314', 'Ostatní zařízení související s výchovou a vzděláváním mládeže'),
  ((SELECT id FROM functional_divisions WHERE code = '31'), '315', 'subdivision-315', 'Vyšší odborné vzdělávání'),
  -- oddíl 32
  ((SELECT id FROM functional_divisions WHERE code = '32'), '321', 'subdivision-321', 'Vysokoškolské vzdělávání'),
  ((SELECT id FROM functional_divisions WHERE code = '32'), '322', 'subdivision-322', 'Zařízení související s vysokoškolským vzděláváním'),
  ((SELECT id FROM functional_divisions WHERE code = '32'), '323', 'subdivision-323', 'Základní umělecké, jazykové a zájmové vzdělávání'),
  ((SELECT id FROM functional_divisions WHERE code = '32'), '326', 'subdivision-326', 'Správa ve vzdělávání'),
  ((SELECT id FROM functional_divisions WHERE code = '32'), '329', 'subdivision-329', 'Ostatní činnost a nespecifikované výdaje'),
  -- oddíl 33
  ((SELECT id FROM functional_divisions WHERE code = '33'), '331', 'subdivision-331', 'Kultura'),
  ((SELECT id FROM functional_divisions WHERE code = '33'), '332', 'subdivision-332', 'Ochrana památek a péče o kulturní dědictví a národní a historické povědomí'),
  ((SELECT id FROM functional_divisions WHERE code = '33'), '333', 'subdivision-333', 'Činnosti registrovaných církví a náboženských společností'),
  ((SELECT id FROM functional_divisions WHERE code = '33'), '334', 'subdivision-334', 'Sdělovací prostředky'),
  -- oddíl 34
  ((SELECT id FROM functional_divisions WHERE code = '34'), '341', 'subdivision-341', 'Sport'),
  ((SELECT id FROM functional_divisions WHERE code = '34'), '342', 'subdivision-342', 'Zájmová činnost a rekreace'),
  -- oddíl 35
  ((SELECT id FROM functional_divisions WHERE code = '35'), '351', 'subdivision-351', 'Ambulantní péče'),
  ((SELECT id FROM functional_divisions WHERE code = '35'), '352', 'subdivision-352', 'Lůžková péče'),
  ((SELECT id FROM functional_divisions WHERE code = '35'), '353', 'subdivision-353', 'Zvláštní zdravotnická zařízení a služby pro zdravotnictví'),
  ((SELECT id FROM functional_divisions WHERE code = '35'), '354', 'subdivision-354', 'Zdravotnické programy'),
  ((SELECT id FROM functional_divisions WHERE code = '35'), '356', 'subdivision-356', 'Správa ve zdravotnictví'),
  -- oddíl 36
  ((SELECT id FROM functional_divisions WHERE code = '36'), '361', 'subdivision-361', 'Rozvoj bydlení a bytové hospodářství'),
  ((SELECT id FROM functional_divisions WHERE code = '36'), '363', 'subdivision-363', 'Komunální služby a územní rozvoj'),
  -- oddíl 37
  ((SELECT id FROM functional_divisions WHERE code = '37'), '371', 'subdivision-371', 'Ochrana ovzduší a klimatu'),
  ((SELECT id FROM functional_divisions WHERE code = '37'), '372', 'subdivision-372', 'Nakládání s odpady'),
  ((SELECT id FROM functional_divisions WHERE code = '37'), '373', 'subdivision-373', 'Ochrana a sanace půdy a podzemní vody'),
  ((SELECT id FROM functional_divisions WHERE code = '37'), '374', 'subdivision-374', 'Ochrana přírody a krajiny'),
  -- oddíl 41
  ((SELECT id FROM functional_divisions WHERE code = '41'), '411', 'subdivision-411', 'Dávky důchodového pojištění'),
  ((SELECT id FROM functional_divisions WHERE code = '41'), '412', 'subdivision-412', 'Dávky nemocenského pojištění'),
  ((SELECT id FROM functional_divisions WHERE code = '41'), '413', 'subdivision-413', 'Dávky státní sociální podpory'),
  ((SELECT id FROM functional_divisions WHERE code = '41'), '414', 'subdivision-414', 'Dávky pěstounské péče'),
  ((SELECT id FROM functional_divisions WHERE code = '41'), '417', 'subdivision-417', 'Dávky pomoci v hmotné nouzi'),
  ((SELECT id FROM functional_divisions WHERE code = '41'), '418', 'subdivision-418', 'Dávky osobám se zdravotním postižením'),
  ((SELECT id FROM functional_divisions WHERE code = '41'), '419', 'subdivision-419', 'Ostatní dávky povahy sociálního zabezpečení'),
  -- oddíl 42
  ((SELECT id FROM functional_divisions WHERE code = '42'), '421', 'subdivision-421', 'Podpory v nezaměstnanosti'),
  ((SELECT id FROM functional_divisions WHERE code = '42'), '422', 'subdivision-422', 'Aktivní politika zaměstnanosti'),
  -- oddíl 43
  ((SELECT id FROM functional_divisions WHERE code = '43'), '431', 'subdivision-431', 'Sociální poradenství'),
  ((SELECT id FROM functional_divisions WHERE code = '43'), '432', 'subdivision-432', 'Sociální péče a pomoc dětem a mládeži'),
  ((SELECT id FROM functional_divisions WHERE code = '43'), '435', 'subdivision-435', 'Sociální služby v oblasti sociální péče'),
  ((SELECT id FROM functional_divisions WHERE code = '43'), '437', 'subdivision-437', 'Služby sociální prevence'),
  -- oddíl 51
  ((SELECT id FROM functional_divisions WHERE code = '51'), '511', 'subdivision-511', 'Vojenská obrana'),
  ((SELECT id FROM functional_divisions WHERE code = '51'), '517', 'subdivision-517', 'Zabezpečení potřeb ozbrojených sil'),
  -- oddíl 52
  ((SELECT id FROM functional_divisions WHERE code = '52'), '521', 'subdivision-521', 'Ochrana fyzických osob'),
  ((SELECT id FROM functional_divisions WHERE code = '52'), '522', 'subdivision-522', 'Hospodářská opatření pro krizové stavy'),
  ((SELECT id FROM functional_divisions WHERE code = '52'), '527', 'subdivision-527', 'Krizové řízení'),
  -- oddíl 53
  ((SELECT id FROM functional_divisions WHERE code = '53'), '531', 'subdivision-531', 'Bezpečnost a veřejný pořádek'),
  -- oddíl 54
  ((SELECT id FROM functional_divisions WHERE code = '54'), '541', 'subdivision-541', 'Ústavní soudnictví'),
  ((SELECT id FROM functional_divisions WHERE code = '54'), '542', 'subdivision-542', 'Soudnictví'),
  ((SELECT id FROM functional_divisions WHERE code = '54'), '543', 'subdivision-543', 'Státní zastupitelství'),
  ((SELECT id FROM functional_divisions WHERE code = '54'), '544', 'subdivision-544', 'Vězeňství'),
  ((SELECT id FROM functional_divisions WHERE code = '54'), '545', 'subdivision-545', 'Probační a mediační služba'),
  ((SELECT id FROM functional_divisions WHERE code = '54'), '547', 'subdivision-547', 'Veřejná ochrana'),
  -- oddíl 55
  ((SELECT id FROM functional_divisions WHERE code = '55'), '551', 'subdivision-551', 'Požární ochrana'),
  ((SELECT id FROM functional_divisions WHERE code = '55'), '552', 'subdivision-552', 'Ostatní složky a činnosti integrovaného záchranného systému'),
  -- oddíl 61
  ((SELECT id FROM functional_divisions WHERE code = '61'), '611', 'subdivision-611', 'Zastupitelské orgány a volby'),
  ((SELECT id FROM functional_divisions WHERE code = '61'), '612', 'subdivision-612', 'Kancelář prezidenta republiky'),
  ((SELECT id FROM functional_divisions WHERE code = '61'), '613', 'subdivision-613', 'Nejvyšší kontrolní úřad'),
  ((SELECT id FROM functional_divisions WHERE code = '61'), '614', 'subdivision-614', 'Všeobecná vnitřní státní správa nezařazená v jiných funkcích'),
  ((SELECT id FROM functional_divisions WHERE code = '61'), '615', 'subdivision-615', 'Zahraniční služba a záležitosti nezařazené v jiných funkcích'),
  ((SELECT id FROM functional_divisions WHERE code = '61'), '617', 'subdivision-617', 'Regionální a místní správa'),
  ((SELECT id FROM functional_divisions WHERE code = '61'), '619', 'subdivision-619', 'Politické strany a hnutí'),
  -- oddíl 62
  ((SELECT id FROM functional_divisions WHERE code = '62'), '621', 'subdivision-621', 'Ostatní veřejné služby'),
  ((SELECT id FROM functional_divisions WHERE code = '62'), '622', 'subdivision-622', 'Zahraniční pomoc a mezinárodní spolupráce jinde nezařazená'),
  -- oddíl 63
  ((SELECT id FROM functional_divisions WHERE code = '63'), '631', 'subdivision-631', 'Obecné příjmy a výdaje z finančních operací'),
  ((SELECT id FROM functional_divisions WHERE code = '63'), '632', 'subdivision-632', 'Pojištění funkčně nespecifikované'),
  ((SELECT id FROM functional_divisions WHERE code = '63'), '633', 'subdivision-633', 'Převody vlastním fondům v rozpočtech územní úrovně'),
  -- oddíl 64
  ((SELECT id FROM functional_divisions WHERE code = '64'), '640', 'subdivision-640', 'Ostatní činnosti');

-- A.3 Paragrafy (4-digit) — stored as functional_paragraphs.
INSERT INTO functional_paragraphs (subdivision_id, code, slug, name_cs) VALUES
  -- pododdíl 221 (Pozemní komunikace). 2211 = DÁLNICE, 2212 = SILNICE (pozor na pořadí dle vyhlášky).
  ((SELECT id FROM functional_subdivisions WHERE code = '221'), '2211', 'paragraph-2211', 'Dálnice'),
  ((SELECT id FROM functional_subdivisions WHERE code = '221'), '2212', 'paragraph-2212', 'Silnice'),
  ((SELECT id FROM functional_subdivisions WHERE code = '221'), '2219', 'paragraph-2219', 'Ostatní záležitosti pozemních komunikací'),
  -- pododdíl 222
  ((SELECT id FROM functional_subdivisions WHERE code = '222'), '2221', 'paragraph-2221', 'Provoz veřejné silniční dopravy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '222'), '2223', 'paragraph-2223', 'Bezpečnost silničního provozu'),
  -- pododdíl 224
  ((SELECT id FROM functional_subdivisions WHERE code = '224'), '2241', 'paragraph-2241', 'Železniční dráhy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '224'), '2242', 'paragraph-2242', 'Provoz veřejné železniční dopravy'),
  -- pododdíl 225
  ((SELECT id FROM functional_subdivisions WHERE code = '225'), '2251', 'paragraph-2251', 'Letiště'),
  ((SELECT id FROM functional_subdivisions WHERE code = '225'), '2252', 'paragraph-2252', 'Zabezpečení letového provozu'),
  -- pododdíl 226
  ((SELECT id FROM functional_subdivisions WHERE code = '226'), '2269', 'paragraph-2269', 'Činnost Státního fondu dopravní infrastruktury (SFDI)'),
  -- pododdíl 311
  ((SELECT id FROM functional_subdivisions WHERE code = '311'), '3111', 'paragraph-3111', 'Mateřské školy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '311'), '3112', 'paragraph-3112', 'Mateřské školy pro děti se speciálními vzdělávacími potřebami'),
  ((SELECT id FROM functional_subdivisions WHERE code = '311'), '3113', 'paragraph-3113', 'Základní školy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '311'), '3114', 'paragraph-3114', 'Základní školy pro žáky se speciálními vzdělávacími potřebami'),
  ((SELECT id FROM functional_subdivisions WHERE code = '311'), '3117', 'paragraph-3117', 'První stupeň základních škol'),
  ((SELECT id FROM functional_subdivisions WHERE code = '311'), '3118', 'paragraph-3118', 'Druhý stupeň základních škol'),
  -- pododdíl 312
  ((SELECT id FROM functional_subdivisions WHERE code = '312'), '3121', 'paragraph-3121', 'Gymnázia'),
  ((SELECT id FROM functional_subdivisions WHERE code = '312'), '3122', 'paragraph-3122', 'Střední odborné školy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '312'), '3123', 'paragraph-3123', 'Střední školy poskytující střední vzdělání s výučním listem'),
  ((SELECT id FROM functional_subdivisions WHERE code = '312'), '3126', 'paragraph-3126', 'Konzervatoře'),
  -- pododdíl 313
  ((SELECT id FROM functional_subdivisions WHERE code = '313'), '3131', 'paragraph-3131', 'Výchovné ústavy a dětské domovy se školou'),
  ((SELECT id FROM functional_subdivisions WHERE code = '313'), '3133', 'paragraph-3133', 'Dětské domovy'),
  -- pododdíl 314
  ((SELECT id FROM functional_subdivisions WHERE code = '314'), '3141', 'paragraph-3141', 'Školní stravování'),
  ((SELECT id FROM functional_subdivisions WHERE code = '314'), '3143', 'paragraph-3143', 'Školní družiny a kluby'),
  -- pododdíl 315
  ((SELECT id FROM functional_subdivisions WHERE code = '315'), '3150', 'paragraph-3150', 'Vyšší odborné školy'),
  -- pododdíl 321
  ((SELECT id FROM functional_subdivisions WHERE code = '321'), '3211', 'paragraph-3211', 'Vysoké školy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '321'), '3212', 'paragraph-3212', 'Výzkum, vývoj a inovace na vysokých školách'),
  ((SELECT id FROM functional_subdivisions WHERE code = '321'), '3213', 'paragraph-3213', 'Bakalářské studium'),
  ((SELECT id FROM functional_subdivisions WHERE code = '321'), '3214', 'paragraph-3214', 'Magisterské a doktorské studium'),
  -- pododdíl 322
  ((SELECT id FROM functional_subdivisions WHERE code = '322'), '3221', 'paragraph-3221', 'Vysokoškolské koleje a menzy'),
  -- pododdíl 323
  ((SELECT id FROM functional_subdivisions WHERE code = '323'), '3231', 'paragraph-3231', 'Základní umělecké školy'),
  -- pododdíl 329
  ((SELECT id FROM functional_subdivisions WHERE code = '329'), '3299', 'paragraph-3299', 'Ostatní záležitosti vzdělávání'),
  -- pododdíl 331 (kultura)
  ((SELECT id FROM functional_subdivisions WHERE code = '331'), '3311', 'paragraph-3311', 'Divadelní činnost'),
  ((SELECT id FROM functional_subdivisions WHERE code = '331'), '3312', 'paragraph-3312', 'Hudební činnost'),
  ((SELECT id FROM functional_subdivisions WHERE code = '331'), '3313', 'paragraph-3313', 'Filmová tvorba, distribuce, kina a shromažďování audiovizuálních archiválií'),
  ((SELECT id FROM functional_subdivisions WHERE code = '331'), '3314', 'paragraph-3314', 'Činnosti knihovnické'),
  ((SELECT id FROM functional_subdivisions WHERE code = '331'), '3315', 'paragraph-3315', 'Činnosti muzeí a galerií'),
  ((SELECT id FROM functional_subdivisions WHERE code = '331'), '3319', 'paragraph-3319', 'Ostatní záležitosti kultury'),
  -- pododdíl 332
  ((SELECT id FROM functional_subdivisions WHERE code = '332'), '3322', 'paragraph-3322', 'Zachování a obnova kulturních památek'),
  ((SELECT id FROM functional_subdivisions WHERE code = '332'), '3325', 'paragraph-3325', 'Pražský hrad'),
  -- pododdíl 333
  ((SELECT id FROM functional_subdivisions WHERE code = '333'), '3330', 'paragraph-3330', 'Činnosti registrovaných církví a náboženských společností'),
  -- pododdíl 334
  ((SELECT id FROM functional_subdivisions WHERE code = '334'), '3341', 'paragraph-3341', 'Rozhlas a televize'),
  -- pododdíl 341 (sport)
  ((SELECT id FROM functional_subdivisions WHERE code = '341'), '3411', 'paragraph-3411', 'Státní sportovní reprezentace'),
  ((SELECT id FROM functional_subdivisions WHERE code = '341'), '3412', 'paragraph-3412', 'Sportovní zařízení ve vlastnictví obce'),
  ((SELECT id FROM functional_subdivisions WHERE code = '341'), '3419', 'paragraph-3419', 'Ostatní sportovní činnost'),
  -- pododdíl 342
  ((SELECT id FROM functional_subdivisions WHERE code = '342'), '3421', 'paragraph-3421', 'Využití volného času dětí a mládeže'),
  ((SELECT id FROM functional_subdivisions WHERE code = '342'), '3429', 'paragraph-3429', 'Ostatní zájmová činnost a rekreace'),
  -- pododdíl 351 (zdravotnictví — ambulantní)
  ((SELECT id FROM functional_subdivisions WHERE code = '351'), '3511', 'paragraph-3511', 'Všeobecná ambulantní péče'),
  ((SELECT id FROM functional_subdivisions WHERE code = '351'), '3512', 'paragraph-3512', 'Stomatologická péče'),
  ((SELECT id FROM functional_subdivisions WHERE code = '351'), '3513', 'paragraph-3513', 'Lékařská služba první pomoci'),
  ((SELECT id FROM functional_subdivisions WHERE code = '351'), '3514', 'paragraph-3514', 'Transfúzní služba a tkáňová zařízení'),
  ((SELECT id FROM functional_subdivisions WHERE code = '351'), '3515', 'paragraph-3515', 'Specializovaná ambulantní zdravotní péče'),
  ((SELECT id FROM functional_subdivisions WHERE code = '351'), '3516', 'paragraph-3516', 'Péče v mateřství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '351'), '3519', 'paragraph-3519', 'Ostatní ambulantní péče'),
  -- pododdíl 352 (lůžková)
  ((SELECT id FROM functional_subdivisions WHERE code = '352'), '3521', 'paragraph-3521', 'Fakultní nemocnice'),
  ((SELECT id FROM functional_subdivisions WHERE code = '352'), '3522', 'paragraph-3522', 'Ostatní nemocnice'),
  ((SELECT id FROM functional_subdivisions WHERE code = '352'), '3523', 'paragraph-3523', 'Odborné léčebné ústavy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '352'), '3524', 'paragraph-3524', 'Léčebny dlouhodobě nemocných'),
  ((SELECT id FROM functional_subdivisions WHERE code = '352'), '3525', 'paragraph-3525', 'Hospice'),
  ((SELECT id FROM functional_subdivisions WHERE code = '352'), '3526', 'paragraph-3526', 'Lázeňské léčebny, ozdravovny, sanatoria'),
  ((SELECT id FROM functional_subdivisions WHERE code = '352'), '3527', 'paragraph-3527', 'Vysoce specializovaná pracoviště a jednooborové zařízení lůžkové péče'),
  -- pododdíl 353
  ((SELECT id FROM functional_subdivisions WHERE code = '353'), '3531', 'paragraph-3531', 'Hygienická služba a ochrana veřejného zdraví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '353'), '3532', 'paragraph-3532', 'Lékárenská služba'),
  ((SELECT id FROM functional_subdivisions WHERE code = '353'), '3533', 'paragraph-3533', 'Zdravotnická záchranná služba'),
  ((SELECT id FROM functional_subdivisions WHERE code = '353'), '3534', 'paragraph-3534', 'Doprava ve zdravotnictví'),
  -- pododdíl 354
  ((SELECT id FROM functional_subdivisions WHERE code = '354'), '3541', 'paragraph-3541', 'Prevence před drogami, alkoholem, nikotinem a jinými závislostmi'),
  ((SELECT id FROM functional_subdivisions WHERE code = '354'), '3543', 'paragraph-3543', 'Pomoc zdravotně postiženým'),
  ((SELECT id FROM functional_subdivisions WHERE code = '354'), '3544', 'paragraph-3544', 'Národní program zdraví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '354'), '3545', 'paragraph-3545', 'Programy paliativní péče'),
  -- pododdíl 371
  ((SELECT id FROM functional_subdivisions WHERE code = '371'), '3711', 'paragraph-3711', 'Odstraňování tuhých emisí'),
  ((SELECT id FROM functional_subdivisions WHERE code = '371'), '3712', 'paragraph-3712', 'Odstraňování plynných emisí'),
  ((SELECT id FROM functional_subdivisions WHERE code = '371'), '3714', 'paragraph-3714', 'Opatření ke snižování produkce skleníkových plynů a plynů poškozujících ozónovou vrstvu'),
  ((SELECT id FROM functional_subdivisions WHERE code = '371'), '3716', 'paragraph-3716', 'Monitoring ochrany ovzduší'),
  -- pododdíl 372
  ((SELECT id FROM functional_subdivisions WHERE code = '372'), '3722', 'paragraph-3722', 'Sběr a svoz komunálních odpadů'),
  ((SELECT id FROM functional_subdivisions WHERE code = '372'), '3725', 'paragraph-3725', 'Využívání a zneškodňování komunálních odpadů'),
  -- pododdíl 374
  ((SELECT id FROM functional_subdivisions WHERE code = '374'), '3741', 'paragraph-3741', 'Ochrana druhů a stanovišť'),
  ((SELECT id FROM functional_subdivisions WHERE code = '374'), '3742', 'paragraph-3742', 'Chráněné části přírody'),
  -- pododdíl 411 (důchody)
  ((SELECT id FROM functional_subdivisions WHERE code = '411'), '4111', 'paragraph-4111', 'Starobní důchody'),
  ((SELECT id FROM functional_subdivisions WHERE code = '411'), '4112', 'paragraph-4112', 'Invalidní důchody pro invaliditu třetího stupně'),
  ((SELECT id FROM functional_subdivisions WHERE code = '411'), '4113', 'paragraph-4113', 'Invalidní důchody pro invaliditu druhého stupně'),
  ((SELECT id FROM functional_subdivisions WHERE code = '411'), '4114', 'paragraph-4114', 'Vdovské důchody'),
  ((SELECT id FROM functional_subdivisions WHERE code = '411'), '4115', 'paragraph-4115', 'Vdovecké důchody'),
  ((SELECT id FROM functional_subdivisions WHERE code = '411'), '4116', 'paragraph-4116', 'Sirotčí důchody'),
  ((SELECT id FROM functional_subdivisions WHERE code = '411'), '4117', 'paragraph-4117', 'Invalidní důchody pro invaliditu prvního stupně'),
  -- pododdíl 412 (nemocenské)
  ((SELECT id FROM functional_subdivisions WHERE code = '412'), '4121', 'paragraph-4121', 'Nemocenské'),
  ((SELECT id FROM functional_subdivisions WHERE code = '412'), '4122', 'paragraph-4122', 'Ošetřovné'),
  ((SELECT id FROM functional_subdivisions WHERE code = '412'), '4124', 'paragraph-4124', 'Peněžitá pomoc v mateřství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '412'), '4125', 'paragraph-4125', 'Dávky otcovské poporodní péče'),
  ((SELECT id FROM functional_subdivisions WHERE code = '412'), '4126', 'paragraph-4126', 'Dlouhodobé ošetřovné'),
  -- pododdíl 413 (SSP)
  ((SELECT id FROM functional_subdivisions WHERE code = '413'), '4131', 'paragraph-4131', 'Přídavek na dítě'),
  ((SELECT id FROM functional_subdivisions WHERE code = '413'), '4133', 'paragraph-4133', 'Porodné'),
  ((SELECT id FROM functional_subdivisions WHERE code = '413'), '4134', 'paragraph-4134', 'Rodičovský příspěvek'),
  ((SELECT id FROM functional_subdivisions WHERE code = '413'), '4138', 'paragraph-4138', 'Pohřebné'),
  ((SELECT id FROM functional_subdivisions WHERE code = '413'), '4141', 'paragraph-4141', 'Příspěvek na bydlení'),
  -- pododdíl 414 (pěstounská péče)
  ((SELECT id FROM functional_subdivisions WHERE code = '414'), '4136', 'paragraph-4136', 'Dávky pěstounské péče a zaopatřovací příspěvky'),
  -- pododdíl 417 (hmotná nouze)
  ((SELECT id FROM functional_subdivisions WHERE code = '417'), '4171', 'paragraph-4171', 'Příspěvek na živobytí'),
  ((SELECT id FROM functional_subdivisions WHERE code = '417'), '4172', 'paragraph-4172', 'Doplatek na bydlení'),
  ((SELECT id FROM functional_subdivisions WHERE code = '417'), '4173', 'paragraph-4173', 'Mimořádná okamžitá pomoc'),
  -- pododdíl 418
  ((SELECT id FROM functional_subdivisions WHERE code = '418'), '4187', 'paragraph-4187', 'Příspěvek na mobilitu'),
  ((SELECT id FROM functional_subdivisions WHERE code = '418'), '4188', 'paragraph-4188', 'Příspěvek na zvláštní pomůcku'),
  -- pododdíl 419
  ((SELECT id FROM functional_subdivisions WHERE code = '419'), '4195', 'paragraph-4195', 'Příspěvek na péči'),
  -- pododdíl 421
  ((SELECT id FROM functional_subdivisions WHERE code = '421'), '4210', 'paragraph-4210', 'Podpory v nezaměstnanosti'),
  -- pododdíl 422
  ((SELECT id FROM functional_subdivisions WHERE code = '422'), '4221', 'paragraph-4221', 'Rekvalifikace'),
  ((SELECT id FROM functional_subdivisions WHERE code = '422'), '4222', 'paragraph-4222', 'Veřejně prospěšné práce'),
  ((SELECT id FROM functional_subdivisions WHERE code = '422'), '4223', 'paragraph-4223', 'Společensky účelná pracovní místa'),
  ((SELECT id FROM functional_subdivisions WHERE code = '422'), '4227', 'paragraph-4227', 'Cílené programy k řešení zaměstnanosti'),
  -- pododdíl 432
  ((SELECT id FROM functional_subdivisions WHERE code = '432'), '4324', 'paragraph-4324', 'Zařízení pro děti vyžadující okamžitou pomoc'),
  -- pododdíl 435 (sociální služby)
  ((SELECT id FROM functional_subdivisions WHERE code = '435'), '4350', 'paragraph-4350', 'Domovy pro seniory'),
  ((SELECT id FROM functional_subdivisions WHERE code = '435'), '4351', 'paragraph-4351', 'Osobní asistence, pečovatelská služba a podpora samostatného bydlení'),
  ((SELECT id FROM functional_subdivisions WHERE code = '435'), '4354', 'paragraph-4354', 'Chráněné bydlení'),
  ((SELECT id FROM functional_subdivisions WHERE code = '435'), '4356', 'paragraph-4356', 'Denní stacionáře a centra denních služeb'),
  ((SELECT id FROM functional_subdivisions WHERE code = '435'), '4357', 'paragraph-4357', 'Domovy pro osoby se zdravotním postižením a domovy se zvláštním režimem'),
  -- pododdíl 437
  ((SELECT id FROM functional_subdivisions WHERE code = '437'), '4374', 'paragraph-4374', 'Azylové domy, nízkoprahová denní centra a noclehárny'),
  -- pododdíl 511 (obrana)
  ((SELECT id FROM functional_subdivisions WHERE code = '511'), '5111', 'paragraph-5111', 'Armáda'),
  ((SELECT id FROM functional_subdivisions WHERE code = '511'), '5112', 'paragraph-5112', 'Ostatní ozbrojené síly'),
  ((SELECT id FROM functional_subdivisions WHERE code = '511'), '5113', 'paragraph-5113', 'Bezpečnostní složky ozbrojených sil'),
  ((SELECT id FROM functional_subdivisions WHERE code = '511'), '5119', 'paragraph-5119', 'Podpůrné složky ozbrojených sil'),
  -- pododdíl 517
  ((SELECT id FROM functional_subdivisions WHERE code = '517'), '5171', 'paragraph-5171', 'Zabezpečení potřeb ozbrojených sil'),
  -- pododdíl 531
  ((SELECT id FROM functional_subdivisions WHERE code = '531'), '5311', 'paragraph-5311', 'Bezpečnost a veřejný pořádek (Policie ČR)'),
  ((SELECT id FROM functional_subdivisions WHERE code = '531'), '5312', 'paragraph-5312', 'Opatření proti legalizaci výnosů z trestné činnosti a financování terorismu'),
  ((SELECT id FROM functional_subdivisions WHERE code = '531'), '5317', 'paragraph-5317', 'Hraniční přechody'),
  -- pododdíl 541
  ((SELECT id FROM functional_subdivisions WHERE code = '541'), '5410', 'paragraph-5410', 'Ústavní soud'),
  -- pododdíl 543
  ((SELECT id FROM functional_subdivisions WHERE code = '543'), '5430', 'paragraph-5430', 'Státní zastupitelství'),
  -- pododdíl 544
  ((SELECT id FROM functional_subdivisions WHERE code = '544'), '5441', 'paragraph-5441', 'Činnost Generálního ředitelství Vězeňské služby a věznic'),
  -- pododdíl 545
  ((SELECT id FROM functional_subdivisions WHERE code = '545'), '5450', 'paragraph-5450', 'Činnost probační a mediační služby'),
  -- pododdíl 547
  ((SELECT id FROM functional_subdivisions WHERE code = '547'), '5470', 'paragraph-5470', 'Kancelář veřejného ochránce práv a ochránce práv dětí'),
  -- pododdíl 551 (požární)
  ((SELECT id FROM functional_subdivisions WHERE code = '551'), '5511', 'paragraph-5511', 'Požární ochrana – profesionální část (HZS)'),
  ((SELECT id FROM functional_subdivisions WHERE code = '551'), '5512', 'paragraph-5512', 'Požární ochrana – dobrovolná část (SDH)'),
  ((SELECT id FROM functional_subdivisions WHERE code = '551'), '5517', 'paragraph-5517', 'Vzdělávací a technická zařízení požární ochrany'),
  -- pododdíl 552
  ((SELECT id FROM functional_subdivisions WHERE code = '552'), '5521', 'paragraph-5521', 'Operační a informační střediska integrovaného záchranného systému'),
  -- pododdíl 611 (volby)
  ((SELECT id FROM functional_subdivisions WHERE code = '611'), '6111', 'paragraph-6111', 'Parlament'),
  ((SELECT id FROM functional_subdivisions WHERE code = '611'), '6112', 'paragraph-6112', 'Zastupitelstva obcí'),
  ((SELECT id FROM functional_subdivisions WHERE code = '611'), '6113', 'paragraph-6113', 'Zastupitelstva krajů'),
  ((SELECT id FROM functional_subdivisions WHERE code = '611'), '6114', 'paragraph-6114', 'Volby do Parlamentu ČR'),
  ((SELECT id FROM functional_subdivisions WHERE code = '611'), '6115', 'paragraph-6115', 'Volby do zastupitelstev územních samosprávných celků'),
  ((SELECT id FROM functional_subdivisions WHERE code = '611'), '6117', 'paragraph-6117', 'Volby do Evropského parlamentu'),
  ((SELECT id FROM functional_subdivisions WHERE code = '611'), '6118', 'paragraph-6118', 'Volba prezidenta republiky'),
  -- pododdíl 612
  ((SELECT id FROM functional_subdivisions WHERE code = '612'), '6120', 'paragraph-6120', 'Kancelář prezidenta republiky'),
  -- pododdíl 613
  ((SELECT id FROM functional_subdivisions WHERE code = '613'), '6130', 'paragraph-6130', 'Nejvyšší kontrolní úřad'),
  -- pododdíl 614 (státní správa)
  ((SELECT id FROM functional_subdivisions WHERE code = '614'), '6141', 'paragraph-6141', 'Ústřední orgány vnitřní státní správy a jejich dislokovaná pracoviště'),
  ((SELECT id FROM functional_subdivisions WHERE code = '614'), '6142', 'paragraph-6142', 'Orgány Finanční správy České republiky'),
  ((SELECT id FROM functional_subdivisions WHERE code = '614'), '6143', 'paragraph-6143', 'Orgány Celní správy České republiky'),
  ((SELECT id FROM functional_subdivisions WHERE code = '614'), '6145', 'paragraph-6145', 'Úřad vlády'),
  ((SELECT id FROM functional_subdivisions WHERE code = '614'), '6146', 'paragraph-6146', 'Český statistický úřad'),
  -- pododdíl 615
  ((SELECT id FROM functional_subdivisions WHERE code = '615'), '6151', 'paragraph-6151', 'Činnost ústředního orgánu státní správy v zahraniční službě (MZV)'),
  ((SELECT id FROM functional_subdivisions WHERE code = '615'), '6152', 'paragraph-6152', 'Zastupitelství a stálé mise ČR v zahraničí'),
  -- pododdíl 617
  ((SELECT id FROM functional_subdivisions WHERE code = '617'), '6171', 'paragraph-6171', 'Činnost místní správy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '617'), '6172', 'paragraph-6172', 'Činnost regionální správy'),
  -- pododdíl 619
  ((SELECT id FROM functional_subdivisions WHERE code = '619'), '6190', 'paragraph-6190', 'Politické strany a hnutí'),
  -- pododdíl 621
  ((SELECT id FROM functional_subdivisions WHERE code = '621'), '6211', 'paragraph-6211', 'Archivní činnost'),
  -- pododdíl 622
  ((SELECT id FROM functional_subdivisions WHERE code = '622'), '6222', 'paragraph-6222', 'Rozvojová zahraniční pomoc'),
  ((SELECT id FROM functional_subdivisions WHERE code = '622'), '6224', 'paragraph-6224', 'Humanitární zahraniční pomoc prostřednictvím mezinárodních organizací'),
  -- pododdíl 631 (obsluha státního dluhu)
  ((SELECT id FROM functional_subdivisions WHERE code = '631'), '6310', 'paragraph-6310', 'Obecné příjmy a výdaje z finančních operací'),
  -- pododdíl 632
  ((SELECT id FROM functional_subdivisions WHERE code = '632'), '6320', 'paragraph-6320', 'Pojištění funkčně nespecifikované'),
  -- pododdíl 633
  ((SELECT id FROM functional_subdivisions WHERE code = '633'), '6330', 'paragraph-6330', 'Převody vlastním fondům v rozpočtech územní úrovně');

-- ===========================================================================
-- B. Economic classification (druhové třídění)
-- Source: vyhláška 412/2021 Sb. — třídy 1–6 + 8 (třída 7 v systému neexistuje)
-- ===========================================================================

INSERT INTO economic_classes (code, slug, name_cs) VALUES
  ('1', 'tax-revenue',         'Daňové příjmy'),
  ('2', 'non-tax-revenue',     'Nedaňové příjmy'),
  ('3', 'capital-revenue',     'Kapitálové příjmy'),
  ('4', 'received-transfers',  'Přijaté transfery'),
  ('5', 'current-expenditure', 'Běžné výdaje'),
  ('6', 'capital-expenditure', 'Kapitálové výdaje'),
  ('8', 'financing',           'Financování');

-- Seskupení položek (2-digit) — partial seed: only those nominally listed in
-- docs/budget-categorization.md. Missing groups will be appended by ETL using
-- ON CONFLICT semantics once we hit unknown codes in real data.
INSERT INTO economic_groups (class_id, code, slug, name_cs) VALUES
  -- třída 1 (daňové příjmy)
  ((SELECT id FROM economic_classes WHERE code = '1'), '11', 'econ-group-11', 'Daně z příjmů, zisku a kapitálových výnosů'),
  ((SELECT id FROM economic_classes WHERE code = '1'), '12', 'econ-group-12', 'Daně ze zboží a služeb'),
  ((SELECT id FROM economic_classes WHERE code = '1'), '13', 'econ-group-13', 'Daně a poplatky z vybraných činností a služeb'),
  ((SELECT id FROM economic_classes WHERE code = '1'), '16', 'econ-group-16', 'Pojistné na sociální zabezpečení a příspěvek na státní politiku zaměstnanosti'),
  -- třída 2
  ((SELECT id FROM economic_classes WHERE code = '2'), '21', 'econ-group-21', 'Příjmy z vlastní činnosti a odvody přebytků organizací s přímým vztahem'),
  ((SELECT id FROM economic_classes WHERE code = '2'), '22', 'econ-group-22', 'Přijaté sankční platby'),
  ((SELECT id FROM economic_classes WHERE code = '2'), '23', 'econ-group-23', 'Příjmy z prodeje nekapitálového majetku a ostatní nedaňové příjmy'),
  ((SELECT id FROM economic_classes WHERE code = '2'), '24', 'econ-group-24', 'Přijaté splátky půjčených prostředků'),
  -- třída 3
  ((SELECT id FROM economic_classes WHERE code = '3'), '31', 'econ-group-31', 'Příjmy z prodeje dlouhodobého majetku a ostatní kapitálové příjmy'),
  ((SELECT id FROM economic_classes WHERE code = '3'), '32', 'econ-group-32', 'Příjmy z prodeje akcií a majetkových podílů'),
  -- třída 4
  ((SELECT id FROM economic_classes WHERE code = '4'), '41', 'econ-group-41', 'Neinvestiční přijaté transfery'),
  ((SELECT id FROM economic_classes WHERE code = '4'), '42', 'econ-group-42', 'Investiční přijaté transfery'),
  -- třída 5
  ((SELECT id FROM economic_classes WHERE code = '5'), '50', 'econ-group-50', 'Platy a podobné a související výdaje'),
  ((SELECT id FROM economic_classes WHERE code = '5'), '51', 'econ-group-51', 'Neinvestiční nákupy a související výdaje'),
  ((SELECT id FROM economic_classes WHERE code = '5'), '53', 'econ-group-53', 'Neinvestiční transfery podnikatelským subjektům, neziskovým a jiným organizacím'),
  ((SELECT id FROM economic_classes WHERE code = '5'), '54', 'econ-group-54', 'Neinvestiční transfery obyvatelstvu'),
  -- třída 6
  ((SELECT id FROM economic_classes WHERE code = '6'), '61', 'econ-group-61', 'Investiční nákupy a související výdaje'),
  ((SELECT id FROM economic_classes WHERE code = '6'), '62', 'econ-group-62', 'Nákup akcií a majetkových podílů'),
  ((SELECT id FROM economic_classes WHERE code = '6'), '63', 'econ-group-63', 'Investiční transfery'),
  -- třída 8
  ((SELECT id FROM economic_classes WHERE code = '8'), '81', 'econ-group-81', 'Financování z tuzemska');

-- Položky (4-digit) — partial seed. Only items explicitly named in
-- docs/budget-categorization.md. ETL will append more as it discovers them.
INSERT INTO economic_items (group_id, code, slug, name_cs) VALUES
  -- skupina 11 (daně z příjmů)
  ((SELECT id FROM economic_groups WHERE code = '11'), '1111', 'econ-item-1111', 'Daň z příjmů fyzických osob placená plátci'),
  ((SELECT id FROM economic_groups WHERE code = '11'), '1112', 'econ-item-1112', 'Daň z příjmů fyzických osob placená poplatníky'),
  ((SELECT id FROM economic_groups WHERE code = '11'), '1113', 'econ-item-1113', 'Daň z příjmů fyzických osob — vybíraná srážkou'),
  ((SELECT id FROM economic_groups WHERE code = '11'), '1121', 'econ-item-1121', 'Daň z příjmů právnických osob'),
  -- skupina 12 (DPH)
  ((SELECT id FROM economic_groups WHERE code = '12'), '1211', 'econ-item-1211', 'Daň z přidané hodnoty'),
  -- skupina 16 (pojistné)
  ((SELECT id FROM economic_groups WHERE code = '16'), '1611', 'econ-item-1611', 'Pojistné na důchodové pojištění od zaměstnavatelů'),
  ((SELECT id FROM economic_groups WHERE code = '16'), '1612', 'econ-item-1612', 'Pojistné na důchodové pojištění od zaměstnanců'),
  ((SELECT id FROM economic_groups WHERE code = '16'), '1613', 'econ-item-1613', 'Pojistné na důchodové pojištění od osob samostatně výdělečně činných'),
  -- skupina 50 (platy)
  ((SELECT id FROM economic_groups WHERE code = '50'), '5011', 'econ-item-5011', 'Platy zaměstnanců v pracovním poměru'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5031', 'econ-item-5031', 'Povinné pojistné na sociální zabezpečení a příspěvek na státní politiku zaměstnanosti'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5032', 'econ-item-5032', 'Povinné pojistné na veřejné zdravotní pojištění'),
  -- skupina 51 (běžné nákupy)
  ((SELECT id FROM economic_groups WHERE code = '51'), '5139', 'econ-item-5139', 'Nákup materiálu jinde nezařazený'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5154', 'econ-item-5154', 'Elektrická energie'),
  -- skupina 54 (sociální dávky)
  ((SELECT id FROM economic_groups WHERE code = '54'), '5410', 'econ-item-5410', 'Sociální dávky'),
  -- skupina 61 (investiční nákupy)
  ((SELECT id FROM economic_groups WHERE code = '61'), '6121', 'econ-item-6121', 'Budovy, haly a stavby'),
  ((SELECT id FROM economic_groups WHERE code = '61'), '6122', 'econ-item-6122', 'Stroje, přístroje a zařízení'),
  -- skupina 62
  ((SELECT id FROM economic_groups WHERE code = '62'), '6201', 'econ-item-6201', 'Nákup akcií'),
  -- skupina 81 (financování)
  ((SELECT id FROM economic_groups WHERE code = '81'), '8111', 'econ-item-8111', 'Krátkodobé vydané dluhopisy'),
  ((SELECT id FROM economic_groups WHERE code = '81'), '8115', 'econ-item-8115', 'Změna stavu krátkodobých prostředků na bankovních účtech');

-- ===========================================================================
-- C. Chapters (kapitolové třídění)
-- Source: zákon č. 434/2024 Sb. o státním rozpočtu ČR na rok 2025
-- Slug = lowercase abbreviation, used as i18n key for chapter name.
-- ===========================================================================

INSERT INTO chapters (code, slug) VALUES
  -- Ústavní činitelé a kontrolní orgány
  ('301', 'kpr'),    -- Kancelář prezidenta republiky
  ('302', 'psp'),    -- Poslanecká sněmovna Parlamentu
  ('303', 'senat'),  -- Senát Parlamentu
  ('304', 'uv'),     -- Úřad vlády České republiky
  ('309', 'kvop'),   -- Kancelář veřejného ochránce práv
  ('358', 'us'),     -- Ústavní soud
  ('359', 'unrr'),   -- Úřad Národní rozpočtové rady
  ('381', 'nku'),    -- Nejvyšší kontrolní úřad
  -- Ministerstva
  ('306', 'mzv'),    -- Ministerstvo zahraničních věcí
  ('307', 'mo'),     -- Ministerstvo obrany
  ('312', 'mf'),     -- Ministerstvo financí
  ('313', 'mpsv'),   -- Ministerstvo práce a sociálních věcí
  ('314', 'mv'),     -- Ministerstvo vnitra
  ('315', 'mzp'),    -- Ministerstvo životního prostředí
  ('317', 'mmr'),    -- Ministerstvo pro místní rozvoj
  ('322', 'mpo'),    -- Ministerstvo průmyslu a obchodu
  ('327', 'md'),     -- Ministerstvo dopravy
  ('329', 'mze'),    -- Ministerstvo zemědělství
  ('333', 'msmt'),   -- Ministerstvo školství, mládeže a tělovýchovy
  ('334', 'mk'),     -- Ministerstvo kultury
  ('335', 'mzd'),    -- Ministerstvo zdravotnictví
  ('336', 'msp'),    -- Ministerstvo spravedlnosti
  -- Bezpečnostní a zpravodajské služby
  ('305', 'bis'),    -- Bezpečnostní informační služba
  ('308', 'nbu'),    -- Národní bezpečnostní úřad
  ('376', 'gibs'),   -- Generální inspekce bezpečnostních sborů
  ('378', 'nukib'),  -- Národní úřad pro kybernetickou a informační bezpečnost
  -- Regulační a kontrolní úřady
  ('328', 'ctu'),    -- Český telekomunikační úřad
  ('343', 'uoou'),   -- Úřad pro ochranu osobních údajů
  ('344', 'upv'),    -- Úřad průmyslového vlastnictví
  ('345', 'csu'),    -- Český statistický úřad
  ('346', 'cuzk'),   -- Český úřad zeměměřický a katastrální
  ('348', 'cbu'),    -- Český báňský úřad
  ('349', 'eru'),    -- Energetický regulační úřad
  ('353', 'uohs'),   -- Úřad pro ochranu hospodářské soutěže
  ('371', 'udhpsh'), -- Úřad pro dohled nad hospodařením politických stran a politických hnutí
  ('372', 'rrtv'),   -- Rada pro rozhlasové a televizní vysílání
  ('375', 'sujb'),   -- Státní úřad pro jadernou bezpečnost
  -- Věda, výzkum a inovace
  ('321', 'gacr'),   -- Grantová agentura ČR
  ('361', 'avcr'),   -- Akademie věd ČR
  ('377', 'tacr'),   -- Technologická agentura ČR
  -- Ostatní speciální orgány
  ('355', 'ustr'),   -- Ústav pro studium totalitních režimů
  ('362', 'nsa'),    -- Národní sportovní agentura
  ('364', 'dia'),    -- Digitální a informační agentura
  ('374', 'sshr'),   -- Správa státních hmotných rezerv
  -- Souhrnné kapitoly
  ('396', 'state-debt'), -- Státní dluh
  ('397', 'osfa'),       -- Operace státních finančních aktiv
  ('398', 'vps');        -- Všeobecná pokladní správa

-- ===========================================================================
-- D. Application layer — categories + paragraph mapping
-- Source: docs/budget-categorization.md
-- ===========================================================================

-- D.1 Categories (11 expense + 6 income, flat — no parent for MVP).
INSERT INTO categories (slug, type, is_mandatory) VALUES
  -- Expenses
  ('socialProtection',          'expense', TRUE),
  ('healthcare',                'expense', FALSE),
  ('education',                 'expense', FALSE),
  ('defenseAndSecurity',        'expense', FALSE),
  ('transport',                 'expense', FALSE),
  ('debtService',               'expense', TRUE),
  ('publicAdministration',      'expense', FALSE),
  ('municipalTransfers',        'expense', FALSE),
  ('environmentAndAgriculture', 'expense', FALSE),
  ('cultureAndSport',           'expense', FALSE),
  ('industryAndEconomy',        'expense', FALSE),
  -- Incomes
  ('vat',                       'income',  FALSE),
  ('incomeTax',                 'income',  FALSE),
  ('socialInsurance',           'income',  FALSE),
  ('exciseDuties',              'income',  FALSE),
  ('euTransfers',               'income',  FALSE),
  ('otherRevenue',              'income',  FALSE);

-- D.2 category_paragraph_map — UI category to functional paragraph mapping.
-- Generated by SELECT joining paragraphs to subdivisions, then filtering by
-- division code per docs/budget-categorization.md.

-- socialProtection ← oddíly 41, 42, 43
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'socialProtection'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (
  SELECT id FROM functional_divisions WHERE code IN ('41', '42', '43')
);

-- healthcare ← oddíl 35
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'healthcare'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id = (SELECT id FROM functional_divisions WHERE code = '35');

-- education ← oddíly 31, 32
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'education'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (
  SELECT id FROM functional_divisions WHERE code IN ('31', '32')
);

-- defenseAndSecurity ← oddíly 51, 52, 53, 55 (NOT 54)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'defenseAndSecurity'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (
  SELECT id FROM functional_divisions WHERE code IN ('51', '52', '53', '55')
);

-- transport ← oddíly 22, 23
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'transport'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (
  SELECT id FROM functional_divisions WHERE code IN ('22', '23')
);

-- debtService ← paragraf 6310 specifically
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'debtService'), id
FROM functional_paragraphs WHERE code = '6310';

-- publicAdministration ← oddíly 61, 62, 54 (UI override per doc)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'publicAdministration'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (
  SELECT id FROM functional_divisions WHERE code IN ('61', '62', '54')
);

-- environmentAndAgriculture ← oddíly 10, 37
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'environmentAndAgriculture'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (
  SELECT id FROM functional_divisions WHERE code IN ('10', '37')
);

-- cultureAndSport ← oddíly 33, 34 (UI override per doc)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'cultureAndSport'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (
  SELECT id FROM functional_divisions WHERE code IN ('33', '34')
);

-- industryAndEconomy ← oddíly 21, 24, 25
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'industryAndEconomy'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (
  SELECT id FROM functional_divisions WHERE code IN ('21', '24', '25')
);

-- NOTE: municipalTransfers has no entries in category_paragraph_map.
-- Per docs/budget-categorization.md, this category is cross-functional and
-- routes via kapitola 398 (VPS) — its aggregation will be handled at the
-- service/repository layer using a different rule, not by paragraph mapping.

-- NOTE: Income categories (vat, incomeTax, socialInsurance, exciseDuties,
-- euTransfers, otherRevenue) are NOT mapped to paragraphs. Income data flows
-- through economic_items (1xxx for daňové, 2xxx for nedaňové, etc.), not
-- through functional paragraphs. Income → category mapping will live in the
-- service layer once income ETL is in place.

-- NOTE: Drobné oddíly 36, 38, 39, 64 are intentionally NOT mapped here —
-- per docs/budget-categorization.md, their paragraphs need case-by-case
-- assignment based on content. To be resolved when budgetMapper service is
-- implemented.

-- Extend functional classification tree with full vyhláška coverage.
-- Source: vyhláška č. 412/2021 Sb., příloha č. 3, fetched from
--   https://www.zakonyprolidi.cz/cs/2021-412 (znění od 1. 1. 2026)
--
-- Migration 0002 seeded only paragrafy explicitly listed in
-- docs/budget-categorization.md (an illustrative selection, ~150 paragrafy).
-- This migration extends the tree to the full vyhláška coverage so that:
--   * UI categories industryAndEconomy and environmentAndAgriculture get
--     non-empty paragraph mappings
--   * "drobné" oddíly (36, 38, 39, 64) have paragraphs available for the
--     service layer to address case-by-case
--   * One data bug from 0002 is fixed (paragraf 4141 was placed under
--     pododdíl 413, vyhláška puts it under 414).
--
-- Idempotent strategy: refresh of category_paragraph_map uses
-- ON CONFLICT (category_id, paragraph_id) DO NOTHING — safe on re-run.

-- 1. Fix bug from 0002: paragraf 4141 was wrongly placed under pododdíl 413, belongs under 414
UPDATE functional_paragraphs SET subdivision_id = (SELECT id FROM functional_subdivisions WHERE code = '414') WHERE code = '4141';

-- 2. Add pododdíly missing in 0002
INSERT INTO functional_subdivisions (division_id, code, slug, name_cs) VALUES
  ((SELECT id FROM functional_divisions WHERE code = '10'), '109', 'subdivision-109', 'Ostatní činnost a nespecifikované výdaje'),
  ((SELECT id FROM functional_divisions WHERE code = '21'), '216', 'subdivision-216', 'Správa v odvětví energetiky, průmyslu, stavebnictví, obchodu a služeb'),
  ((SELECT id FROM functional_divisions WHERE code = '21'), '218', 'subdivision-218', 'Výzkum a vývoj v průmyslu, stavebnictví, obchodu a službách'),
  ((SELECT id FROM functional_divisions WHERE code = '21'), '219', 'subdivision-219', 'Ostatní činnost a nespecifikované výdaje'),
  ((SELECT id FROM functional_divisions WHERE code = '22'), '223', 'subdivision-223', 'Vnitrozemská a námořní plavba'),
  ((SELECT id FROM functional_divisions WHERE code = '22'), '227', 'subdivision-227', 'Doprava ostatních drah'),
  ((SELECT id FROM functional_divisions WHERE code = '22'), '228', 'subdivision-228', 'Výzkum v dopravě'),
  ((SELECT id FROM functional_divisions WHERE code = '22'), '229', 'subdivision-229', 'Ostatní činnost a nespecifikované výdaje v dopravě'),
  ((SELECT id FROM functional_divisions WHERE code = '23'), '234', 'subdivision-234', 'Voda v zemědělské krajině'),
  ((SELECT id FROM functional_divisions WHERE code = '23'), '236', 'subdivision-236', 'Správa ve vodním hospodářství'),
  ((SELECT id FROM functional_divisions WHERE code = '23'), '238', 'subdivision-238', 'Vodohospodářský výzkum a vývoj'),
  ((SELECT id FROM functional_divisions WHERE code = '23'), '239', 'subdivision-239', 'Ostatní činnost a nespecifikované výdaje'),
  ((SELECT id FROM functional_divisions WHERE code = '24'), '241', 'subdivision-241', 'Činnosti spojů'),
  ((SELECT id FROM functional_divisions WHERE code = '24'), '246', 'subdivision-246', 'Správa ve spojích'),
  ((SELECT id FROM functional_divisions WHERE code = '24'), '248', 'subdivision-248', 'Výzkum a vývoj ve spojích'),
  ((SELECT id FROM functional_divisions WHERE code = '24'), '249', 'subdivision-249', 'Ostatní činnost a nespecifikované výdaje ve spojích'),
  ((SELECT id FROM functional_divisions WHERE code = '25'), '252', 'subdivision-252', 'Všeobecné pracovní záležitosti'),
  ((SELECT id FROM functional_divisions WHERE code = '25'), '253', 'subdivision-253', 'Všeobecné finanční záležitosti'),
  ((SELECT id FROM functional_divisions WHERE code = '25'), '254', 'subdivision-254', 'Všeobecné hospodářské služby'),
  ((SELECT id FROM functional_divisions WHERE code = '25'), '256', 'subdivision-256', 'Všeobecná hospodářská správa'),
  ((SELECT id FROM functional_divisions WHERE code = '25'), '258', 'subdivision-258', 'Výzkum a vývoj v oblasti všeobecných hospodářských záležitostí'),
  ((SELECT id FROM functional_divisions WHERE code = '25'), '259', 'subdivision-259', 'Ostatní činnosti a nespecifikované výdaje'),
  ((SELECT id FROM functional_divisions WHERE code = '25'), '328', 'subdivision-328', 'Výzkum školství a vzdělávání'),
  ((SELECT id FROM functional_divisions WHERE code = '33'), '336', 'subdivision-336', 'Správa v oblasti kultury, církví a sdělovacích prostředků'),
  ((SELECT id FROM functional_divisions WHERE code = '33'), '338', 'subdivision-338', 'Výzkum a vývoj v oblasti kultury, církví a sdělovacích prostředků'),
  ((SELECT id FROM functional_divisions WHERE code = '33'), '339', 'subdivision-339', 'Ostatní činnosti v záležitostech kultury, církví a sdělovacích prostředků'),
  ((SELECT id FROM functional_divisions WHERE code = '34'), '346', 'subdivision-346', 'Správa v oblasti sportu'),
  ((SELECT id FROM functional_divisions WHERE code = '34'), '348', 'subdivision-348', 'Výzkum v oblasti sportu, zájmové činnosti a rekreace'),
  ((SELECT id FROM functional_divisions WHERE code = '35'), '358', 'subdivision-358', 'Výzkum a vývoj ve zdravotnictví'),
  ((SELECT id FROM functional_divisions WHERE code = '35'), '359', 'subdivision-359', 'Ostatní činnost ve zdravotnictví'),
  ((SELECT id FROM functional_divisions WHERE code = '36'), '366', 'subdivision-366', 'Správa v oblasti bydlení, komunálních služeb a územního rozvoje'),
  ((SELECT id FROM functional_divisions WHERE code = '36'), '368', 'subdivision-368', 'Výzkum a vývoj v oblasti bydlení, komunálních služeb a územního rozvoje'),
  ((SELECT id FROM functional_divisions WHERE code = '36'), '369', 'subdivision-369', 'Ostatní činnost v oblasti bydlení, komunálních služeb a územního rozvoje'),
  ((SELECT id FROM functional_divisions WHERE code = '37'), '375', 'subdivision-375', 'Omezování hluku a vibrací'),
  ((SELECT id FROM functional_divisions WHERE code = '37'), '376', 'subdivision-376', 'Správa v ochraně životního prostředí'),
  ((SELECT id FROM functional_divisions WHERE code = '37'), '377', 'subdivision-377', 'Ochrana proti záření'),
  ((SELECT id FROM functional_divisions WHERE code = '37'), '378', 'subdivision-378', 'Výzkum životního prostředí'),
  ((SELECT id FROM functional_divisions WHERE code = '37'), '379', 'subdivision-379', 'Ostatní činnosti v životním prostředí'),
  ((SELECT id FROM functional_divisions WHERE code = '38'), '380', 'subdivision-380', 'Ostatní výzkum a vývoj'),
  ((SELECT id FROM functional_divisions WHERE code = '39'), '390', 'subdivision-390', 'Ostatní činnosti související se službami pro fyzické osoby'),
  ((SELECT id FROM functional_divisions WHERE code = '41'), '415', 'subdivision-415', 'Zvláštní sociální dávky příslušníků ozbrojených sil a bezpečnostních sborů při skončení služebního poměru'),
  ((SELECT id FROM functional_divisions WHERE code = '42'), '423', 'subdivision-423', 'Ochrana zaměstnanců při platební neschopnosti zaměstnavatelů'),
  ((SELECT id FROM functional_divisions WHERE code = '42'), '424', 'subdivision-424', 'Zaměstnávání zdravotně postižených občanů'),
  ((SELECT id FROM functional_divisions WHERE code = '42'), '425', 'subdivision-425', 'Příspěvky na sociální důsledky restrukturalizace'),
  ((SELECT id FROM functional_divisions WHERE code = '42'), '428', 'subdivision-428', 'Výzkum a vývoj v politice zaměstnanosti'),
  ((SELECT id FROM functional_divisions WHERE code = '43'), '433', 'subdivision-433', 'Sociální péče a pomoc manželství a rodinám'),
  ((SELECT id FROM functional_divisions WHERE code = '43'), '434', 'subdivision-434', 'Sociální rehabilitace a ostatní sociální péče a pomoc'),
  ((SELECT id FROM functional_divisions WHERE code = '43'), '436', 'subdivision-436', 'Správa v sociálním zabezpečení a politice zaměstnanosti'),
  ((SELECT id FROM functional_divisions WHERE code = '43'), '438', 'subdivision-438', 'Výzkum v sociálním zabezpečení a politice zaměstnanosti'),
  ((SELECT id FROM functional_divisions WHERE code = '43'), '439', 'subdivision-439', 'Ostatní činnost a nespecifikované výdaje'),
  ((SELECT id FROM functional_divisions WHERE code = '51'), '516', 'subdivision-516', 'Státní správa ve vojenské obraně'),
  ((SELECT id FROM functional_divisions WHERE code = '51'), '518', 'subdivision-518', 'Výzkum a vývoj v oblasti obrany'),
  ((SELECT id FROM functional_divisions WHERE code = '51'), '519', 'subdivision-519', 'Ostatní záležitosti obrany'),
  ((SELECT id FROM functional_divisions WHERE code = '52'), '526', 'subdivision-526', 'Státní správa v oblasti hospodářských opatření'),
  ((SELECT id FROM functional_divisions WHERE code = '52'), '528', 'subdivision-528', 'Výzkum a vývoj v oblasti civilní připravenosti na krizové stavy'),
  ((SELECT id FROM functional_divisions WHERE code = '52'), '529', 'subdivision-529', 'Ostatní záležitosti civilní připravenosti pro krizové stavy'),
  ((SELECT id FROM functional_divisions WHERE code = '53'), '538', 'subdivision-538', 'Výzkum týkající se bezpečnosti a veřejného pořádku'),
  ((SELECT id FROM functional_divisions WHERE code = '53'), '539', 'subdivision-539', 'Ostatní záležitosti bezpečnosti a veřejného pořádku'),
  ((SELECT id FROM functional_divisions WHERE code = '54'), '546', 'subdivision-546', 'Správa v oblasti právní ochrany'),
  ((SELECT id FROM functional_divisions WHERE code = '54'), '548', 'subdivision-548', 'Výzkum v oblasti právní ochrany'),
  ((SELECT id FROM functional_divisions WHERE code = '54'), '549', 'subdivision-549', 'Ostatní záležitosti právní ochrany'),
  ((SELECT id FROM functional_divisions WHERE code = '55'), '556', 'subdivision-556', 'Státní správa v požární ochraně a integrovaném záchranném systému'),
  ((SELECT id FROM functional_divisions WHERE code = '55'), '558', 'subdivision-558', 'Výzkum a vývoj v požární ochraně a integrovaném záchranném systému'),
  ((SELECT id FROM functional_divisions WHERE code = '55'), '559', 'subdivision-559', 'Ostatní záležitosti požární ochrany a integrovaného záchranného systému'),
  ((SELECT id FROM functional_divisions WHERE code = '61'), '618', 'subdivision-618', 'Výzkum ve státní správě a samosprávě'),
  ((SELECT id FROM functional_divisions WHERE code = '63'), '639', 'subdivision-639', 'Ostatní finanční operace');

-- 3. Add paragrafy missing in 0002
INSERT INTO functional_paragraphs (subdivision_id, code, slug, name_cs) VALUES
  ((SELECT id FROM functional_subdivisions WHERE code = '101'), '1011', 'paragraph-1011', 'Udržování výrobního potenciálu zemědělství, zemědělský půdní fond a mimoprodukční funkce zemědělství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '101'), '1012', 'paragraph-1012', 'Podnikání a restrukturalizace v zemědělství a potravinářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '101'), '1013', 'paragraph-1013', 'Genetický potenciál hospodářských zvířat, osiv a sádí'),
  ((SELECT id FROM functional_subdivisions WHERE code = '101'), '1014', 'paragraph-1014', 'Ozdravování hospodářských zvířat, polních a speciálních plodin a zvláštní veterinární péče'),
  ((SELECT id FROM functional_subdivisions WHERE code = '101'), '1019', 'paragraph-1019', 'Ostatní zemědělská a potravinářská činnost a rozvoj'),
  ((SELECT id FROM functional_subdivisions WHERE code = '102'), '1021', 'paragraph-1021', 'Organizace trhu s produkty rostlinné výroby'),
  ((SELECT id FROM functional_subdivisions WHERE code = '102'), '1022', 'paragraph-1022', 'Organizace trhu s výrobky vzniklými zpracováním produktů rostlinné výroby'),
  ((SELECT id FROM functional_subdivisions WHERE code = '102'), '1023', 'paragraph-1023', 'Organizace trhu s produkty živočišné výroby'),
  ((SELECT id FROM functional_subdivisions WHERE code = '102'), '1024', 'paragraph-1024', 'Organizace trhu s výrobky vzniklými zpracováním produktů živočišné výroby'),
  ((SELECT id FROM functional_subdivisions WHERE code = '102'), '1029', 'paragraph-1029', 'Ostatní záležitosti regulace zemědělské produkce, organizace zemědělského trhu a poskytování podpor'),
  ((SELECT id FROM functional_subdivisions WHERE code = '103'), '1031', 'paragraph-1031', 'Pěstební činnost'),
  ((SELECT id FROM functional_subdivisions WHERE code = '103'), '1032', 'paragraph-1032', 'Podpora ostatních produkčních činností'),
  ((SELECT id FROM functional_subdivisions WHERE code = '103'), '1036', 'paragraph-1036', 'Správa v lesním hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '103'), '1037', 'paragraph-1037', 'Celospolečenské funkce lesů'),
  ((SELECT id FROM functional_subdivisions WHERE code = '103'), '1039', 'paragraph-1039', 'Ostatní záležitosti lesního hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '106'), '1061', 'paragraph-1061', 'Činnost ústředního orgánu státní správy v zemědělství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '106'), '1062', 'paragraph-1062', 'Činnost ostatních orgánů státní správy v zemědělství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '106'), '1063', 'paragraph-1063', 'Správa zemědělského majetku'),
  ((SELECT id FROM functional_subdivisions WHERE code = '106'), '1069', 'paragraph-1069', 'Ostatní správa v zemědělství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '107'), '1070', 'paragraph-1070', 'Rybářství a myslivost'),
  ((SELECT id FROM functional_subdivisions WHERE code = '108'), '1081', 'paragraph-1081', 'Zemědělský výzkum a vývoj'),
  ((SELECT id FROM functional_subdivisions WHERE code = '108'), '1082', 'paragraph-1082', 'Lesnický výzkum'),
  ((SELECT id FROM functional_subdivisions WHERE code = '109'), '1091', 'paragraph-1091', 'Mezinárodní spolupráce v zemědělství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '109'), '1092', 'paragraph-1092', 'Mezinárodní spolupráce v lesním hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '109'), '1098', 'paragraph-1098', 'Ostatní výdaje na zemědělství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '109'), '1099', 'paragraph-1099', 'Ostatní výdaje na lesní hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '211'), '2111', 'paragraph-2111', 'Uhelné hornictví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '211'), '2112', 'paragraph-2112', 'Těžba nerostných surovin kromě paliv'),
  ((SELECT id FROM functional_subdivisions WHERE code = '211'), '2113', 'paragraph-2113', 'Zpracování ropy a zemního plynu'),
  ((SELECT id FROM functional_subdivisions WHERE code = '211'), '2114', 'paragraph-2114', 'Jaderné elektrárny'),
  ((SELECT id FROM functional_subdivisions WHERE code = '211'), '2115', 'paragraph-2115', 'Úspora energie a obnovitelné zdroje'),
  ((SELECT id FROM functional_subdivisions WHERE code = '211'), '2116', 'paragraph-2116', 'Jaderné palivo a ochrana před ionizujícím zářením'),
  ((SELECT id FROM functional_subdivisions WHERE code = '211'), '2117', 'paragraph-2117', 'Elektrická energie'),
  ((SELECT id FROM functional_subdivisions WHERE code = '211'), '2118', 'paragraph-2118', 'Energie jiná než elektrická'),
  ((SELECT id FROM functional_subdivisions WHERE code = '211'), '2119', 'paragraph-2119', 'Ostatní záležitosti těžebního průmyslu a energetiky'),
  ((SELECT id FROM functional_subdivisions WHERE code = '212'), '2121', 'paragraph-2121', 'Stavebnictví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '212'), '2122', 'paragraph-2122', 'Sběr a zpracování druhotných surovin'),
  ((SELECT id FROM functional_subdivisions WHERE code = '212'), '2123', 'paragraph-2123', 'Podpora rozvoje průmyslových zón'),
  ((SELECT id FROM functional_subdivisions WHERE code = '212'), '2124', 'paragraph-2124', 'Opatření ke zvýšení konkurenceschopnosti průmyslových odvětví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '212'), '2125', 'paragraph-2125', 'Podpora podnikání a inovací'),
  ((SELECT id FROM functional_subdivisions WHERE code = '212'), '2129', 'paragraph-2129', 'Ostatní odvětvová a oborová opatření'),
  ((SELECT id FROM functional_subdivisions WHERE code = '213'), '2131', 'paragraph-2131', 'Přímá podpora exportu'),
  ((SELECT id FROM functional_subdivisions WHERE code = '213'), '2139', 'paragraph-2139', 'Ostatní záležitosti zahraničního obchodu'),
  ((SELECT id FROM functional_subdivisions WHERE code = '214'), '2141', 'paragraph-2141', 'Vnitřní obchod'),
  ((SELECT id FROM functional_subdivisions WHERE code = '214'), '2142', 'paragraph-2142', 'Ubytování a stravování'),
  ((SELECT id FROM functional_subdivisions WHERE code = '214'), '2143', 'paragraph-2143', 'Cestovní ruch'),
  ((SELECT id FROM functional_subdivisions WHERE code = '214'), '2144', 'paragraph-2144', 'Ostatní služby'),
  ((SELECT id FROM functional_subdivisions WHERE code = '216'), '2161', 'paragraph-2161', 'Činnost ústředního orgánu státní správy v odvětví energetiky, průmyslu, stavebnictví, obchodu a služeb'),
  ((SELECT id FROM functional_subdivisions WHERE code = '216'), '2162', 'paragraph-2162', 'Činnost ostatních orgánů státní správy v průmyslu, stavebnictví, obchodu a službách'),
  ((SELECT id FROM functional_subdivisions WHERE code = '216'), '2169', 'paragraph-2169', 'Ostatní správa v průmyslu, stavebnictví, obchodu a službách'),
  ((SELECT id FROM functional_subdivisions WHERE code = '218'), '2181', 'paragraph-2181', 'Výzkum a vývoj v palivech a energetice'),
  ((SELECT id FROM functional_subdivisions WHERE code = '218'), '2182', 'paragraph-2182', 'Výzkum a vývoj v průmyslu kromě paliv a energetiky'),
  ((SELECT id FROM functional_subdivisions WHERE code = '218'), '2183', 'paragraph-2183', 'Výzkum a vývoj ve službách'),
  ((SELECT id FROM functional_subdivisions WHERE code = '218'), '2184', 'paragraph-2184', 'Výzkum a vývoj v obchodu a cestovním ruchu'),
  ((SELECT id FROM functional_subdivisions WHERE code = '218'), '2185', 'paragraph-2185', 'Výzkum a vývoj ve stavebnictví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '219'), '2191', 'paragraph-2191', 'Mezinárodní spolupráce v průmyslu, stavebnictví, obchodu a službách'),
  ((SELECT id FROM functional_subdivisions WHERE code = '219'), '2199', 'paragraph-2199', 'Záležitosti průmyslu, stavebnictví, obchodu a služeb jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '222'), '2222', 'paragraph-2222', 'Kontrola technické způsobilosti vozidel'),
  ((SELECT id FROM functional_subdivisions WHERE code = '222'), '2229', 'paragraph-2229', 'Ostatní záležitosti v silniční dopravě'),
  ((SELECT id FROM functional_subdivisions WHERE code = '223'), '2231', 'paragraph-2231', 'Vodní cesty'),
  ((SELECT id FROM functional_subdivisions WHERE code = '223'), '2232', 'paragraph-2232', 'Provoz vnitrozemské plavby'),
  ((SELECT id FROM functional_subdivisions WHERE code = '223'), '2233', 'paragraph-2233', 'Záležitosti námořní dopravy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '223'), '2239', 'paragraph-2239', 'Ostatní záležitosti vnitrozemské plavby'),
  ((SELECT id FROM functional_subdivisions WHERE code = '224'), '2243', 'paragraph-2243', 'Drážní vozidla'),
  ((SELECT id FROM functional_subdivisions WHERE code = '224'), '2249', 'paragraph-2249', 'Ostatní záležitosti železniční dopravy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '225'), '2253', 'paragraph-2253', 'Provoz civilní letecké dopravy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '225'), '2259', 'paragraph-2259', 'Ostatní záležitosti civilní letecké dopravy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '226'), '2261', 'paragraph-2261', 'Činnost ústředních orgánů státní správy v dopravě'),
  ((SELECT id FROM functional_subdivisions WHERE code = '226'), '2262', 'paragraph-2262', 'Činnost ostatních orgánů státní správy v dopravě'),
  ((SELECT id FROM functional_subdivisions WHERE code = '227'), '2271', 'paragraph-2271', 'Ostatní dráhy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '227'), '2272', 'paragraph-2272', 'Provoz ostatních drah'),
  ((SELECT id FROM functional_subdivisions WHERE code = '227'), '2279', 'paragraph-2279', 'Záležitosti ostatních drah jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '228'), '2280', 'paragraph-2280', 'Výzkum a vývoj v dopravě'),
  ((SELECT id FROM functional_subdivisions WHERE code = '229'), '2291', 'paragraph-2291', 'Mezinárodní spolupráce v dopravě'),
  ((SELECT id FROM functional_subdivisions WHERE code = '229'), '2292', 'paragraph-2292', 'Dopravní obslužnost veřejnými službami - linková'),
  ((SELECT id FROM functional_subdivisions WHERE code = '229'), '2293', 'paragraph-2293', 'Dopravní obslužnost mimo veřejnou službu'),
  ((SELECT id FROM functional_subdivisions WHERE code = '229'), '2294', 'paragraph-2294', 'Dopravní obslužnost veřejnými službami - drážní'),
  ((SELECT id FROM functional_subdivisions WHERE code = '229'), '2295', 'paragraph-2295', 'Dopravní obslužnost veřejnými službami - smíšená'),
  ((SELECT id FROM functional_subdivisions WHERE code = '229'), '2299', 'paragraph-2299', 'Ostatní záležitosti v dopravě'),
  ((SELECT id FROM functional_subdivisions WHERE code = '231'), '2310', 'paragraph-2310', 'Pitná voda'),
  ((SELECT id FROM functional_subdivisions WHERE code = '232'), '2321', 'paragraph-2321', 'Odvádění a čistění odpadních vod a nakládání s kaly'),
  ((SELECT id FROM functional_subdivisions WHERE code = '232'), '2322', 'paragraph-2322', 'Prevence znečisťování vody'),
  ((SELECT id FROM functional_subdivisions WHERE code = '232'), '2329', 'paragraph-2329', 'Odvádění a čištění odpadních vod jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '233'), '2331', 'paragraph-2331', 'Úpravy vodohospodářsky významných a vodárenských toků'),
  ((SELECT id FROM functional_subdivisions WHERE code = '233'), '2332', 'paragraph-2332', 'Vodní díla na vodohospodářsky významných a vodárenských tocích'),
  ((SELECT id FROM functional_subdivisions WHERE code = '233'), '2333', 'paragraph-2333', 'Úpravy drobných vodních toků'),
  ((SELECT id FROM functional_subdivisions WHERE code = '233'), '2334', 'paragraph-2334', 'Revitalizace říčních systémů'),
  ((SELECT id FROM functional_subdivisions WHERE code = '233'), '2339', 'paragraph-2339', 'Záležitosti vodních toků a vodohospodářských děl jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '234'), '2341', 'paragraph-2341', 'Vodní díla v zemědělské krajině'),
  ((SELECT id FROM functional_subdivisions WHERE code = '234'), '2342', 'paragraph-2342', 'Protierozní ochrana'),
  ((SELECT id FROM functional_subdivisions WHERE code = '234'), '2349', 'paragraph-2349', 'Ostatní záležitosti vody v zemědělské krajině'),
  ((SELECT id FROM functional_subdivisions WHERE code = '236'), '2361', 'paragraph-2361', 'Činnost ústředních orgánů státní správy ve vodním hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '236'), '2362', 'paragraph-2362', 'Činnost ostatních orgánů státní správy ve vodním hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '236'), '2369', 'paragraph-2369', 'Ostatní správa ve vodním hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '238'), '2380', 'paragraph-2380', 'Vodohospodářský výzkum a vývoj'),
  ((SELECT id FROM functional_subdivisions WHERE code = '239'), '2391', 'paragraph-2391', 'Mezinárodní spolupráce v oblasti vodního hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '239'), '2399', 'paragraph-2399', 'Ostatní záležitosti vodního hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '241'), '2411', 'paragraph-2411', 'Záležitosti pošt'),
  ((SELECT id FROM functional_subdivisions WHERE code = '241'), '2412', 'paragraph-2412', 'Záležitosti telekomunikací'),
  ((SELECT id FROM functional_subdivisions WHERE code = '241'), '2413', 'paragraph-2413', 'Záležitosti radiokomunikací'),
  ((SELECT id FROM functional_subdivisions WHERE code = '241'), '2419', 'paragraph-2419', 'Ostatní záležitosti spojů'),
  ((SELECT id FROM functional_subdivisions WHERE code = '246'), '2461', 'paragraph-2461', 'Činnost ústředních orgánů státní správy ve spojích'),
  ((SELECT id FROM functional_subdivisions WHERE code = '246'), '2462', 'paragraph-2462', 'Činnost ostatních orgánů státní správy ve spojích'),
  ((SELECT id FROM functional_subdivisions WHERE code = '246'), '2469', 'paragraph-2469', 'Ostatní správa ve spojích'),
  ((SELECT id FROM functional_subdivisions WHERE code = '248'), '2480', 'paragraph-2480', 'Výzkum a vývoj ve spojích'),
  ((SELECT id FROM functional_subdivisions WHERE code = '249'), '2491', 'paragraph-2491', 'Mezinárodní spolupráce ve spojích'),
  ((SELECT id FROM functional_subdivisions WHERE code = '249'), '2499', 'paragraph-2499', 'Ostatní záležitosti spojů'),
  ((SELECT id FROM functional_subdivisions WHERE code = '251'), '2510', 'paragraph-2510', 'Podpora podnikání'),
  ((SELECT id FROM functional_subdivisions WHERE code = '252'), '2521', 'paragraph-2521', 'Bezpečnost práce'),
  ((SELECT id FROM functional_subdivisions WHERE code = '252'), '2529', 'paragraph-2529', 'Všeobecné pracovní záležitosti jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '253'), '2531', 'paragraph-2531', 'Česká národní banka a měna'),
  ((SELECT id FROM functional_subdivisions WHERE code = '253'), '2532', 'paragraph-2532', 'Úřad Národní rozpočtové rady'),
  ((SELECT id FROM functional_subdivisions WHERE code = '253'), '2539', 'paragraph-2539', 'Všeobecné finanční záležitosti jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '254'), '2541', 'paragraph-2541', 'Geologie'),
  ((SELECT id FROM functional_subdivisions WHERE code = '254'), '2542', 'paragraph-2542', 'Meteorologie'),
  ((SELECT id FROM functional_subdivisions WHERE code = '254'), '2549', 'paragraph-2549', 'Všeobecné hospodářské služby jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '256'), '2561', 'paragraph-2561', 'Činnost ústředních orgánů státní správy v oblasti hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '256'), '2562', 'paragraph-2562', 'Činnost ostatních orgánů a organizací v oblasti normalizace, standardizace a metrologie'),
  ((SELECT id FROM functional_subdivisions WHERE code = '256'), '2563', 'paragraph-2563', 'Činnost ostatních orgánů státní správy v zeměměřictví a katastru'),
  ((SELECT id FROM functional_subdivisions WHERE code = '256'), '2564', 'paragraph-2564', 'Správa národního majetku'),
  ((SELECT id FROM functional_subdivisions WHERE code = '256'), '2565', 'paragraph-2565', 'Činnost ostatních orgánů státní správy v oblasti bezpečnosti práce'),
  ((SELECT id FROM functional_subdivisions WHERE code = '256'), '2569', 'paragraph-2569', 'Všeobecná hospodářská správa jinde nezařazená'),
  ((SELECT id FROM functional_subdivisions WHERE code = '258'), '2580', 'paragraph-2580', 'Výzkum a vývoj v oblasti všeobecných hospodářských záležitostí'),
  ((SELECT id FROM functional_subdivisions WHERE code = '259'), '2590', 'paragraph-2590', 'Mezinárodní spolupráce ve všeobecných hospodářských záležitostech'),
  ((SELECT id FROM functional_subdivisions WHERE code = '311'), '3115', 'paragraph-3115', 'Ostatní záležitosti předškolního vzdělávání'),
  ((SELECT id FROM functional_subdivisions WHERE code = '311'), '3119', 'paragraph-3119', 'Ostatní záležitosti základního vzdělávání'),
  ((SELECT id FROM functional_subdivisions WHERE code = '312'), '3124', 'paragraph-3124', 'Střední školy a konzervatoře pro žáky se speciálními vzdělávacími potřebami'),
  ((SELECT id FROM functional_subdivisions WHERE code = '312'), '3125', 'paragraph-3125', 'Střediska praktického vyučování a školní hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '312'), '3127', 'paragraph-3127', 'Střední školy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '312'), '3128', 'paragraph-3128', 'Sportovní školy - gymnázia'),
  ((SELECT id FROM functional_subdivisions WHERE code = '312'), '3129', 'paragraph-3129', 'Ostatní zařízení středního vzdělávání'),
  ((SELECT id FROM functional_subdivisions WHERE code = '313'), '3132', 'paragraph-3132', 'Diagnostické ústavy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '313'), '3139', 'paragraph-3139', 'Ostatní školská zařízení pro výkon ústavní a ochranné výchovy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '314'), '3144', 'paragraph-3144', 'Školy v přírodě'),
  ((SELECT id FROM functional_subdivisions WHERE code = '314'), '3145', 'paragraph-3145', 'Internáty'),
  ((SELECT id FROM functional_subdivisions WHERE code = '314'), '3146', 'paragraph-3146', 'Zařízení výchovného poradenství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '314'), '3147', 'paragraph-3147', 'Domovy mládeže'),
  ((SELECT id FROM functional_subdivisions WHERE code = '314'), '3148', 'paragraph-3148', 'Střediska výchovné péče'),
  ((SELECT id FROM functional_subdivisions WHERE code = '314'), '3149', 'paragraph-3149', 'Ostatní zařízení související s výchovou a vzděláváním mládeže'),
  ((SELECT id FROM functional_subdivisions WHERE code = '322'), '3229', 'paragraph-3229', 'Ostatní zařízení související s vysokoškolským vzděláváním'),
  ((SELECT id FROM functional_subdivisions WHERE code = '323'), '3232', 'paragraph-3232', 'Jazykové školy s právem státní jazykové zkoušky'),
  ((SELECT id FROM functional_subdivisions WHERE code = '323'), '3233', 'paragraph-3233', 'Střediska volného času'),
  ((SELECT id FROM functional_subdivisions WHERE code = '323'), '3239', 'paragraph-3239', 'Záležitosti zájmového vzdělávání jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '326'), '3261', 'paragraph-3261', 'Činnost ústředního orgánu státní správy ve vzdělávání'),
  ((SELECT id FROM functional_subdivisions WHERE code = '326'), '3262', 'paragraph-3262', 'Činnost ostatních orgánů státní správy ve vzdělávání'),
  ((SELECT id FROM functional_subdivisions WHERE code = '326'), '3269', 'paragraph-3269', 'Ostatní správa ve vzdělávání jinde nezařazená'),
  ((SELECT id FROM functional_subdivisions WHERE code = '328'), '3280', 'paragraph-3280', 'Výzkum školství a vzdělávání'),
  ((SELECT id FROM functional_subdivisions WHERE code = '329'), '3291', 'paragraph-3291', 'Mezinárodní spolupráce ve vzdělávání'),
  ((SELECT id FROM functional_subdivisions WHERE code = '329'), '3292', 'paragraph-3292', 'Vzdělávání národnostních menšin a multikulturní výchova'),
  ((SELECT id FROM functional_subdivisions WHERE code = '329'), '3293', 'paragraph-3293', 'Vzdělávací akce k integraci Romů'),
  ((SELECT id FROM functional_subdivisions WHERE code = '329'), '3294', 'paragraph-3294', 'Zařízení pro další vzdělávání pedagogických pracovníků'),
  ((SELECT id FROM functional_subdivisions WHERE code = '331'), '3316', 'paragraph-3316', 'Vydavatelská činnost'),
  ((SELECT id FROM functional_subdivisions WHERE code = '331'), '3317', 'paragraph-3317', 'Výstavní činnosti v kultuře'),
  ((SELECT id FROM functional_subdivisions WHERE code = '332'), '3321', 'paragraph-3321', 'Činnosti památkových ústavů, hradů a zámků'),
  ((SELECT id FROM functional_subdivisions WHERE code = '332'), '3324', 'paragraph-3324', 'Výkup předmětů kulturní hodnoty'),
  ((SELECT id FROM functional_subdivisions WHERE code = '332'), '3326', 'paragraph-3326', 'Pořízení, zachování a obnova hodnot místního kulturního, národního a historického povědomí'),
  ((SELECT id FROM functional_subdivisions WHERE code = '332'), '3329', 'paragraph-3329', 'Ostatní záležitosti ochrany památek a péče o kulturní dědictví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '334'), '3349', 'paragraph-3349', 'Ostatní záležitosti sdělovacích prostředků'),
  ((SELECT id FROM functional_subdivisions WHERE code = '336'), '3361', 'paragraph-3361', 'Činnost ústředního orgánu státní správy v oblasti kultury a církví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '336'), '3362', 'paragraph-3362', 'Činnost ústředního orgánu státní správy v oblasti sdělovacích prostředků'),
  ((SELECT id FROM functional_subdivisions WHERE code = '336'), '3369', 'paragraph-3369', 'Ostatní správa v oblasti kultury, církví a sdělovacích prostředků'),
  ((SELECT id FROM functional_subdivisions WHERE code = '338'), '3380', 'paragraph-3380', 'Výzkum a vývoj v oblasti kultury, církví a sdělovacích prostředků'),
  ((SELECT id FROM functional_subdivisions WHERE code = '339'), '3391', 'paragraph-3391', 'Mezinárodní spolupráce v kultuře, církvích a sdělovacích prostředcích'),
  ((SELECT id FROM functional_subdivisions WHERE code = '339'), '3392', 'paragraph-3392', 'Zájmová činnost v kultuře'),
  ((SELECT id FROM functional_subdivisions WHERE code = '339'), '3399', 'paragraph-3399', 'Ostatní záležitosti kultury, církví a sdělovacích prostředků'),
  ((SELECT id FROM functional_subdivisions WHERE code = '346'), '3461', 'paragraph-3461', 'Činnost ústředního orgánu státní správy v oblasti sportu'),
  ((SELECT id FROM functional_subdivisions WHERE code = '348'), '3480', 'paragraph-3480', 'Výzkum v oblasti sportu, zájmové činnosti a rekreace'),
  ((SELECT id FROM functional_subdivisions WHERE code = '352'), '3529', 'paragraph-3529', 'Ostatní ústavní péče'),
  ((SELECT id FROM functional_subdivisions WHERE code = '353'), '3539', 'paragraph-3539', 'Ostatní zdravotnická zařízení a služby pro zdravotnictví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '354'), '3542', 'paragraph-3542', 'Prevence HIV/AIDS'),
  ((SELECT id FROM functional_subdivisions WHERE code = '354'), '3549', 'paragraph-3549', 'Ostatní speciální zdravotnická péče'),
  ((SELECT id FROM functional_subdivisions WHERE code = '356'), '3561', 'paragraph-3561', 'Činnost ústředního orgánu státní správy ve zdravotnictví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '356'), '3562', 'paragraph-3562', 'Činnost ostatních orgánů státní správy ve zdravotnictví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '356'), '3569', 'paragraph-3569', 'Ostatní správa ve zdravotnictví jinde nezařazená'),
  ((SELECT id FROM functional_subdivisions WHERE code = '358'), '3581', 'paragraph-3581', 'Organizace výzkumu a střediska vědeckých informací'),
  ((SELECT id FROM functional_subdivisions WHERE code = '358'), '3589', 'paragraph-3589', 'Ostatní výzkum a vývoj ve zdravotnictví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '359'), '3591', 'paragraph-3591', 'Mezinárodní spolupráce ve zdravotnictví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '359'), '3592', 'paragraph-3592', 'Další vzdělávání pracovníků ve zdravotnictví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '359'), '3599', 'paragraph-3599', 'Ostatní činnost ve zdravotnictví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '361'), '3611', 'paragraph-3611', 'Podpora individuální bytové výstavby'),
  ((SELECT id FROM functional_subdivisions WHERE code = '361'), '3612', 'paragraph-3612', 'Bytové hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '361'), '3613', 'paragraph-3613', 'Nebytové hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '361'), '3614', 'paragraph-3614', 'Bytové služby pro vlastní zaměstnance'),
  ((SELECT id FROM functional_subdivisions WHERE code = '361'), '3615', 'paragraph-3615', 'Podpora stavebního spoření a hypotečních úvěrů'),
  ((SELECT id FROM functional_subdivisions WHERE code = '361'), '3619', 'paragraph-3619', 'Ostatní rozvoj bydlení a bytového hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '363'), '3631', 'paragraph-3631', 'Veřejné osvětlení'),
  ((SELECT id FROM functional_subdivisions WHERE code = '363'), '3632', 'paragraph-3632', 'Pohřebnictví'),
  ((SELECT id FROM functional_subdivisions WHERE code = '363'), '3633', 'paragraph-3633', 'Výstavba a údržba místních inženýrských sítí'),
  ((SELECT id FROM functional_subdivisions WHERE code = '363'), '3634', 'paragraph-3634', 'Lokální zásobování teplem'),
  ((SELECT id FROM functional_subdivisions WHERE code = '363'), '3635', 'paragraph-3635', 'Územní plánování'),
  ((SELECT id FROM functional_subdivisions WHERE code = '363'), '3636', 'paragraph-3636', 'Územní rozvoj'),
  ((SELECT id FROM functional_subdivisions WHERE code = '363'), '3639', 'paragraph-3639', 'Komunální služby a územní rozvoj jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '366'), '3661', 'paragraph-3661', 'Činnost ústředního orgánu státní správy v oblasti bydlení, komunálních služeb a územního rozvoje'),
  ((SELECT id FROM functional_subdivisions WHERE code = '366'), '3662', 'paragraph-3662', 'Činnost ostatních orgánů státní správy v oblasti bydlení, komunálních služeb a územního rozvoje'),
  ((SELECT id FROM functional_subdivisions WHERE code = '366'), '3669', 'paragraph-3669', 'Ostatní správa v oblasti bydlení, komunálních služeb a územního rozvoje jinde nezařazená'),
  ((SELECT id FROM functional_subdivisions WHERE code = '368'), '3680', 'paragraph-3680', 'Výzkum a vývoj v oblasti bydlení, komunálních služeb a územního rozvoje'),
  ((SELECT id FROM functional_subdivisions WHERE code = '369'), '3691', 'paragraph-3691', 'Mezinárodní spolupráce v oblasti bydlení, komunálních služeb a územního rozvoje'),
  ((SELECT id FROM functional_subdivisions WHERE code = '369'), '3699', 'paragraph-3699', 'Ostatní záležitosti bydlení, komunálních služeb a územního rozvoje'),
  ((SELECT id FROM functional_subdivisions WHERE code = '371'), '3713', 'paragraph-3713', 'Změny technologií vytápění'),
  ((SELECT id FROM functional_subdivisions WHERE code = '371'), '3715', 'paragraph-3715', 'Změny výrobních technologií za účelem výrazného odstranění emisí'),
  ((SELECT id FROM functional_subdivisions WHERE code = '371'), '3719', 'paragraph-3719', 'Ostatní činnosti k ochraně ovzduší'),
  ((SELECT id FROM functional_subdivisions WHERE code = '372'), '3721', 'paragraph-3721', 'Sběr a svoz nebezpečných odpadů'),
  ((SELECT id FROM functional_subdivisions WHERE code = '372'), '3723', 'paragraph-3723', 'Sběr a svoz ostatních odpadů jiných než nebezpečných a komunálních'),
  ((SELECT id FROM functional_subdivisions WHERE code = '372'), '3724', 'paragraph-3724', 'Využívání a zneškodňování nebezpečných odpadů'),
  ((SELECT id FROM functional_subdivisions WHERE code = '372'), '3726', 'paragraph-3726', 'Využívání a zneškodňování ostatních odpadů'),
  ((SELECT id FROM functional_subdivisions WHERE code = '372'), '3727', 'paragraph-3727', 'Prevence vzniku odpadů'),
  ((SELECT id FROM functional_subdivisions WHERE code = '372'), '3728', 'paragraph-3728', 'Monitoring nakládání s odpady'),
  ((SELECT id FROM functional_subdivisions WHERE code = '372'), '3729', 'paragraph-3729', 'Ostatní nakládání s odpady'),
  ((SELECT id FROM functional_subdivisions WHERE code = '373'), '3731', 'paragraph-3731', 'Ochrana půdy a podzemní vody proti znečišťujícím infiltracím'),
  ((SELECT id FROM functional_subdivisions WHERE code = '373'), '3732', 'paragraph-3732', 'Dekontaminace půd a čištění spodní vody'),
  ((SELECT id FROM functional_subdivisions WHERE code = '373'), '3733', 'paragraph-3733', 'Monitoring půdy a podzemní vody'),
  ((SELECT id FROM functional_subdivisions WHERE code = '373'), '3734', 'paragraph-3734', 'Předcházení a sanace zasolení půd'),
  ((SELECT id FROM functional_subdivisions WHERE code = '373'), '3739', 'paragraph-3739', 'Ostatní ochrana půdy a spodní vody'),
  ((SELECT id FROM functional_subdivisions WHERE code = '374'), '3743', 'paragraph-3743', 'Rekultivace půdy v důsledku těžební a důlní činnosti, po skládkách odpadů apod.'),
  ((SELECT id FROM functional_subdivisions WHERE code = '374'), '3744', 'paragraph-3744', 'Protierozní, protilavinová a protipožární ochrana'),
  ((SELECT id FROM functional_subdivisions WHERE code = '374'), '3745', 'paragraph-3745', 'Péče o vzhled obcí a veřejnou zeleň'),
  ((SELECT id FROM functional_subdivisions WHERE code = '374'), '3749', 'paragraph-3749', 'Ostatní činnosti k ochraně přírody a krajiny'),
  ((SELECT id FROM functional_subdivisions WHERE code = '375'), '3751', 'paragraph-3751', 'Konstrukce a uplatnění protihlukových zařízení'),
  ((SELECT id FROM functional_subdivisions WHERE code = '375'), '3753', 'paragraph-3753', 'Monitoring ke zjišťování úrovně hluku a vibrací'),
  ((SELECT id FROM functional_subdivisions WHERE code = '375'), '3759', 'paragraph-3759', 'Ostatní činnosti k omezení hluku a vibrací'),
  ((SELECT id FROM functional_subdivisions WHERE code = '376'), '3761', 'paragraph-3761', 'Činnost ústředního orgánu státní správy v ochraně životního prostředí'),
  ((SELECT id FROM functional_subdivisions WHERE code = '376'), '3762', 'paragraph-3762', 'Činnost ostatních orgánů státní správy v ochraně životního prostředí'),
  ((SELECT id FROM functional_subdivisions WHERE code = '376'), '3769', 'paragraph-3769', 'Ostatní správa v ochraně životního prostředí'),
  ((SELECT id FROM functional_subdivisions WHERE code = '377'), '3771', 'paragraph-3771', 'Protiradonová opatření'),
  ((SELECT id FROM functional_subdivisions WHERE code = '377'), '3772', 'paragraph-3772', 'Přeprava a nakládání s radioaktivním odpadem'),
  ((SELECT id FROM functional_subdivisions WHERE code = '377'), '3773', 'paragraph-3773', 'Monitoring k zajišťování úrovně radioaktivního záření'),
  ((SELECT id FROM functional_subdivisions WHERE code = '377'), '3779', 'paragraph-3779', 'Ostatní činnosti k ochraně proti záření'),
  ((SELECT id FROM functional_subdivisions WHERE code = '378'), '3780', 'paragraph-3780', 'Výzkum životního prostředí'),
  ((SELECT id FROM functional_subdivisions WHERE code = '379'), '3791', 'paragraph-3791', 'Mezinárodní spolupráce v životním prostředí'),
  ((SELECT id FROM functional_subdivisions WHERE code = '379'), '3792', 'paragraph-3792', 'Ekologická výchova a osvěta'),
  ((SELECT id FROM functional_subdivisions WHERE code = '379'), '3793', 'paragraph-3793', 'Ekologie v dopravě'),
  ((SELECT id FROM functional_subdivisions WHERE code = '379'), '3799', 'paragraph-3799', 'Ostatní ekologické záležitosti'),
  ((SELECT id FROM functional_subdivisions WHERE code = '380'), '3801', 'paragraph-3801', 'Akademie věd České republiky'),
  ((SELECT id FROM functional_subdivisions WHERE code = '380'), '3802', 'paragraph-3802', 'Grantová agentura České republiky'),
  ((SELECT id FROM functional_subdivisions WHERE code = '380'), '3803', 'paragraph-3803', 'Technologická agentura České republiky'),
  ((SELECT id FROM functional_subdivisions WHERE code = '380'), '3809', 'paragraph-3809', 'Ostatní výzkum a vývoj odvětvově nespecifikovaný'),
  ((SELECT id FROM functional_subdivisions WHERE code = '390'), '3900', 'paragraph-3900', 'Ostatní činnosti související se službami pro fyzické osoby'),
  ((SELECT id FROM functional_subdivisions WHERE code = '411'), '4119', 'paragraph-4119', 'Ostatní dávky důchodového pojištění'),
  ((SELECT id FROM functional_subdivisions WHERE code = '412'), '4123', 'paragraph-4123', 'Vyrovnávací příspěvek v těhotenství a mateřství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '412'), '4129', 'paragraph-4129', 'Dávky nemocenského pojištění jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '413'), '4132', 'paragraph-4132', 'Sociální příplatek'),
  ((SELECT id FROM functional_subdivisions WHERE code = '414'), '4142', 'paragraph-4142', 'Příspěvek na školní pomůcky'),
  ((SELECT id FROM functional_subdivisions WHERE code = '414'), '4149', 'paragraph-4149', 'Dávky státní sociální podpory jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '415'), '4151', 'paragraph-4151', 'Odchodné'),
  ((SELECT id FROM functional_subdivisions WHERE code = '415'), '4152', 'paragraph-4152', 'Výsluhový příspěvek'),
  ((SELECT id FROM functional_subdivisions WHERE code = '415'), '4153', 'paragraph-4153', 'Úmrtné a příspěvek na pohřeb příslušníka'),
  ((SELECT id FROM functional_subdivisions WHERE code = '415'), '4154', 'paragraph-4154', 'Odbytné'),
  ((SELECT id FROM functional_subdivisions WHERE code = '415'), '4159', 'paragraph-4159', 'Ostatní sociální dávky příslušníků ozbrojených sil a bezpečnostních sborů při skončení služebního poměru'),
  ((SELECT id FROM functional_subdivisions WHERE code = '417'), '4177', 'paragraph-4177', 'Mimořádná okamžitá pomoc osobám ohroženým sociálním vyloučením'),
  ((SELECT id FROM functional_subdivisions WHERE code = '417'), '4179', 'paragraph-4179', 'Ostatní dávky sociální pomoci'),
  ((SELECT id FROM functional_subdivisions WHERE code = '418'), '4182', 'paragraph-4182', 'Příspěvek na zvláštní pomůcky'),
  ((SELECT id FROM functional_subdivisions WHERE code = '418'), '4183', 'paragraph-4183', 'Příspěvek na úpravu a provoz bezbariérového bytu'),
  ((SELECT id FROM functional_subdivisions WHERE code = '418'), '4184', 'paragraph-4184', 'Příspěvky na zakoupení, opravu a zvláštní úpravu motorového vozidla'),
  ((SELECT id FROM functional_subdivisions WHERE code = '418'), '4185', 'paragraph-4185', 'Příspěvek na provoz motorového vozidla'),
  ((SELECT id FROM functional_subdivisions WHERE code = '418'), '4186', 'paragraph-4186', 'Příspěvek na individuální dopravu'),
  ((SELECT id FROM functional_subdivisions WHERE code = '418'), '4189', 'paragraph-4189', 'Ostatní dávky zdravotně postiženým občanům'),
  ((SELECT id FROM functional_subdivisions WHERE code = '419'), '4191', 'paragraph-4191', 'Státní příspěvky na důchodové připojištění'),
  ((SELECT id FROM functional_subdivisions WHERE code = '419'), '4192', 'paragraph-4192', 'Úrokové příspěvky mladým manželstvím'),
  ((SELECT id FROM functional_subdivisions WHERE code = '419'), '4193', 'paragraph-4193', 'Dávky válečným veteránům a perzekvovaným osobám'),
  ((SELECT id FROM functional_subdivisions WHERE code = '419'), '4194', 'paragraph-4194', 'Zvýšení důchodů pro bezmocnost'),
  ((SELECT id FROM functional_subdivisions WHERE code = '419'), '4196', 'paragraph-4196', 'Náhradní výživné pro nezaopatřené dítě'),
  ((SELECT id FROM functional_subdivisions WHERE code = '419'), '4197', 'paragraph-4197', 'Dávka státní sociální pomoci'),
  ((SELECT id FROM functional_subdivisions WHERE code = '419'), '4199', 'paragraph-4199', 'Ostatní dávky povahy sociálního zabezpečení jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '422'), '4225', 'paragraph-4225', 'Podpora zaměstnanosti zdravotně postižených občanů'),
  ((SELECT id FROM functional_subdivisions WHERE code = '422'), '4226', 'paragraph-4226', 'Ostatní podpora zaměstnanosti'),
  ((SELECT id FROM functional_subdivisions WHERE code = '422'), '4229', 'paragraph-4229', 'Aktivní politika zaměstnanosti jinde nezařazená'),
  ((SELECT id FROM functional_subdivisions WHERE code = '423'), '4230', 'paragraph-4230', 'Ochrana zaměstnanců při platební neschopnosti zaměstnavatelů'),
  ((SELECT id FROM functional_subdivisions WHERE code = '424'), '4240', 'paragraph-4240', 'Příspěvek na podporu zaměstnávání osob se zdravotním postižením na chráněném trhu práce'),
  ((SELECT id FROM functional_subdivisions WHERE code = '425'), '4250', 'paragraph-4250', 'Příspěvky na sociální důsledky restrukturalizace'),
  ((SELECT id FROM functional_subdivisions WHERE code = '428'), '4280', 'paragraph-4280', 'Výzkum a vývoj v politice zaměstnanosti'),
  ((SELECT id FROM functional_subdivisions WHERE code = '431'), '4311', 'paragraph-4311', 'Základní sociální poradenství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '431'), '4312', 'paragraph-4312', 'Odborné sociální poradenství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '431'), '4319', 'paragraph-4319', 'Ostatní výdaje související se sociálním poradenstvím'),
  ((SELECT id FROM functional_subdivisions WHERE code = '432'), '4329', 'paragraph-4329', 'Ostatní sociální péče a pomoc dětem a mládeži'),
  ((SELECT id FROM functional_subdivisions WHERE code = '433'), '4334', 'paragraph-4334', 'Pečovatelská služba pro rodinu a děti'),
  ((SELECT id FROM functional_subdivisions WHERE code = '433'), '4339', 'paragraph-4339', 'Ostatní sociální péče a pomoc rodině a manželství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '434'), '4341', 'paragraph-4341', 'Sociální pomoc osobám v hmotné nouzi a občanům sociálně nepřizpůsobivým'),
  ((SELECT id FROM functional_subdivisions WHERE code = '434'), '4342', 'paragraph-4342', 'Sociální péče a pomoc přistěhovalcům a vybraným etnikům'),
  ((SELECT id FROM functional_subdivisions WHERE code = '434'), '4343', 'paragraph-4343', 'Sociální pomoc osobám v souvislosti s živelní pohromou nebo požárem'),
  ((SELECT id FROM functional_subdivisions WHERE code = '434'), '4344', 'paragraph-4344', 'Sociální rehabilitace'),
  ((SELECT id FROM functional_subdivisions WHERE code = '434'), '4345', 'paragraph-4345', 'Centra sociálně rehabilitačních služeb'),
  ((SELECT id FROM functional_subdivisions WHERE code = '434'), '4349', 'paragraph-4349', 'Ostatní sociální péče a pomoc ostatním skupinám fyzických osob'),
  ((SELECT id FROM functional_subdivisions WHERE code = '435'), '4352', 'paragraph-4352', 'Tísňová péče'),
  ((SELECT id FROM functional_subdivisions WHERE code = '435'), '4353', 'paragraph-4353', 'Průvodcovské a předčitatelské služby'),
  ((SELECT id FROM functional_subdivisions WHERE code = '435'), '4355', 'paragraph-4355', 'Týdenní stacionáře'),
  ((SELECT id FROM functional_subdivisions WHERE code = '435'), '4358', 'paragraph-4358', 'Sociální služby poskytované ve zdravotnických zařízeních ústavní péče'),
  ((SELECT id FROM functional_subdivisions WHERE code = '435'), '4359', 'paragraph-4359', 'Ostatní služby a činnosti v oblasti sociální péče'),
  ((SELECT id FROM functional_subdivisions WHERE code = '436'), '4361', 'paragraph-4361', 'Činnost ústředního orgánu státní správy v sociálním zabezpečení, politice zaměstnanosti a rodinné politice'),
  ((SELECT id FROM functional_subdivisions WHERE code = '436'), '4362', 'paragraph-4362', 'Činnost ostatních orgánů státní správy v sociálním zabezpečení'),
  ((SELECT id FROM functional_subdivisions WHERE code = '436'), '4363', 'paragraph-4363', 'Ostatní orgány státní správy v oblasti politiky zaměstnanosti'),
  ((SELECT id FROM functional_subdivisions WHERE code = '436'), '4369', 'paragraph-4369', 'Ostatní správa v sociálním zabezpečení a politice zaměstnanosti'),
  ((SELECT id FROM functional_subdivisions WHERE code = '437'), '4371', 'paragraph-4371', 'Raná péče a sociálně aktivizační služby pro rodiny s dětmi'),
  ((SELECT id FROM functional_subdivisions WHERE code = '437'), '4372', 'paragraph-4372', 'Krizová pomoc'),
  ((SELECT id FROM functional_subdivisions WHERE code = '437'), '4373', 'paragraph-4373', 'Domy na půl cesty'),
  ((SELECT id FROM functional_subdivisions WHERE code = '437'), '4375', 'paragraph-4375', 'Nízkoprahová zařízení pro děti a mládež'),
  ((SELECT id FROM functional_subdivisions WHERE code = '437'), '4376', 'paragraph-4376', 'Služby následné péče, terapeutické komunity a kontaktní centra'),
  ((SELECT id FROM functional_subdivisions WHERE code = '437'), '4377', 'paragraph-4377', 'Sociálně terapeutické dílny'),
  ((SELECT id FROM functional_subdivisions WHERE code = '437'), '4378', 'paragraph-4378', 'Terénní programy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '437'), '4379', 'paragraph-4379', 'Ostatní služby a činnosti v oblasti sociální prevence'),
  ((SELECT id FROM functional_subdivisions WHERE code = '438'), '4380', 'paragraph-4380', 'Výzkum v sociálním zabezpečení a politice zaměstnanosti'),
  ((SELECT id FROM functional_subdivisions WHERE code = '439'), '4391', 'paragraph-4391', 'Mezinárodní spolupráce v sociálním zabezpečení a podpoře zaměstnanosti'),
  ((SELECT id FROM functional_subdivisions WHERE code = '439'), '4392', 'paragraph-4392', 'Inspekce poskytování sociálních služeb'),
  ((SELECT id FROM functional_subdivisions WHERE code = '439'), '4399', 'paragraph-4399', 'Ostatní záležitosti sociálních věcí a politiky zaměstnanosti'),
  ((SELECT id FROM functional_subdivisions WHERE code = '516'), '5161', 'paragraph-5161', 'Činnost ústředního orgánu státní správy ve vojenské obraně'),
  ((SELECT id FROM functional_subdivisions WHERE code = '516'), '5162', 'paragraph-5162', 'Činnost ostatních orgánů státní správy ve vojenské obraně'),
  ((SELECT id FROM functional_subdivisions WHERE code = '516'), '5169', 'paragraph-5169', 'Ostatní správa ve vojenské obraně'),
  ((SELECT id FROM functional_subdivisions WHERE code = '517'), '5172', 'paragraph-5172', 'Operační příprava státního území'),
  ((SELECT id FROM functional_subdivisions WHERE code = '517'), '5179', 'paragraph-5179', 'Ostatní činnosti pro zabezpečení potřeb ozbrojených sil'),
  ((SELECT id FROM functional_subdivisions WHERE code = '518'), '5180', 'paragraph-5180', 'Výzkum a vývoj v oblasti obrany'),
  ((SELECT id FROM functional_subdivisions WHERE code = '519'), '5191', 'paragraph-5191', 'Mezinárodní spolupráce v obraně'),
  ((SELECT id FROM functional_subdivisions WHERE code = '519'), '5192', 'paragraph-5192', 'Zahraniční vojenská pomoc'),
  ((SELECT id FROM functional_subdivisions WHERE code = '519'), '5199', 'paragraph-5199', 'Ostatní záležitosti obrany'),
  ((SELECT id FROM functional_subdivisions WHERE code = '521'), '5211', 'paragraph-5211', 'Civilní ochrana - vojenská část'),
  ((SELECT id FROM functional_subdivisions WHERE code = '521'), '5212', 'paragraph-5212', 'Ochrana obyvatelstva'),
  ((SELECT id FROM functional_subdivisions WHERE code = '521'), '5213', 'paragraph-5213', 'Krizová opatření'),
  ((SELECT id FROM functional_subdivisions WHERE code = '521'), '5219', 'paragraph-5219', 'Ostatní záležitosti ochrany fyzických osob'),
  ((SELECT id FROM functional_subdivisions WHERE code = '522'), '5220', 'paragraph-5220', 'Hospodářská opatření pro krizové stavy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '526'), '5261', 'paragraph-5261', 'Státní správa v oblasti hospodářských opatření pro krizové stavy a v oblasti krizového řízení'),
  ((SELECT id FROM functional_subdivisions WHERE code = '526'), '5262', 'paragraph-5262', 'Činnost ostatních orgánů státní správy v oblasti civilního nouzového hospodářství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '526'), '5269', 'paragraph-5269', 'Ostatní správa v oblasti hospodářských opatření pro krizové stavy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '527'), '5271', 'paragraph-5271', 'Činnost orgánů krizového řízení na ústřední úrovni a dalších správních úřadů v oblasti krizového řízení'),
  ((SELECT id FROM functional_subdivisions WHERE code = '527'), '5272', 'paragraph-5272', 'Činnost orgánů krizového řízení na územní úrovni a dalších územních správních úřadů v oblasti krizového řízení'),
  ((SELECT id FROM functional_subdivisions WHERE code = '527'), '5273', 'paragraph-5273', 'Ostatní správa v oblasti krizového řízení'),
  ((SELECT id FROM functional_subdivisions WHERE code = '527'), '5274', 'paragraph-5274', 'Podpora krizového řízení a nouzového plánování'),
  ((SELECT id FROM functional_subdivisions WHERE code = '527'), '5279', 'paragraph-5279', 'Záležitosti krizového řízení jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '528'), '5281', 'paragraph-5281', 'Výzkum a vývoj v oblasti ochrany fyzických osob'),
  ((SELECT id FROM functional_subdivisions WHERE code = '528'), '5289', 'paragraph-5289', 'Výzkum a vývoj v oblasti krizového řízení'),
  ((SELECT id FROM functional_subdivisions WHERE code = '529'), '5291', 'paragraph-5291', 'Mezinárodní spolupráce v oblasti krizového řízení'),
  ((SELECT id FROM functional_subdivisions WHERE code = '529'), '5292', 'paragraph-5292', 'Poskytnutí vzájemné zahraniční pomoci podle mezinárodních smluv'),
  ((SELECT id FROM functional_subdivisions WHERE code = '529'), '5299', 'paragraph-5299', 'Ostatní záležitosti civilní připravenosti na krizové stavy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '531'), '5316', 'paragraph-5316', 'Činnost ústředního orgánu státní správy v oblasti bezpečnosti a veřejného pořádku'),
  ((SELECT id FROM functional_subdivisions WHERE code = '531'), '5319', 'paragraph-5319', 'Ostatní záležitosti bezpečnosti a veřejného pořádku'),
  ((SELECT id FROM functional_subdivisions WHERE code = '538'), '5380', 'paragraph-5380', 'Výzkum týkající se bezpečnosti a veřejného pořádku'),
  ((SELECT id FROM functional_subdivisions WHERE code = '539'), '5391', 'paragraph-5391', 'Mezinárodní spolupráce v oblasti bezpečnosti a veřejného pořádku'),
  ((SELECT id FROM functional_subdivisions WHERE code = '539'), '5399', 'paragraph-5399', 'Ostatní záležitosti bezpečnosti, veřejného pořádku'),
  ((SELECT id FROM functional_subdivisions WHERE code = '542'), '5420', 'paragraph-5420', 'Soudy'),
  ((SELECT id FROM functional_subdivisions WHERE code = '544'), '5442', 'paragraph-5442', 'Ostatní správa ve vězeňství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '544'), '5449', 'paragraph-5449', 'Ostatní záležitosti vězeňství'),
  ((SELECT id FROM functional_subdivisions WHERE code = '546'), '5461', 'paragraph-5461', 'Činnost ústředního orgánu státní správy v oblasti právní ochrany'),
  ((SELECT id FROM functional_subdivisions WHERE code = '546'), '5462', 'paragraph-5462', 'Činnost ostatních orgánů státní správy v oblasti právní ochrany'),
  ((SELECT id FROM functional_subdivisions WHERE code = '546'), '5469', 'paragraph-5469', 'Ostatní správa v oblasti právní ochrany'),
  ((SELECT id FROM functional_subdivisions WHERE code = '547'), '5471', 'paragraph-5471', 'Kancelář finančního arbitra'),
  ((SELECT id FROM functional_subdivisions WHERE code = '548'), '5480', 'paragraph-5480', 'Výzkum v oblasti právní ochrany'),
  ((SELECT id FROM functional_subdivisions WHERE code = '549'), '5491', 'paragraph-5491', 'Mezinárodní spolupráce v oblasti právní ochrany'),
  ((SELECT id FROM functional_subdivisions WHERE code = '549'), '5499', 'paragraph-5499', 'Ostatní záležitosti právní ochrany'),
  ((SELECT id FROM functional_subdivisions WHERE code = '551'), '5519', 'paragraph-5519', 'Ostatní záležitosti požární ochrany'),
  ((SELECT id FROM functional_subdivisions WHERE code = '552'), '5522', 'paragraph-5522', 'Ostatní činnosti v integrovaném záchranném systému'),
  ((SELECT id FROM functional_subdivisions WHERE code = '552'), '5529', 'paragraph-5529', 'Ostatní složky a činnosti integrovaného záchranného systému'),
  ((SELECT id FROM functional_subdivisions WHERE code = '556'), '5561', 'paragraph-5561', 'Činnost ústředního orgánu státní správy v požární ochraně'),
  ((SELECT id FROM functional_subdivisions WHERE code = '556'), '5562', 'paragraph-5562', 'Činnost ústředních orgánů státní správy v integrovaném záchranném systému'),
  ((SELECT id FROM functional_subdivisions WHERE code = '556'), '5563', 'paragraph-5563', 'Činnost ostatních orgánů státní správy v integrovaném záchranném systému'),
  ((SELECT id FROM functional_subdivisions WHERE code = '558'), '5580', 'paragraph-5580', 'Výzkum a vývoj v požární ochraně a integrovaném záchranném systému'),
  ((SELECT id FROM functional_subdivisions WHERE code = '559'), '5591', 'paragraph-5591', 'Mezinárodní spolupráce v oblasti požární ochrany a integrovaném záchranném systému'),
  ((SELECT id FROM functional_subdivisions WHERE code = '559'), '5592', 'paragraph-5592', 'Poskytnutí vzájemné zahraniční pomoci podle mezinárodních smluv'),
  ((SELECT id FROM functional_subdivisions WHERE code = '559'), '5599', 'paragraph-5599', 'Ostatní záležitosti požární ochrany a integrovaného záchranného systému'),
  ((SELECT id FROM functional_subdivisions WHERE code = '611'), '6116', 'paragraph-6116', 'Celostátní referendum'),
  ((SELECT id FROM functional_subdivisions WHERE code = '611'), '6119', 'paragraph-6119', 'Ostatní zastupitelské orgány a volby'),
  ((SELECT id FROM functional_subdivisions WHERE code = '614'), '6148', 'paragraph-6148', 'Plánování a statistika'),
  ((SELECT id FROM functional_subdivisions WHERE code = '614'), '6149', 'paragraph-6149', 'Ostatní všeobecná vnitřní správa jinde nezařazená'),
  ((SELECT id FROM functional_subdivisions WHERE code = '615'), '6153', 'paragraph-6153', 'Ostatní účast v mezinárodních vládních organizacích'),
  ((SELECT id FROM functional_subdivisions WHERE code = '615'), '6159', 'paragraph-6159', 'Zahraniční služba a záležitosti jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '617'), '6173', 'paragraph-6173', 'Místní referendum'),
  ((SELECT id FROM functional_subdivisions WHERE code = '618'), '6180', 'paragraph-6180', 'Výzkum ve státní správě a samosprávě'),
  ((SELECT id FROM functional_subdivisions WHERE code = '621'), '6219', 'paragraph-6219', 'Ostatní veřejné služby jinde nezařazené'),
  ((SELECT id FROM functional_subdivisions WHERE code = '622'), '6221', 'paragraph-6221', 'Humanitární zahraniční pomoc přímá'),
  ((SELECT id FROM functional_subdivisions WHERE code = '622'), '6223', 'paragraph-6223', 'Mezinárodní spolupráce jinde nezařazená'),
  ((SELECT id FROM functional_subdivisions WHERE code = '622'), '6229', 'paragraph-6229', 'Ostatní zahraniční pomoc'),
  ((SELECT id FROM functional_subdivisions WHERE code = '639'), '6391', 'paragraph-6391', 'Soudní a mimosoudní rehabilitace'),
  ((SELECT id FROM functional_subdivisions WHERE code = '639'), '6399', 'paragraph-6399', 'Ostatní finanční operace'),
  ((SELECT id FROM functional_subdivisions WHERE code = '640'), '6401', 'paragraph-6401', 'Transfery všeobecné povahy jiným úrovním vlády'),
  ((SELECT id FROM functional_subdivisions WHERE code = '640'), '6402', 'paragraph-6402', 'Finanční vypořádání'),
  ((SELECT id FROM functional_subdivisions WHERE code = '640'), '6409', 'paragraph-6409', 'Ostatní činnosti jinde nezařazené');

-- 4. Refresh category_paragraph_map for new paragrafy (idempotent via ON CONFLICT)

INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'socialProtection'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (SELECT id FROM functional_divisions WHERE code IN ('41', '42', '43'))
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'transport'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (SELECT id FROM functional_divisions WHERE code IN ('22', '23'))
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'environmentAndAgriculture'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (SELECT id FROM functional_divisions WHERE code IN ('10', '37'))
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'industryAndEconomy'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (SELECT id FROM functional_divisions WHERE code IN ('21', '24', '25'))
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

-- Stats: 66 new pododdíly, 372 new paragrafy

-- Refresh category_paragraph_map for remaining expense categories.
-- Migration 0003 added ~370 new paragrafy across the tree but only refreshed
-- the map for 4 categories (socialProtection, transport, environment, industry).
-- This migration completes the refresh for the rest, idempotent via
-- ON CONFLICT (category_id, paragraph_id) DO NOTHING.

-- healthcare ← oddíl 35
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'healthcare'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id = (SELECT id FROM functional_divisions WHERE code = '35')
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

-- education ← oddíly 31, 32
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'education'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (SELECT id FROM functional_divisions WHERE code IN ('31', '32'))
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

-- cultureAndSport ← oddíly 33, 34
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'cultureAndSport'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (SELECT id FROM functional_divisions WHERE code IN ('33', '34'))
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

-- defenseAndSecurity ← oddíly 51, 52, 53, 55
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'defenseAndSecurity'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (SELECT id FROM functional_divisions WHERE code IN ('51', '52', '53', '55'))
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

-- publicAdministration ← oddíly 61, 62, 54
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'publicAdministration'), fp.id
FROM functional_paragraphs fp
JOIN functional_subdivisions fs ON fs.id = fp.subdivision_id
WHERE fs.division_id IN (SELECT id FROM functional_divisions WHERE code IN ('61', '62', '54'))
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

-- debtService ← paragraf 6310 (single paragraph, already mapped, but safe to retry)
INSERT INTO category_paragraph_map (category_id, paragraph_id)
SELECT (SELECT id FROM categories WHERE slug = 'debtService'), id
FROM functional_paragraphs WHERE code = '6310'
ON CONFLICT (category_id, paragraph_id) DO NOTHING;

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

-- Extend economic classification (druhové třídění) to full vyhláška coverage.
-- Source: vyhláška č. 412/2021 Sb., příloha č. 2, fetched from
--   https://www.zakonyprolidi.cz/cs/2021-412 (znění od 1. 1. 2026)
--
-- Migration 0002 seeded only items mentioned in docs/budget-categorization.md
-- (~19 items, ~20 groups). MIS-RIS ETL data contains 345 unique items across
-- 36 groups — many missing FK targets in our DB. This migration adds the rest
-- so the loader can INSERT budget_facts rows without FK violations.
--
-- Schema uses 3 levels (class → group → item), vyhláška has 4 (třída → seskupení
-- → podseskupení → položka). The 3-digit podseskupení layer is collapsed; items
-- reference their 2-digit group directly.
--
-- Idempotent: ON CONFLICT (code) DO NOTHING — safe on re-run.

-- New groups: 17, new items: 518

INSERT INTO economic_groups (class_id, code, slug, name_cs) VALUES
  ((SELECT id FROM economic_classes WHERE code = '1'), '14', 'econ-group-14', 'Příjem z daní a cel za zboží a služby ze zahraničí'),
  ((SELECT id FROM economic_classes WHERE code = '1'), '15', 'econ-group-15', 'Příjem z majetkových daní'),
  ((SELECT id FROM economic_classes WHERE code = '1'), '17', 'econ-group-17', 'Ostatní daňové příjmy'),
  ((SELECT id FROM economic_classes WHERE code = '2'), '25', 'econ-group-25', 'Příjmy sdílené s Evropskou unií nebo s jejím členským státem'),
  ((SELECT id FROM economic_classes WHERE code = '5'), '52', 'econ-group-52', 'Neinvestiční transfery soukromoprávním osobám'),
  ((SELECT id FROM economic_classes WHERE code = '5'), '55', 'econ-group-55', 'Neinvestiční transfery a související platby do zahraničí'),
  ((SELECT id FROM economic_classes WHERE code = '5'), '56', 'econ-group-56', 'Neinvestiční půjčené prostředky'),
  ((SELECT id FROM economic_classes WHERE code = '5'), '57', 'econ-group-57', 'Neinvestiční převody Národnímu fondu'),
  ((SELECT id FROM economic_classes WHERE code = '5'), '58', 'econ-group-58', 'Výdaje na náhrady za nezpůsobenou újmu'),
  ((SELECT id FROM economic_classes WHERE code = '5'), '59', 'econ-group-59', 'Ostatní neinvestiční výdaje'),
  ((SELECT id FROM economic_classes WHERE code = '6'), '64', 'econ-group-64', 'Investiční půjčené prostředky Rozpočtová jednotka postupuje podle vyhlášky k provedení zákona o účetnictví, která upravuje vymezení dlouhodobého hmotného a dlouhodobého nehmotného majetku.'),
  ((SELECT id FROM economic_classes WHERE code = '6'), '67', 'econ-group-67', 'Investiční převody Národnímu fondu'),
  ((SELECT id FROM economic_classes WHERE code = '6'), '69', 'econ-group-69', 'Ostatní investiční výdaje'),
  ((SELECT id FROM economic_classes WHERE code = '8'), '82', 'econ-group-82', 'Financování ze zahraničí'),
  ((SELECT id FROM economic_classes WHERE code = '8'), '83', 'econ-group-83', 'Pohyby na účtech pro financování nepatřící na jiné financující položky'),
  ((SELECT id FROM economic_classes WHERE code = '8'), '84', 'econ-group-84', 'Aktivní financování z jaderného účtu a účtu rezervy důchodového pojištění'),
  ((SELECT id FROM economic_classes WHERE code = '8'), '89', 'econ-group-89', 'Opravné položky k peněžním operacím')
ON CONFLICT (code) DO NOTHING;

INSERT INTO economic_items (group_id, code, slug, name_cs) VALUES
  ((SELECT id FROM economic_groups WHERE code = '11'), '1122', 'econ-item-1122', 'Příjem z daně z příjmů právnických osob v případech, kdy poplatníkem je obec, s'),
  ((SELECT id FROM economic_groups WHERE code = '11'), '1123', 'econ-item-1123', 'Příjem z daně z příjmů právnických osob v případech, kdy poplatníkem je kraj, s'),
  ((SELECT id FROM economic_groups WHERE code = '11'), '1131', 'econ-item-1131', 'Příjem z dorovnávacích daní'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1220', 'econ-item-1220', 'Příjem ze spotřební daně z výrobků souvisejících s tabákovými výrobky'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1221', 'econ-item-1221', 'Příjem ze spotřební daně z minerálních olejů'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1222', 'econ-item-1222', 'Příjem ze spotřební daně z lihu'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1223', 'econ-item-1223', 'Příjem ze spotřební daně z piva'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1224', 'econ-item-1224', 'Příjem ze spotřební daně z vína a meziproduktů'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1225', 'econ-item-1225', 'Příjem ze spotřební daně z tabákových výrobků'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1226', 'econ-item-1226', 'Příjem z poplatku za látky poškozující nebo ohrožující ozónovou vrstvu Země'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1227', 'econ-item-1227', 'Příjem z audiovizuálních poplatků'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1228', 'econ-item-1228', 'Příjem ze spotřební daně ze surového tabáku'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1229', 'econ-item-1229', 'Příjem ze spotřební daně ze zahřívaných tabákových výrobků'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1231', 'econ-item-1231', 'Příjem z daně ze zemního plynu a některých dalších plynů'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1232', 'econ-item-1232', 'Příjem z daně z pevných paliv'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1233', 'econ-item-1233', 'Příjem z daně z elektřiny'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1234', 'econ-item-1234', 'Příjem z odvodu z elektřiny ze slunečního záření'),
  ((SELECT id FROM economic_groups WHERE code = '12'), '1235', 'econ-item-1235', 'Příjem z poplatku za výrobu elektřiny ve výrobně elektřiny využívající energii v'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1321', 'econ-item-1321', 'Příjem z daně silniční'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1322', 'econ-item-1322', 'Příjem z časového poplatku za užívání dálnic a rychlostních silnic'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1323', 'econ-item-1323', 'Příjem z mýtného'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1331', 'econ-item-1331', 'Příjem z poplatku za vypouštění odpadních vod do vod povrchových'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1332', 'econ-item-1332', 'Příjem z poplatků za znečišťování ovzduší'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1333', 'econ-item-1333', 'Příjem z poplatků za ukládání odpadů na skládku'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1334', 'econ-item-1334', 'Příjem z odvodů za odnětí půdy ze zemědělského půdního fondu podle zákona upravu'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1335', 'econ-item-1335', 'Příjem z poplatku za odnětí pozemku podle lesního zákona'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1336', 'econ-item-1336', 'Příjem z poplatku za povolené vypouštění odpadních vod do vod podzemních'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1337', 'econ-item-1337', 'Příjem ze zrušeného poplatku za komunální odpad'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1338', 'econ-item-1338', 'Příjem z registračních a evidenčních poplatků za obaly'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1339', 'econ-item-1339', 'Příjem z ostatních poplatků a jiných obdobných peněžitých plnění v oblasti život'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1341', 'econ-item-1341', 'Příjem z poplatku ze psů'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1342', 'econ-item-1342', 'Příjem z poplatku z pobytu'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1343', 'econ-item-1343', 'Příjem z poplatku za užívání veřejného prostranství'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1344', 'econ-item-1344', 'Příjem z poplatku ze vstupného'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1345', 'econ-item-1345', 'Příjem z poplatku za obecní systém odpadového hospodářství a příjem z poplatku z'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1346', 'econ-item-1346', 'Příjem z poplatku za povolení k vjezdu s motorovým vozidlem do vybraných míst a'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1348', 'econ-item-1348', 'Příjem z poplatku za zhodnocení stavebního pozemku možností jeho připojení na st'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1349', 'econ-item-1349', 'Příjem ze zrušených místních poplatků'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1353', 'econ-item-1353', 'Příjem za zkoušky z odborné způsobilosti od žadatelů o řidičské oprávnění'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1354', 'econ-item-1354', 'Příjem z licencí pro kamionovou dopravu'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1356', 'econ-item-1356', 'Příjem z úhrad za dobývání nerostů a poplatků za geologické práce'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1357', 'econ-item-1357', 'Příjem z poplatku za odebrané množství podzemní vody'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1358', 'econ-item-1358', 'Příjem z poplatku za využívání zdroje přírodní minerální vody'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1359', 'econ-item-1359', 'Příjem z odvodů z vybraných činností a služeb jinde neuvedených'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1361', 'econ-item-1361', 'Příjem ze správních poplatků'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1362', 'econ-item-1362', 'Příjem ze soudních poplatků'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1371', 'econ-item-1371', 'Příjem z poplatku na činnost Energetického regulačního úřadu'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1372', 'econ-item-1372', 'Příjem z poplatku placeného Státnímu úřadu pro jadernou bezpečnost za žádost o v'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1373', 'econ-item-1373', 'Příjem z udržovacího poplatku Státnímu úřadu pro jadernou bezpečnost'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1379', 'econ-item-1379', 'Příjem z ostatních poplatků na činnost správních úřadů v jiných položkách neuved'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1381', 'econ-item-1381', 'Příjem z daně z hazardních her s výjimkou dílčí daně z technických her za zdaňov'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1382', 'econ-item-1382', 'Příjem ze zrušeného odvodu z loterií a podobných her kromě odvodu z výherních hr'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1383', 'econ-item-1383', 'Příjem ze zrušeného odvodu z výherních hracích přístrojů'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1385', 'econ-item-1385', 'Příjem z dílčí daně z technických her za zdaňovací období do konce roku 2023'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1386', 'econ-item-1386', 'Příjem z daně z hazardních her s výjimkou technických her neprovozovaných prostř'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1387', 'econ-item-1387', 'Příjem z daně z technických her neprovozovaných prostřednictvím internetu'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1388', 'econ-item-1388', 'Příjem z daně z internetových hazardních her'),
  ((SELECT id FROM economic_groups WHERE code = '13'), '1389', 'econ-item-1389', 'Příjem z daně z hazardních her provozovaných bez povolení nebo ohlášení'),
  ((SELECT id FROM economic_groups WHERE code = '14'), '1401', 'econ-item-1401', 'Příjem ze cla vyměřeného do dne 30. dubna 2004'),
  ((SELECT id FROM economic_groups WHERE code = '14'), '1409', 'econ-item-1409', 'Příjem ze zrušené dovozní přirážky, dovozní daně a jiných zrušených daní z mezin'),
  ((SELECT id FROM economic_groups WHERE code = '15'), '1511', 'econ-item-1511', 'Příjem z daně z nemovitých věcí'),
  ((SELECT id FROM economic_groups WHERE code = '15'), '1521', 'econ-item-1521', 'Příjem ze zrušené daně dědické'),
  ((SELECT id FROM economic_groups WHERE code = '15'), '1522', 'econ-item-1522', 'Příjem ze zrušené daně darovací'),
  ((SELECT id FROM economic_groups WHERE code = '15'), '1523', 'econ-item-1523', 'Příjem ze zrušené daně z nabytí nemovitých věcí a zrušené daně z převodu nemovit'),
  ((SELECT id FROM economic_groups WHERE code = '16'), '1614', 'econ-item-1614', 'Příjem z pojistného na nemocenské pojištění od zaměstnavatelů'),
  ((SELECT id FROM economic_groups WHERE code = '16'), '1615', 'econ-item-1615', 'Příjem z pojistného na nemocenské pojištění od zaměstnanců'),
  ((SELECT id FROM economic_groups WHERE code = '16'), '1617', 'econ-item-1617', 'Příjem z příspěvků na státní politiku zaměstnanosti od zaměstnavatelů'),
  ((SELECT id FROM economic_groups WHERE code = '16'), '1618', 'econ-item-1618', 'Příjem z příspěvků na státní politiku zaměstnanosti od osob samostatně výdělečně'),
  ((SELECT id FROM economic_groups WHERE code = '16'), '1627', 'econ-item-1627', 'Příjem z přirážek k pojistnému'),
  ((SELECT id FROM economic_groups WHERE code = '16'), '1628', 'econ-item-1628', 'Příjem z příslušenství pojistného'),
  ((SELECT id FROM economic_groups WHERE code = '16'), '1629', 'econ-item-1629', 'Nevyjasněné, neidentifikované a nezařazené příjmy z pojistného na sociální zabez'),
  ((SELECT id FROM economic_groups WHERE code = '17'), '1701', 'econ-item-1701', 'Nerozúčtované, neidentifikované a do jiných položek nezařaditelné daňové příjmy'),
  ((SELECT id FROM economic_groups WHERE code = '17'), '1702', 'econ-item-1702', 'Příjem z prodeje kolkových známek'),
  ((SELECT id FROM economic_groups WHERE code = '17'), '1703', 'econ-item-1703', 'Příjem z odvodů nahrazujících zaměstnávání občanů se změněnou pracovní schopnost'),
  ((SELECT id FROM economic_groups WHERE code = '17'), '1704', 'econ-item-1704', 'Příjem z příslušenství daní a poplatků'),
  ((SELECT id FROM economic_groups WHERE code = '17'), '1706', 'econ-item-1706', 'Příjem ze zrušené dávky z cukru'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2111', 'econ-item-2111', 'Příjem z poskytování služeb, výrobků, prací, výkonů a práv'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2112', 'econ-item-2112', 'Příjem z prodeje zboží (již nakoupeného za účelem prodeje)'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2113', 'econ-item-2113', 'Příjem ze školného'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2115', 'econ-item-2115', 'Příjem z prodeje práv k využívání rádiových kmitočtů'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2119', 'econ-item-2119', 'Ostatní příjmy z vlastní činnosti'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2121', 'econ-item-2121', 'Příjem z odvodů zbývajícího zisku České národní banky'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2122', 'econ-item-2122', 'Příjem z odvodů příspěvkových organizací'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2123', 'econ-item-2123', 'Příjem z ostatních odvodů příspěvkových organizací'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2124', 'econ-item-2124', 'Příjem z odvodů školských právnických osob zřízených státem, kraji a obcemi'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2125', 'econ-item-2125', 'Příjem z převodů z fondů státních podniků do státního rozpočtu'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2129', 'econ-item-2129', 'Příjem z výnosů z likvidace zbytkových podniků'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2131', 'econ-item-2131', 'Příjem z pronájmu nebo pachtu pozemků'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2132', 'econ-item-2132', 'Příjem z pronájmu nebo pachtu ostatních nemovitých věcí a jejich částí'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2133', 'econ-item-2133', 'Příjem z pronájmu nebo pachtu movitých věcí'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2139', 'econ-item-2139', 'Ostatní příjmy z pronájmu nebo pachtu majetku'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2140', 'econ-item-2140', 'Neúrokové příjmy z finančních derivátů kromě příjmů z derivátů k vlastním dluhop'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2141', 'econ-item-2141', 'Příjem z úroků'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2142', 'econ-item-2142', 'Příjem z podílů na zisku a dividend'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2143', 'econ-item-2143', 'Kursové rozdíly v příjmech'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2144', 'econ-item-2144', 'Příjem z úroků ze státních dluhopisů'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2145', 'econ-item-2145', 'Příjem z úroků z komunálních dluhopisů'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2146', 'econ-item-2146', 'Úrokové příjmy z finančních derivátů k vlastním dluhopisům'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2147', 'econ-item-2147', 'Neúrokové příjmy z finančních derivátů k vlastním dluhopisům'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2148', 'econ-item-2148', 'Úrokové příjmy z finančních derivátů kromě příjmů z derivátů k vlastním dluhopis'),
  ((SELECT id FROM economic_groups WHERE code = '21'), '2149', 'econ-item-2149', 'Ostatní příjmy z výnosů finančního majetku'),
  ((SELECT id FROM economic_groups WHERE code = '22'), '2211', 'econ-item-2211', 'Příjem sankčních plateb přijatých od státu, obcí a krajů'),
  ((SELECT id FROM economic_groups WHERE code = '22'), '2212', 'econ-item-2212', 'Příjem sankčních plateb přijatých od jiných osob'),
  ((SELECT id FROM economic_groups WHERE code = '22'), '2221', 'econ-item-2221', 'Přijaté vratky nespotřebovaných transferů'),
  ((SELECT id FROM economic_groups WHERE code = '22'), '2222', 'econ-item-2222', 'Ostatní příjmy z finančního vypořádání od jiných rozpočtů'),
  ((SELECT id FROM economic_groups WHERE code = '22'), '2223', 'econ-item-2223', 'Příjem z finančního vypořádání mezi kraji, obcemi a dobrovolnými svazky obcí'),
  ((SELECT id FROM economic_groups WHERE code = '22'), '2224', 'econ-item-2224', 'Příjem z vratek nevyužitých prostředků z Národního fondu'),
  ((SELECT id FROM economic_groups WHERE code = '22'), '2225', 'econ-item-2225', 'Příjem z úhrad prostředků vynaložených podle zákona o ochraně zaměstnanců při pl'),
  ((SELECT id FROM economic_groups WHERE code = '22'), '2226', 'econ-item-2226', 'Příjem z finančního vypořádání mezi obcemi a dobrovolnými svazky obcí'),
  ((SELECT id FROM economic_groups WHERE code = '22'), '2227', 'econ-item-2227', 'Příjem z finančního vypořádání mezi regionální radou a kraji, obcemi a dobrovoln'),
  ((SELECT id FROM economic_groups WHERE code = '22'), '2229', 'econ-item-2229', 'Ostatní přijaté vratky transferů a podobné příjmy'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2310', 'econ-item-2310', 'Příjem z prodeje krátkodobého a drobného dlouhodobého neinvestičního majetku'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2321', 'econ-item-2321', 'Přijaté peněžité neinvestiční dary'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2322', 'econ-item-2322', 'Příjem z pojistných plnění'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2324', 'econ-item-2324', 'Přijaté neinvestiční příspěvky a náhrady'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2325', 'econ-item-2325', 'Vratky nepoužitých prostředků z Národního fondu pro vyrovnání kursových rozdílů'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2326', 'econ-item-2326', 'Prostředky přijaté z Národního fondu související s neplněním závazků z mezinárod'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2327', 'econ-item-2327', 'Úhrada prostředků, které státní rozpočet odvedl Evropské unii za Národní fond'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2328', 'econ-item-2328', 'Neidentifikované příjmy'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2329', 'econ-item-2329', 'Ostatní nedaňové příjmy jinde nezařazené'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2342', 'econ-item-2342', 'Příjem plateb k úhradě správy vodních toků a správy povodí'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2343', 'econ-item-2343', 'Příjem z dobíhajících úhrad z dobývacího prostoru a z vydobytých nerostů'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2351', 'econ-item-2351', 'Příjem z poplatků za udržování patentu v platnosti'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2352', 'econ-item-2352', 'Příjem z poplatků za udržování evropského patentu v platnosti'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2353', 'econ-item-2353', 'Příjem z poplatků za udržování dodatkového ochranného osvědčení pro léčiva'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2361', 'econ-item-2361', 'Příjem z pojistného na nemocenské pojištění od osob samostatně výdělečně činných'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2362', 'econ-item-2362', 'Příjem z dobrovolného pojistného na důchodové pojištění'),
  ((SELECT id FROM economic_groups WHERE code = '23'), '2391', 'econ-item-2391', 'Dočasné zatřídění příjmů'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2411', 'econ-item-2411', 'Splátky půjčených prostředků od podnikatelů - fyzických osob'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2412', 'econ-item-2412', 'Splátky půjčených prostředků od nefinančních podnikatelů - právnických osob'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2413', 'econ-item-2413', 'Splátky půjčených prostředků od finančních podnikatelů - právnických osob'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2414', 'econ-item-2414', 'Splátky půjčených prostředků od podniků ve vlastnictví státu'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2420', 'econ-item-2420', 'Splátky půjčených prostředků od obecně prospěšných společností a obdobných osob'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2431', 'econ-item-2431', 'Splátky půjčených prostředků od státního rozpočtu'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2432', 'econ-item-2432', 'Splátky půjčených prostředků od státních fondů'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2433', 'econ-item-2433', 'Splátky půjčených prostředků od zvláštních fondů ústřední úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2434', 'econ-item-2434', 'Splátky půjčených prostředků od fondů sociálního a veřejného zdravotního pojiště'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2439', 'econ-item-2439', 'Ostatní splátky půjčených prostředků od veřejných rozpočtů'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2441', 'econ-item-2441', 'Splátky půjčených prostředků od obcí'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2442', 'econ-item-2442', 'Splátky půjčených prostředků od krajů'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2443', 'econ-item-2443', 'Splátky půjčených prostředků od regionálních rad'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2449', 'econ-item-2449', 'Ostatní splátky půjčených prostředků od rozpočtů územní úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2451', 'econ-item-2451', 'Splátky půjčených prostředků od příspěvkových organizací'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2452', 'econ-item-2452', 'Splátky půjčených prostředků od vysokých škol'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2459', 'econ-item-2459', 'Splátky půjčených prostředků od ostatních zřízených a podobných osob'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2460', 'econ-item-2460', 'Splátky půjčených prostředků od fyzických osob'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2470', 'econ-item-2470', 'Splátky půjčených prostředků ze zahraničí'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2481', 'econ-item-2481', 'Příjem od dlužníků za realizace záruk'),
  ((SELECT id FROM economic_groups WHERE code = '24'), '2482', 'econ-item-2482', 'Splátky od dlužníků za zaplacení dodávek včetně splátek vládních úvěrů'),
  ((SELECT id FROM economic_groups WHERE code = '25'), '2511', 'econ-item-2511', 'Podíl na clu vyměřeném ode dne 1. května 2004'),
  ((SELECT id FROM economic_groups WHERE code = '25'), '2512', 'econ-item-2512', 'Podíl na dávkách z cukru vybraných Státním zemědělským intervenčním fondem'),
  ((SELECT id FROM economic_groups WHERE code = '31'), '3111', 'econ-item-3111', 'Příjem z prodeje pozemků'),
  ((SELECT id FROM economic_groups WHERE code = '31'), '3112', 'econ-item-3112', 'Příjem z prodeje ostatních nemovitých věcí a jejich částí'),
  ((SELECT id FROM economic_groups WHERE code = '31'), '3113', 'econ-item-3113', 'Příjem z prodeje ostatního hmotného dlouhodobého majetku'),
  ((SELECT id FROM economic_groups WHERE code = '31'), '3114', 'econ-item-3114', 'Příjem z prodeje nehmotného dlouhodobého majetku'),
  ((SELECT id FROM economic_groups WHERE code = '31'), '3119', 'econ-item-3119', 'Ostatní příjmy z prodeje dlouhodobého majetku'),
  ((SELECT id FROM economic_groups WHERE code = '31'), '3121', 'econ-item-3121', 'Přijaté dary na pořízení dlouhodobého majetku'),
  ((SELECT id FROM economic_groups WHERE code = '31'), '3122', 'econ-item-3122', 'Přijaté příspěvky od osob na pořízení dlouhodobého majetku'),
  ((SELECT id FROM economic_groups WHERE code = '31'), '3129', 'econ-item-3129', 'Ostatní kapitálové příjmy jinde nezařazené'),
  ((SELECT id FROM economic_groups WHERE code = '32'), '3201', 'econ-item-3201', 'Příjem z prodeje akcií'),
  ((SELECT id FROM economic_groups WHERE code = '32'), '3202', 'econ-item-3202', 'Příjem z prodeje majetkových podílů'),
  ((SELECT id FROM economic_groups WHERE code = '32'), '3203', 'econ-item-3203', 'Příjem z prodeje dluhopisů'),
  ((SELECT id FROM economic_groups WHERE code = '32'), '3209', 'econ-item-3209', 'Ostatní příjmy z prodeje dlouhodobého finančního majetku'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4111', 'econ-item-4111', 'Neinvestiční přijaté transfery z všeobecné pokladní správy státního rozpočtu'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4112', 'econ-item-4112', 'Neinvestiční přijaté transfery ze státního rozpočtu v rámci souhrnného dotačního'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4113', 'econ-item-4113', 'Neinvestiční přijaté transfery ze státních fondů'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4114', 'econ-item-4114', 'Neinvestiční přijaté transfery ze zvláštních fondů ústřední úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4115', 'econ-item-4115', 'Neinvestiční přijaté transfery od fondů sociálního nebo veřejného zdravotního po'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4116', 'econ-item-4116', 'Ostatní neinvestiční přijaté transfery ze státního rozpočtu'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4118', 'econ-item-4118', 'Neinvestiční převody z Národního fondu'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4119', 'econ-item-4119', 'Ostatní neinvestiční přijaté transfery od rozpočtů ústřední úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4121', 'econ-item-4121', 'Neinvestiční přijaté transfery od obcí'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4122', 'econ-item-4122', 'Neinvestiční přijaté transfery od krajů'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4129', 'econ-item-4129', 'Ostatní neinvestiční přijaté transfery od rozpočtů územní úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4131', 'econ-item-4131', 'Převody z vlastních fondů podnikatelské činnosti'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4132', 'econ-item-4132', 'Převody z ostatních vlastních fondů'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4133', 'econ-item-4133', 'Převody z vlastních rezervních fondů jiných než organizačních složek státu'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4134', 'econ-item-4134', 'Převody z rozpočtových účtů'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4135', 'econ-item-4135', 'Převody z rezervních fondů organizačních složek státu'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4136', 'econ-item-4136', 'Převody z fondu kulturních a sociálních potřeb organizačních složek státu'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4137', 'econ-item-4137', 'Neinvestiční převody mezi statutárními městy včetně hl. m. Prahy a jejich městsk'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4138', 'econ-item-4138', 'Převody z vlastní pokladny'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4139', 'econ-item-4139', 'Ostatní převody z vlastních fondů'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4140', 'econ-item-4140', 'Převody z vlastních fondů přes rok'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4151', 'econ-item-4151', 'Neinvestiční přijaté transfery od jiných států'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4152', 'econ-item-4152', 'Neinvestiční přijaté transfery od mezinárodních organizací a některých zahraničn'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4153', 'econ-item-4153', 'Neinvestiční transfery přijaté od Evropské unie'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4155', 'econ-item-4155', 'Neinvestiční transfery z finančních mechanismů'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4156', 'econ-item-4156', 'Neinvestiční transfery od Organizace severoatlantické smlouvy'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4159', 'econ-item-4159', 'Ostatní neinvestiční transfery přijaté ze zahraničí'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4160', 'econ-item-4160', 'Neinvestiční přijaté transfery ze státních finančních aktiv'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4171', 'econ-item-4171', 'Příjem náhrad za nezpůsobenou újmu'),
  ((SELECT id FROM economic_groups WHERE code = '41'), '4172', 'econ-item-4172', 'Příjem náhrad škod způsobených nezákonným rozhodnutím nebo nesprávným úředním po'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4211', 'econ-item-4211', 'Investiční přijaté transfery z všeobecné pokladní správy státního rozpočtu'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4212', 'econ-item-4212', 'Investiční přijaté transfery ze státního rozpočtu v rámci souhrnného dotačního v'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4213', 'econ-item-4213', 'Investiční přijaté transfery ze státních fondů'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4214', 'econ-item-4214', 'Investiční přijaté transfery ze zvláštních fondů ústřední úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4216', 'econ-item-4216', 'Ostatní investiční přijaté transfery ze státního rozpočtu'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4218', 'econ-item-4218', 'Investiční převody z Národního fondu'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4219', 'econ-item-4219', 'Ostatní investiční přijaté transfery od rozpočtů ústřední úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4221', 'econ-item-4221', 'Investiční přijaté transfery od obcí'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4222', 'econ-item-4222', 'Investiční přijaté transfery od krajů'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4229', 'econ-item-4229', 'Ostatní investiční přijaté transfery od rozpočtů územní úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4231', 'econ-item-4231', 'Investiční přijaté transfery od jiných států'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4232', 'econ-item-4232', 'Investiční přijaté transfery od mezinárodních nebo zahraničních institucí'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4233', 'econ-item-4233', 'Investiční transfery přijaté od Evropské unie'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4234', 'econ-item-4234', 'Investiční transfery z finančních mechanismů'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4235', 'econ-item-4235', 'Investiční transfery od Organizace severoatlantické smlouvy'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4240', 'econ-item-4240', 'Investiční přijaté transfery ze státních finančních aktiv'),
  ((SELECT id FROM economic_groups WHERE code = '42'), '4251', 'econ-item-4251', 'Investiční převody mezi statutárními městy včetně hl. m. Prahy a jejich městským'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5012', 'econ-item-5012', 'Platy zaměstnanců bezpečnostních sborů a ozbrojených sil ve služebním poměru'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5013', 'econ-item-5013', 'Platy zaměstnanců na služebních místech podle zákona o státní službě'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5014', 'econ-item-5014', 'Platy zaměstnanců v pracovním poměru odvozované od platů ústavních činitelů'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5019', 'econ-item-5019', 'Ostatní platy'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5021', 'econ-item-5021', 'Ostatní osobní výdaje'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5022', 'econ-item-5022', 'Platy představitelů státní moci a některých orgánů'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5023', 'econ-item-5023', 'Odměny členů zastupitelstev obcí a krajů'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5024', 'econ-item-5024', 'Odstupné'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5025', 'econ-item-5025', 'Odbytné vyplácené státním zaměstnancům ve správních úřadech'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5026', 'econ-item-5026', 'Odchodné'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5027', 'econ-item-5027', 'Peněžní náležitosti vojáků v záloze ve službě'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5028', 'econ-item-5028', 'Kázeňské odměny poskytnuté formou peněžitých darů příslušníkům bezpečnostních sb'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5029', 'econ-item-5029', 'Ostatní platby za provedenou práci jinde nezařazené'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5038', 'econ-item-5038', 'Pojistné na zákonné pojištění odpovědnosti zaměstnavatele za škodu při pracovním'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5039', 'econ-item-5039', 'Ostatní povinné pojistné placené zaměstnavatelem'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5041', 'econ-item-5041', 'Odměny za užití duševního vlastnictví'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5042', 'econ-item-5042', 'Odměny za užití počítačových programů'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5051', 'econ-item-5051', 'Platové a mzdové náhrady'),
  ((SELECT id FROM economic_groups WHERE code = '50'), '5061', 'econ-item-5061', 'Mzdy podle cizího práva'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5122', 'econ-item-5122', 'Podlimitní věcná břemena'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5123', 'econ-item-5123', 'Podlimitní technické zhodnocení'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5131', 'econ-item-5131', 'Potraviny'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5132', 'econ-item-5132', 'Ochranné pomůcky'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5133', 'econ-item-5133', 'Léky a zdravotnický materiál'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5134', 'econ-item-5134', 'Prádlo, oděv a obuv s výjimkou ochranných pomůcek'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5135', 'econ-item-5135', 'Učebnice a školní potřeby'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5136', 'econ-item-5136', 'Knihy a obdobné listinné informační prostředky'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5137', 'econ-item-5137', 'Drobný dlouhodobý hmotný majetek'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5138', 'econ-item-5138', 'Nákup zboží za účelem dalšího prodeje'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5141', 'econ-item-5141', 'Úroky vlastní'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5142', 'econ-item-5142', 'Kursové rozdíly ve výdajích'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5143', 'econ-item-5143', 'Úroky vzniklé převzetím cizích závazků'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5144', 'econ-item-5144', 'Úplaty dluhové služby'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5145', 'econ-item-5145', 'Neúrokové výdaje na finanční deriváty k vlastním dluhopisům'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5146', 'econ-item-5146', 'Úrokové výdaje na finanční deriváty k vlastním dluhopisům'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5147', 'econ-item-5147', 'Úrokové výdaje na finanční deriváty kromě výdajů na deriváty k vlastním dluhopis'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5148', 'econ-item-5148', 'Neúrokové výdaje na finanční deriváty kromě výdajů na deriváty k vlastním dluhop'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5149', 'econ-item-5149', 'Ostatní úroky a ostatní finanční výdaje'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5151', 'econ-item-5151', 'Studená voda včetně stočného a úplaty za odvod dešťových vod'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5152', 'econ-item-5152', 'Teplo'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5153', 'econ-item-5153', 'Plyn'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5155', 'econ-item-5155', 'Pevná paliva'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5156', 'econ-item-5156', 'Pohonné hmoty a maziva'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5157', 'econ-item-5157', 'Teplá voda'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5159', 'econ-item-5159', 'Nákup ostatních paliv a energie'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5161', 'econ-item-5161', 'Poštovní služby'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5162', 'econ-item-5162', 'Služby elektronických komunikací'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5163', 'econ-item-5163', 'Služby peněžních ústavů'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5164', 'econ-item-5164', 'Nájemné'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5165', 'econ-item-5165', 'Zemědělské pachtovné'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5166', 'econ-item-5166', 'Konzultační, poradenské a právní služby'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5167', 'econ-item-5167', 'Služby školení a vzdělávání'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5168', 'econ-item-5168', 'Zpracování dat a služby související s informačními a komunikačními technologiemi'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5169', 'econ-item-5169', 'Nákup ostatních služeb'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5171', 'econ-item-5171', 'Opravy a udržování'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5172', 'econ-item-5172', 'Podlimitní programové vybavení'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5173', 'econ-item-5173', 'Cestovné'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5175', 'econ-item-5175', 'Pohoštění'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5176', 'econ-item-5176', 'Účastnické úplaty na konference'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5177', 'econ-item-5177', 'Nákup archiválií'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5178', 'econ-item-5178', 'Nájemné za nájem s právem koupě'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5179', 'econ-item-5179', 'Ostatní nákupy jinde nezařazené'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5181', 'econ-item-5181', 'Převody vnitřním organizačním jednotkám'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5182', 'econ-item-5182', 'Převody vlastní pokladně'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5183', 'econ-item-5183', 'Výdaje na realizaci záruk'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5184', 'econ-item-5184', 'Výdaje na vládní úvěry'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5185', 'econ-item-5185', 'Převody do elektronických peněženek'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5189', 'econ-item-5189', 'Vratky jistot'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5191', 'econ-item-5191', 'Zaplacené sankce a odstupné'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5192', 'econ-item-5192', 'Poskytnuté náhrady'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5194', 'econ-item-5194', 'Výdaje na věcné dary'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5195', 'econ-item-5195', 'Odvody za neplnění povinnosti zaměstnávat zdravotně postižené'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5196', 'econ-item-5196', 'Náhrady a příspěvky související s výkonem ústavní funkce a funkce soudce'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5197', 'econ-item-5197', 'Náhrady zvýšených nákladů spojených s výkonem funkce v zahraničí'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5198', 'econ-item-5198', 'Finanční náhrady v rámci majetkového vyrovnání s církvemi'),
  ((SELECT id FROM economic_groups WHERE code = '51'), '5199', 'econ-item-5199', 'Ostatní výdaje související s neinvestičními nákupy'),
  ((SELECT id FROM economic_groups WHERE code = '52'), '5211', 'econ-item-5211', 'Neinvestiční transfery finančním institucím'),
  ((SELECT id FROM economic_groups WHERE code = '52'), '5212', 'econ-item-5212', 'Neinvestiční transfery nefinančním podnikatelům - fyzickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '52'), '5213', 'econ-item-5213', 'Neinvestiční transfery nefinančním podnikatelům - právnickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '52'), '5214', 'econ-item-5214', 'Neinvestiční transfery finančním a podobným institucím ve vlastnictví státu'),
  ((SELECT id FROM economic_groups WHERE code = '52'), '5215', 'econ-item-5215', 'Neinvestiční transfery vybraným podnikatelům ve vlastnictví státu'),
  ((SELECT id FROM economic_groups WHERE code = '52'), '5216', 'econ-item-5216', 'Neinvestiční transfery obecním a krajským nemocnicím - obchodním společnostem'),
  ((SELECT id FROM economic_groups WHERE code = '52'), '5219', 'econ-item-5219', 'Ostatní neinvestiční transfery podnikatelům'),
  ((SELECT id FROM economic_groups WHERE code = '52'), '5221', 'econ-item-5221', 'Neinvestiční transfery fundacím, ústavům a obecně prospěšným společnostem'),
  ((SELECT id FROM economic_groups WHERE code = '52'), '5222', 'econ-item-5222', 'Neinvestiční transfery spolkům'),
  ((SELECT id FROM economic_groups WHERE code = '52'), '5223', 'econ-item-5223', 'Neinvestiční transfery církvím a náboženským společnostem'),
  ((SELECT id FROM economic_groups WHERE code = '52'), '5224', 'econ-item-5224', 'Neinvestiční transfery politickým stranám a hnutím'),
  ((SELECT id FROM economic_groups WHERE code = '52'), '5225', 'econ-item-5225', 'Neinvestiční transfery společenstvím vlastníků jednotek'),
  ((SELECT id FROM economic_groups WHERE code = '52'), '5229', 'econ-item-5229', 'Ostatní neinvestiční transfery neziskovým a podobným osobám'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5311', 'econ-item-5311', 'Neinvestiční transfery státnímu rozpočtu'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5312', 'econ-item-5312', 'Neinvestiční transfery státním fondům'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5313', 'econ-item-5313', 'Neinvestiční transfery zvláštním fondům ústřední úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5314', 'econ-item-5314', 'Neinvestiční transfery fondům sociálního a veřejného zdravotního pojištění'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5315', 'econ-item-5315', 'Odvod daně za zaměstnance'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5316', 'econ-item-5316', 'Odvod pojistného na sociální zabezpečení a příspěvku na státní politiku zaměstna'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5317', 'econ-item-5317', 'Odvod pojistného na veřejné zdravotní pojištění za zaměstnance'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5318', 'econ-item-5318', 'Neinvestiční transfery prostředků do státních finančních aktiv'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5319', 'econ-item-5319', 'Ostatní neinvestiční transfery jiným veřejným rozpočtům'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5321', 'econ-item-5321', 'Neinvestiční transfery obcím'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5322', 'econ-item-5322', 'Neinvestiční transfery obcím v rámci souhrnného dotačního vztahu'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5323', 'econ-item-5323', 'Neinvestiční transfery krajům'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5324', 'econ-item-5324', 'Neinvestiční transfery krajům v rámci souhrnného dotačního vztahu'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5329', 'econ-item-5329', 'Ostatní neinvestiční transfery rozpočtům územní úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5331', 'econ-item-5331', 'Neinvestiční příspěvky zřízeným příspěvkovým organizacím'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5332', 'econ-item-5332', 'Neinvestiční transfery veřejným vysokým školám'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5333', 'econ-item-5333', 'Neinvestiční transfery školským právnickým osobám zřízeným státem, kraji a obcem'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5334', 'econ-item-5334', 'Neinvestiční transfery veřejným výzkumným institucím'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5335', 'econ-item-5335', 'Neinvestiční transfery veřejným kulturním institucím'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5336', 'econ-item-5336', 'Neinvestiční transfery zřízeným příspěvkovým organizacím'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5339', 'econ-item-5339', 'Neinvestiční transfery cizím příspěvkovým organizacím'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5341', 'econ-item-5341', 'Převody vlastním fondům podnikatelské činnosti'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5342', 'econ-item-5342', 'Základní příděl fondu kulturních a sociálních potřeb a sociálnímu fondu obcí a k'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5343', 'econ-item-5343', 'Převody na účty nemající povahu veřejných rozpočtů'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5344', 'econ-item-5344', 'Převody vlastním rezervním fondům územních rozpočtů'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5345', 'econ-item-5345', 'Převody vlastním rozpočtovým účtům'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5346', 'econ-item-5346', 'Převody do fondů organizačních složek státu'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5347', 'econ-item-5347', 'Neinvestiční převody mezi statutárními městy včetně hl. m. Prahy a jejich městsk'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5348', 'econ-item-5348', 'Převody do vlastní pokladny'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5349', 'econ-item-5349', 'Ostatní převody vlastním fondům'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5350', 'econ-item-5350', 'Převody do vlastních fondů přes rok'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5361', 'econ-item-5361', 'Nákup kolků'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5362', 'econ-item-5362', 'Platby daní státnímu rozpočtu'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5363', 'econ-item-5363', 'Úhrady sankcí jiným rozpočtům'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5364', 'econ-item-5364', 'Vratky transferů poskytnutých z veřejných rozpočtů'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5365', 'econ-item-5365', 'Platby daní krajům, obcím a státním fondům'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5366', 'econ-item-5366', 'Výdaje z finančního vypořádání mezi krajem a obcemi'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5367', 'econ-item-5367', 'Výdaje z finančního vypořádání mezi obcemi'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5368', 'econ-item-5368', 'Výdaje z finančního vypořádání mezi regionální radou a kraji, obcemi a dobrovoln'),
  ((SELECT id FROM economic_groups WHERE code = '53'), '5369', 'econ-item-5369', 'Ostatní neinvestiční transfery jiným veřejným rozpočtům'),
  ((SELECT id FROM economic_groups WHERE code = '54'), '5421', 'econ-item-5421', 'Plnění z úrazového pojištění'),
  ((SELECT id FROM economic_groups WHERE code = '54'), '5423', 'econ-item-5423', 'Náhrady mezd podle zákona o ochraně zaměstnanců při platební neschopnosti zaměst'),
  ((SELECT id FROM economic_groups WHERE code = '54'), '5425', 'econ-item-5425', 'Příspěvek na náklady pohřbu dárce orgánu a náhrada poskytovaná žijícímu dárci'),
  ((SELECT id FROM economic_groups WHERE code = '54'), '5491', 'econ-item-5491', 'Stipendia žákům, studentům a doktorandům'),
  ((SELECT id FROM economic_groups WHERE code = '54'), '5492', 'econ-item-5492', 'Dary fyzickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '54'), '5493', 'econ-item-5493', 'Účelové neinvestiční transfery fyzickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '54'), '5494', 'econ-item-5494', 'Neinvestiční transfery fyzickým osobám nemající povahu daru'),
  ((SELECT id FROM economic_groups WHERE code = '54'), '5495', 'econ-item-5495', 'Stabilizační příspěvek vojákům'),
  ((SELECT id FROM economic_groups WHERE code = '54'), '5496', 'econ-item-5496', 'Služební příspěvek vojákům na bydlení'),
  ((SELECT id FROM economic_groups WHERE code = '54'), '5497', 'econ-item-5497', 'Náborový příspěvek'),
  ((SELECT id FROM economic_groups WHERE code = '54'), '5498', 'econ-item-5498', 'Kvalifikační příspěvek a jednorázová peněžní výpomoc vojákům'),
  ((SELECT id FROM economic_groups WHERE code = '54'), '5499', 'econ-item-5499', 'Ostatní neinvestiční transfery fyzickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '55'), '5511', 'econ-item-5511', 'Neinvestiční transfery mezinárodním vládním organizacím'),
  ((SELECT id FROM economic_groups WHERE code = '55'), '5512', 'econ-item-5512', 'Neinvestiční transfery nadnárodním orgánům Transfery Evropské unii. Na položku 5'),
  ((SELECT id FROM economic_groups WHERE code = '55'), '5513', 'econ-item-5513', 'Vratky neoprávněně použitých nebo zadržených prostředků Evropské unie'),
  ((SELECT id FROM economic_groups WHERE code = '55'), '5514', 'econ-item-5514', 'Odvody vlastních zdrojů Evropské unie do rozpočtu Evropské unie podle daně z při'),
  ((SELECT id FROM economic_groups WHERE code = '55'), '5515', 'econ-item-5515', 'Odvody vlastních zdrojů Evropské unie do rozpočtu Evropské unie podle hrubého ná'),
  ((SELECT id FROM economic_groups WHERE code = '55'), '5516', 'econ-item-5516', 'Odvody Evropské unii ke krytí záporných úroků'),
  ((SELECT id FROM economic_groups WHERE code = '55'), '5517', 'econ-item-5517', 'Odvody vlastních zdrojů Evropské unie do rozpočtu Evropské unie podle objemu ner'),
  ((SELECT id FROM economic_groups WHERE code = '55'), '5520', 'econ-item-5520', 'Neinvestiční transfery cizím státům'),
  ((SELECT id FROM economic_groups WHERE code = '55'), '5531', 'econ-item-5531', 'Peněžní dary do zahraničí'),
  ((SELECT id FROM economic_groups WHERE code = '55'), '5532', 'econ-item-5532', 'Ostatní neinvestiční transfery do zahraničí'),
  ((SELECT id FROM economic_groups WHERE code = '55'), '5541', 'econ-item-5541', 'Členské příspěvky mezinárodním vládním organizacím'),
  ((SELECT id FROM economic_groups WHERE code = '55'), '5542', 'econ-item-5542', 'Členské příspěvky mezinárodním nevládním organizacím'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5611', 'econ-item-5611', 'Neinvestiční půjčené prostředky finančním institucím'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5612', 'econ-item-5612', 'Neinvestiční půjčené prostředky nefinančním podnikatelům - fyzickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5613', 'econ-item-5613', 'Neinvestiční půjčené prostředky nefinančním podnikatelům -právnickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5614', 'econ-item-5614', 'Neinvestiční půjčené prostředky finančním a podobným institucím ve vlastnictví s'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5615', 'econ-item-5615', 'Neinvestiční půjčené prostředky vybraným podnikatelům ve vlastnictví státu'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5619', 'econ-item-5619', 'Ostatní neinvestiční půjčené prostředky podnikatelům'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5621', 'econ-item-5621', 'Neinvestiční půjčené prostředky fundacím, ústavům a obecně prospěšným společnost'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5622', 'econ-item-5622', 'Neinvestiční půjčené prostředky spolkům'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5623', 'econ-item-5623', 'Neinvestiční půjčené prostředky církvím a náboženským společnostem'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5624', 'econ-item-5624', 'Neinvestiční půjčené prostředky společenstvím vlastníků jednotek'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5629', 'econ-item-5629', 'Ostatní neinvestiční půjčené prostředky neziskovým a podobným osobám'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5631', 'econ-item-5631', 'Neinvestiční půjčené prostředky státnímu rozpočtu'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5632', 'econ-item-5632', 'Neinvestiční půjčené prostředky státním fondům'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5633', 'econ-item-5633', 'Neinvestiční půjčené prostředky zvláštním fondům ústřední úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5634', 'econ-item-5634', 'Neinvestiční půjčené prostředky fondům sociálního a veřejného zdravotního pojišt'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5639', 'econ-item-5639', 'Ostatní neinvestiční půjčené prostředky jiným veřejným rozpočtům'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5641', 'econ-item-5641', 'Neinvestiční půjčené prostředky obcím'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5642', 'econ-item-5642', 'Neinvestiční půjčené prostředky krajům'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5649', 'econ-item-5649', 'Ostatní neinvestiční půjčené prostředky rozpočtům územní úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5651', 'econ-item-5651', 'Neinvestiční půjčené prostředky zřízeným příspěvkovým organizacím'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5652', 'econ-item-5652', 'Neinvestiční půjčené prostředky veřejným vysokým školám'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5659', 'econ-item-5659', 'Neinvestiční půjčené prostředky příspěvkovým organizacím zřízených jinými zřizov'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5660', 'econ-item-5660', 'Neinvestiční půjčené prostředky fyzickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '56'), '5670', 'econ-item-5670', 'Neinvestiční půjčené prostředky do zahraničí'),
  ((SELECT id FROM economic_groups WHERE code = '57'), '5711', 'econ-item-5711', 'Převody Národnímu fondu ke kompenzaci nesrovnalostí'),
  ((SELECT id FROM economic_groups WHERE code = '57'), '5719', 'econ-item-5719', 'Ostatní neinvestiční převody Národnímu fondu'),
  ((SELECT id FROM economic_groups WHERE code = '58'), '5811', 'econ-item-5811', 'Výdaje na náhrady za nezpůsobenou újmu'),
  ((SELECT id FROM economic_groups WHERE code = '58'), '5812', 'econ-item-5812', 'Výdaje na náhrady škod způsobených nezákonným rozhodnutím nebo nesprávným úřední'),
  ((SELECT id FROM economic_groups WHERE code = '59'), '5901', 'econ-item-5901', 'Nespecifikované rezervy'),
  ((SELECT id FROM economic_groups WHERE code = '59'), '5902', 'econ-item-5902', 'Ostatní výdaje z finančního vypořádání'),
  ((SELECT id FROM economic_groups WHERE code = '59'), '5903', 'econ-item-5903', 'Rezerva na krizová opatření'),
  ((SELECT id FROM economic_groups WHERE code = '59'), '5904', 'econ-item-5904', 'Převody domněle neoprávněně použitých dotací zpět poskytovateli'),
  ((SELECT id FROM economic_groups WHERE code = '59'), '5905', 'econ-item-5905', 'Výdaje na plnění nahrazující úroky'),
  ((SELECT id FROM economic_groups WHERE code = '59'), '5909', 'econ-item-5909', 'Ostatní neinvestiční výdaje jinde nezařazené'),
  ((SELECT id FROM economic_groups WHERE code = '59'), '5991', 'econ-item-5991', 'Dočasné zatřídění výdajů'),
  ((SELECT id FROM economic_groups WHERE code = '61'), '6111', 'econ-item-6111', 'Programové vybavení'),
  ((SELECT id FROM economic_groups WHERE code = '61'), '6112', 'econ-item-6112', 'Ocenitelná práva'),
  ((SELECT id FROM economic_groups WHERE code = '61'), '6113', 'econ-item-6113', 'Nehmotné výsledky výzkumné a obdobné činnosti'),
  ((SELECT id FROM economic_groups WHERE code = '61'), '6119', 'econ-item-6119', 'Ostatní nákup dlouhodobého nehmotného majetku'),
  ((SELECT id FROM economic_groups WHERE code = '61'), '6123', 'econ-item-6123', 'Dopravní prostředky'),
  ((SELECT id FROM economic_groups WHERE code = '61'), '6124', 'econ-item-6124', 'Pěstitelské celky trvalých porostů'),
  ((SELECT id FROM economic_groups WHERE code = '61'), '6125', 'econ-item-6125', 'Informační a komunikační technologie'),
  ((SELECT id FROM economic_groups WHERE code = '61'), '6127', 'econ-item-6127', 'Kulturní předměty'),
  ((SELECT id FROM economic_groups WHERE code = '61'), '6129', 'econ-item-6129', 'Nákup ostatního dlouhodobého hmotného majetku'),
  ((SELECT id FROM economic_groups WHERE code = '61'), '6130', 'econ-item-6130', 'Pozemky'),
  ((SELECT id FROM economic_groups WHERE code = '61'), '6141', 'econ-item-6141', 'Právo stavby'),
  ((SELECT id FROM economic_groups WHERE code = '61'), '6142', 'econ-item-6142', 'Nadlimitní věcná břemena'),
  ((SELECT id FROM economic_groups WHERE code = '62'), '6202', 'econ-item-6202', 'Nákup majetkových podílů'),
  ((SELECT id FROM economic_groups WHERE code = '62'), '6209', 'econ-item-6209', 'Nákup majetkových nároků'),
  ((SELECT id FROM economic_groups WHERE code = '62'), '6211', 'econ-item-6211', 'Vklady do nadací'),
  ((SELECT id FROM economic_groups WHERE code = '62'), '6212', 'econ-item-6212', 'Vklady do nadačních fondů'),
  ((SELECT id FROM economic_groups WHERE code = '62'), '6213', 'econ-item-6213', 'Vklady do ústavů'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6311', 'econ-item-6311', 'Investiční transfery finančním institucím'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6312', 'econ-item-6312', 'Investiční transfery nefinančním podnikatelům - fyzickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6313', 'econ-item-6313', 'Investiční transfery nefinančním podnikatelům - právnickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6314', 'econ-item-6314', 'Investiční transfery finančním a podobným institucím ve vlastnictví státu'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6315', 'econ-item-6315', 'Investiční transfery vybraným podnikatelům ve vlastnictví státu'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6316', 'econ-item-6316', 'Investiční transfery obecním a krajským nemocnicím - obchodním společnostem'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6319', 'econ-item-6319', 'Ostatní investiční transfery podnikatelům'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6321', 'econ-item-6321', 'Investiční transfery fundacím, ústavům a obecně prospěšným společnostem'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6322', 'econ-item-6322', 'Investiční transfery spolkům'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6323', 'econ-item-6323', 'Investiční transfery církvím a náboženským společnostem'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6324', 'econ-item-6324', 'Investiční transfery společenstvím vlastníků jednotek'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6329', 'econ-item-6329', 'Ostatní investiční transfery neziskovým a podobným osobám'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6331', 'econ-item-6331', 'Investiční transfery státnímu rozpočtu'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6332', 'econ-item-6332', 'Investiční transfery státním fondům'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6333', 'econ-item-6333', 'Investiční transfery zvláštním fondům ústřední úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6334', 'econ-item-6334', 'Investiční transfery fondům sociálního a veřejného zdravotního pojištění'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6335', 'econ-item-6335', 'Investiční transfery státním finančním aktivům'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6339', 'econ-item-6339', 'Investiční transfery jiným rozpočtům ústřední úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6341', 'econ-item-6341', 'Investiční transfery obcím'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6342', 'econ-item-6342', 'Investiční transfery krajům'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6343', 'econ-item-6343', 'Investiční transfery obcím v rámci souhrnného dotačního vztahu'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6344', 'econ-item-6344', 'Investiční transfery krajům v rámci souhrnného dotačního vztahu'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6349', 'econ-item-6349', 'Ostatní investiční transfery rozpočtům územní úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6351', 'econ-item-6351', 'Investiční transfery zřízeným příspěvkovým organizacím'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6352', 'econ-item-6352', 'Investiční transfery veřejným vysokým školám'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6353', 'econ-item-6353', 'Investiční transfery školským právnickým osobám zřízeným státem, kraji a obcemi'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6354', 'econ-item-6354', 'Investiční transfery veřejným výzkumným institucím'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6355', 'econ-item-6355', 'Investiční transfery veřejným kulturním institucím'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6356', 'econ-item-6356', 'Jiné investiční transfery zřízeným příspěvkovým organizacím'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6359', 'econ-item-6359', 'Investiční transfery příspěvkovým organizacím zřízeným jinými zřizovateli'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6361', 'econ-item-6361', 'Investiční převody do rezervního fondu organizačních složek státu'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6362', 'econ-item-6362', 'Převody investičních prostředků zpět do fondu kulturních a sociálních potřeb'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6363', 'econ-item-6363', 'Investiční převody mezi statutárními městy včetně hl. m. Prahy a jejich městským'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6371', 'econ-item-6371', 'Účelové investiční transfery nepodnikajícím fyzickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6379', 'econ-item-6379', 'Ostatní investiční transfery fyzickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '63'), '6380', 'econ-item-6380', 'Investiční transfery do zahraničí'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6411', 'econ-item-6411', 'Investiční půjčené prostředky finančním institucím'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6412', 'econ-item-6412', 'Investiční půjčené prostředky nefinančním podnikatelům - fyzickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6413', 'econ-item-6413', 'Investiční půjčené prostředky nefinančním podnikatelům - právnickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6414', 'econ-item-6414', 'Investiční půjčené prostředky finančním a podobným institucím ve vlastnictví stá'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6415', 'econ-item-6415', 'Investiční půjčené prostředky vybraným podnikatelům ve vlastnictví státu'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6419', 'econ-item-6419', 'Ostatní investiční půjčené prostředky podnikatelům'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6421', 'econ-item-6421', 'Investiční půjčené prostředky fundacím, ústavům a obecně prospěšným společnostem'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6422', 'econ-item-6422', 'Investiční půjčené prostředky spolkům'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6423', 'econ-item-6423', 'Investiční půjčené prostředky církvím a náboženským společnostem'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6424', 'econ-item-6424', 'Investiční půjčené prostředky společenstvím vlastníků jednotek'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6429', 'econ-item-6429', 'Ostatní investiční půjčené prostředky neziskovým a podobným osobám'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6431', 'econ-item-6431', 'Investiční půjčené prostředky státnímu rozpočtu'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6432', 'econ-item-6432', 'Investiční půjčené prostředky státním fondům'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6433', 'econ-item-6433', 'Investiční půjčené prostředky zvláštním fondům ústřední úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6434', 'econ-item-6434', 'Investiční půjčené prostředky fondům sociálního a veřejného zdravotního pojištěn'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6439', 'econ-item-6439', 'Ostatní investiční půjčené prostředky jiným rozpočtům'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6441', 'econ-item-6441', 'Investiční půjčené prostředky obcím'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6442', 'econ-item-6442', 'Investiční půjčené prostředky krajům'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6449', 'econ-item-6449', 'Ostatní investiční půjčené prostředky rozpočtům místní úrovně'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6451', 'econ-item-6451', 'Investiční půjčené prostředky zřízeným příspěvkovým organizacím'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6452', 'econ-item-6452', 'Investiční půjčené prostředky veřejným vysokým školám'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6459', 'econ-item-6459', 'Investiční půjčené prostředky ostatním příspěvkovým organizacím'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6460', 'econ-item-6460', 'Investiční půjčené prostředky fyzickým osobám'),
  ((SELECT id FROM economic_groups WHERE code = '64'), '6470', 'econ-item-6470', 'Investiční půjčené prostředky do zahraničí'),
  ((SELECT id FROM economic_groups WHERE code = '67'), '6711', 'econ-item-6711', 'Investiční převody Národnímu fondu'),
  ((SELECT id FROM economic_groups WHERE code = '69'), '6901', 'econ-item-6901', 'Rezervy investičních výdajů'),
  ((SELECT id FROM economic_groups WHERE code = '69'), '6909', 'econ-item-6909', 'Ostatní investiční výdaje jinde nezařazené'),
  ((SELECT id FROM economic_groups WHERE code = '81'), '8112', 'econ-item-8112', 'Uhrazené splátky krátkodobých vydaných dluhopisů'),
  ((SELECT id FROM economic_groups WHERE code = '81'), '8113', 'econ-item-8113', 'Krátkodobé přijaté půjčené prostředky'),
  ((SELECT id FROM economic_groups WHERE code = '81'), '8114', 'econ-item-8114', 'Uhrazené splátky krátkodobých přijatých půjčených prostředků'),
  ((SELECT id FROM economic_groups WHERE code = '81'), '8116', 'econ-item-8116', 'Změny stavu bankovních účtů krátkodobých prostředků státních finančních aktiv, k'),
  ((SELECT id FROM economic_groups WHERE code = '81'), '8117', 'econ-item-8117', 'Aktivní krátkodobé operace řízení likvidity - příjmy'),
  ((SELECT id FROM economic_groups WHERE code = '81'), '8118', 'econ-item-8118', 'Aktivní krátkodobé operace řízení likvidity - výdaje'),
  ((SELECT id FROM economic_groups WHERE code = '81'), '8121', 'econ-item-8121', 'Dlouhodobé vydané dluhopisy'),
  ((SELECT id FROM economic_groups WHERE code = '81'), '8122', 'econ-item-8122', 'Uhrazené splátky dlouhodobých vydaných dluhopisů'),
  ((SELECT id FROM economic_groups WHERE code = '81'), '8123', 'econ-item-8123', 'Dlouhodobé přijaté půjčené prostředky'),
  ((SELECT id FROM economic_groups WHERE code = '81'), '8124', 'econ-item-8124', 'Uhrazené splátky dlouhodobých přijatých půjčených prostředků'),
  ((SELECT id FROM economic_groups WHERE code = '81'), '8125', 'econ-item-8125', 'Změna stavu dlouhodobých prostředků na bankovních účtech'),
  ((SELECT id FROM economic_groups WHERE code = '81'), '8127', 'econ-item-8127', 'Aktivní dlouhodobé operace řízení likvidity - příjmy'),
  ((SELECT id FROM economic_groups WHERE code = '81'), '8128', 'econ-item-8128', 'Aktivní dlouhodobé operace řízení likvidity - výdaje'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8211', 'econ-item-8211', 'Krátkodobé vydané dluhopisy'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8212', 'econ-item-8212', 'Uhrazené splátky krátkodobých vydaných dluhopisů'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8213', 'econ-item-8213', 'Krátkodobé přijaté půjčené prostředky'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8214', 'econ-item-8214', 'Uhrazené splátky krátkodobých přijatých půjčených prostředků'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8215', 'econ-item-8215', 'Změna stavu bankovních účtů krátkodobých prostředků ze zahraničí jiných než ze z'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8216', 'econ-item-8216', 'Změna stavu bankovních účtů krátkodobých prostředků z dlouhodobých úvěrů ze zahr'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8217', 'econ-item-8217', 'Aktivní krátkodobé operace řízení likvidity - příjmy'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8218', 'econ-item-8218', 'Aktivní krátkodobé operace řízení likvidity - výdaje'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8221', 'econ-item-8221', 'Dlouhodobé vydané dluhopisy'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8222', 'econ-item-8222', 'Uhrazené splátky dlouhodobých vydaných dluhopisů'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8223', 'econ-item-8223', 'Dlouhodobé přijaté půjčené prostředky'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8224', 'econ-item-8224', 'Uhrazené splátky dlouhodobých přijatých půjčených prostředků'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8225', 'econ-item-8225', 'Změna stavu dlouhodobých prostředků na bankovních účtech'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8227', 'econ-item-8227', 'Aktivní dlouhodobé operace řízení likvidity - příjmy'),
  ((SELECT id FROM economic_groups WHERE code = '82'), '8228', 'econ-item-8228', 'Aktivní dlouhodobé operace řízení likvidity - výdaje'),
  ((SELECT id FROM economic_groups WHERE code = '83'), '8300', 'econ-item-8300', 'Pohyby na účtech pro financování nepatřící na jiné financující položky'),
  ((SELECT id FROM economic_groups WHERE code = '83'), '8301', 'econ-item-8301', 'Převody ve vztahu k úvěrům od Evropské investiční banky'),
  ((SELECT id FROM economic_groups WHERE code = '83'), '8302', 'econ-item-8302', 'Operace na bankovních účtech státních finančních aktiv, které tvoří kapitolu Ope'),
  ((SELECT id FROM economic_groups WHERE code = '84'), '8413', 'econ-item-8413', 'Krátkodobé přijaté půjčené prostředky'),
  ((SELECT id FROM economic_groups WHERE code = '84'), '8414', 'econ-item-8414', 'Uhrazené splátky krátkodobých přijatých půjčených prostředků'),
  ((SELECT id FROM economic_groups WHERE code = '84'), '8417', 'econ-item-8417', 'Krátkodobé aktivní financování z jaderného účtu a účtu rezervy důchodového pojiš'),
  ((SELECT id FROM economic_groups WHERE code = '84'), '8418', 'econ-item-8418', 'Krátkodobé aktivní financování z jaderného účtu a účtu rezervy důchodového pojiš'),
  ((SELECT id FROM economic_groups WHERE code = '84'), '8427', 'econ-item-8427', 'Dlouhodobé aktivní financování z jaderného účtu a účtu rezervy důchodového pojiš'),
  ((SELECT id FROM economic_groups WHERE code = '84'), '8428', 'econ-item-8428', 'Dlouhodobé aktivní financování z jaderného účtu a účtu rezervy důchodového pojiš'),
  ((SELECT id FROM economic_groups WHERE code = '89'), '8901', 'econ-item-8901', 'Operace z peněžních účtů rozpočtové jednotky nemající charakter příjmů a výdajů'),
  ((SELECT id FROM economic_groups WHERE code = '89'), '8902', 'econ-item-8902', 'Nerealizované kursové rozdíly pohybů na devizových účtech'),
  ((SELECT id FROM economic_groups WHERE code = '89'), '8905', 'econ-item-8905', 'Nepřevedené částky vyrovnávající schodek a saldo státní pokladny')
ON CONFLICT (code) DO NOTHING;

-- Add kapitola 373 (Úřad pro přístup k dopravní infrastruktuře, ÚPDI).
-- Zrušená k 1.1.2024 (agenda převedena na ÚOHS), proto chybí v zákoně 434/2024 Sb.,
-- který je zdroj naší seed listy pro rok 2025.
--
-- Pro rok 2024 ale kapitola ještě existovala se schváleným rozpočtem
-- 22 354 tis Kč (skutečnost 0). Bez tohoto řádku ETL pro 2024 skipoval 31
-- řádků s chapter_code=373 (FK violation) → schválené výdaje SR 2024 nám chyběly
-- o 22 354 064 Kč oproti oficiálnímu závěrečnému účtu.

INSERT INTO chapters (code, slug) VALUES ('373', 'updi');
