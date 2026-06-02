import {
  type AnyPgColumn,
  pgTable,
  pgEnum,
  serial,
  bigserial,
  varchar,
  text,
  smallint,
  integer,
  numeric,
  boolean,
  char,
  index,
  unique,
  primaryKey,
} from 'drizzle-orm/pg-core'

// =============================================================
// 1. Administrative classification
// =============================================================

export const chapters = pgTable('chapters', {
  id: serial().primaryKey(),
  code: varchar({ length: 20 }).notNull().unique(),
  slug: varchar({ length: 100 }).notNull().unique(),
})

export const chapterOrgUnits = pgTable(
  'chapter_org_units',
  {
    id: serial().primaryKey(),
    chapterId: integer()
      .notNull()
      .references(() => chapters.id, { onDelete: 'cascade' }),
    code: varchar({ length: 20 }).notNull(),
    nameCs: text().notNull(),
  },
  (t) => [unique().on(t.chapterId, t.code)],
)

// =============================================================
// 2. Functional classification
// =============================================================

export const functionalDivisions = pgTable('functional_divisions', {
  id: serial().primaryKey(),
  code: varchar({ length: 2 }).notNull().unique(),
  slug: varchar({ length: 100 }).notNull().unique(),
  nameCs: text().notNull(),
})

export const functionalSubdivisions = pgTable('functional_subdivisions', {
  id: serial().primaryKey(),
  divisionId: integer()
    .notNull()
    .references(() => functionalDivisions.id, { onDelete: 'cascade' }),
  code: varchar({ length: 3 }).notNull().unique(),
  slug: varchar({ length: 100 }).notNull().unique(),
  nameCs: text().notNull(),
})

export const functionalParagraphs = pgTable('functional_paragraphs', {
  id: serial().primaryKey(),
  subdivisionId: integer()
    .notNull()
    .references(() => functionalSubdivisions.id, { onDelete: 'cascade' }),
  code: varchar({ length: 4 }).notNull().unique(),
  slug: varchar({ length: 100 }).notNull().unique(),
  nameCs: text().notNull(),
})

// =============================================================
// 3. Economic classification
// =============================================================

export const economicClasses = pgTable('economic_classes', {
  id: serial().primaryKey(),
  code: char({ length: 1 }).notNull().unique(),
  slug: varchar({ length: 100 }).notNull().unique(),
  nameCs: text().notNull(),
})

export const economicGroups = pgTable('economic_groups', {
  id: serial().primaryKey(),
  classId: integer()
    .notNull()
    .references(() => economicClasses.id, { onDelete: 'cascade' }),
  code: varchar({ length: 2 }).notNull().unique(),
  slug: varchar({ length: 100 }).notNull().unique(),
  nameCs: text().notNull(),
})

export const economicItems = pgTable('economic_items', {
  id: serial().primaryKey(),
  groupId: integer()
    .notNull()
    .references(() => economicGroups.id, { onDelete: 'cascade' }),
  code: varchar({ length: 4 }).notNull().unique(),
  slug: varchar({ length: 100 }).notNull().unique(),
  nameCs: text().notNull(),
})

// =============================================================
// 4. Fact table
// =============================================================

// One row per fully-qualified MIS-RIS tuple. All five budget value states are
// held side-by-side as NULLable columns (NULL when MIS-RIS leaves them empty
// for that tuple). See migration 0019 and docs/db-schema.md.
export const budgetFacts = pgTable(
  'budget_facts',
  {
    id: bigserial({ mode: 'number' }).primaryKey(),
    fiscalYear: smallint().notNull(),
    fiscalMonth: smallint().notNull(),
    orgUnitId: integer()
      .notNull()
      .references(() => chapterOrgUnits.id),
    paragraphId: integer()
      .notNull()
      .references(() => functionalParagraphs.id),
    itemId: integer()
      .notNull()
      .references(() => economicItems.id),
    // #5 podkladové (ZC_ZDROJA): '1' základní, '2'–'3' mimorozpočtové,
    // '4' kryté nároky, '5' překročení. NULL in 2020–2023 files.
    fundingSourceCode: char({ length: 1 }),
    // #7 nástrojové (ZC_NASTRJ): funding instrument code. '0000' = none,
    // '01xx' = EU OP, '04xx' = FM EHP/Norway, '05xx' = Swiss, '0143'/'0186' = NPO, '0170' = SZP.
    nastrojCode: varchar({ length: 20 }),
    // #8 doplňkové (ZC_FUND): účelově sledovaný celek (earmarked agenda).
    fundCode: varchar({ length: 20 }),
    // #9 programové (ZC_EDS): EDS/SMVS program identifier.
    edsCode: varchar({ length: 20 }),
    // #10 účelové (ZC_UCRIS): purpose of transfer.
    ucrisCode: varchar({ length: 20 }),
    // Budget value states from MIS-RIS — held side-by-side.
    valueApproved: numeric({ precision: 14, scale: 2 }),
    valueAmended: numeric({ precision: 14, scale: 2 }),
    valueFinal: numeric({ precision: 14, scale: 2 }),
    valueActual: numeric({ precision: 14, scale: 2 }),
    valueObligation: numeric({ precision: 14, scale: 2 }),
  },
  (t) => [
    index('idx_facts_fiscal_year').on(t.fiscalYear),
    index('idx_facts_year_month').on(t.fiscalYear, t.fiscalMonth),
    index('idx_facts_org_unit').on(t.orgUnitId),
    index('idx_facts_paragraph').on(t.paragraphId),
    index('idx_facts_item').on(t.itemId),
    index('idx_facts_year_org').on(t.fiscalYear, t.orgUnitId),
    index('idx_facts_nastroj').on(t.nastrojCode),
  ],
)

// =============================================================
// 5. Application layer
// =============================================================

export const categoryType = pgEnum('category_type', ['expense', 'income'])

export const categories = pgTable('categories', {
  id: serial().primaryKey(),
  parentId: integer().references((): AnyPgColumn => categories.id),
  slug: varchar({ length: 60 }).notNull().unique(),
  type: categoryType().notNull(),
  isMandatory: boolean().notNull().default(false),
})

export const categoryParagraphMap = pgTable(
  'category_paragraph_map',
  {
    categoryId: integer()
      .notNull()
      .references(() => categories.id, { onDelete: 'cascade' }),
    paragraphId: integer()
      .notNull()
      .references(() => functionalParagraphs.id, { onDelete: 'cascade' }),
  },
  (t) => [primaryKey({ columns: [t.categoryId, t.paragraphId] })],
)
