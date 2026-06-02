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
