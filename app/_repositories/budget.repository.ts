// Budget data repository. Drizzle queries on top of the star schema.
//
// Defaults follow the UI "show actual SR scope" convention:
//   - actual values (value_actual column)
//   - SR scope filter (funding_source_code IN ('1','4','5') OR IS NULL)
//
// Returns numbers in CZK (not thousands — see docs/db-schema.md notes).

import { and, desc, eq, inArray, isNotNull, isNull, or, sql } from 'drizzle-orm'

import { db } from '@/app/_db/client'
import {
  budgetFacts,
  categories,
  categoryParagraphMap,
  economicClasses,
  economicGroups,
  economicItems,
  functionalParagraphs,
  functionalSubdivisions,
} from '@/app/_db/schema'

// ─── Shared filters ──────────────────────────────────────────────────────

/** SR-scope funding sources: 1 (základní), 4 (kryté nároky), 5 (překročení) or NULL (older data). */
const srScopeFilter = or(inArray(budgetFacts.fundingSourceCode, ['1', '4', '5']), isNull(budgetFacts.fundingSourceCode))

/** Restricts to rows where cash execution actually happened. */
const hasActualFilter = isNotNull(budgetFacts.valueActual)

// ─── Types ──────────────────────────────────────────────────────────────

export interface YearTotals {
  fiscalYear: number
  /** Plánovaný rozpočet — schválený zákonem. */
  approved: {
    revenue: number
    expenditure: number
    /** Saldo: positive = přebytek, negative = schodek. */
    balance: number
  }
  /** Skutečné plnění. */
  actual: {
    revenue: number
    expenditure: number
    /** Saldo: positive = přebytek, negative = schodek. */
    balance: number
  }
}

export interface ExpenseCategoryRow {
  /** Category slug from `categories.slug` (e.g. 'socialProtection'). */
  slug: string
  /** Aggregated value in CZK. */
  value: number
  isMandatory: boolean
  /** Count of distinct pododdíly (subdivisions) with non-zero activity in this category. */
  subcategoryCount: number
}

export interface IncomeCategoryRow {
  /** UI category slug (vat, incomeTax, socialInsurance, exciseDuties, euTransfers, otherRevenue). */
  slug: string
  /** Aggregated value in CZK. */
  value: number
  /** Count of distinct economic items contributing to this income category. */
  subcategoryCount: number
}

export interface CategorySubdivisionRow {
  /** Czech name from vyhláška for display. */
  name: string
  /** Aggregated value in CZK. */
  value: number
}

// Income → category mapping. Items are NOT joined via paragraph (income has no
// functional dimension), so we apply this regex rule at query time. Patterns
// reflect vyhláška 412/2021 Sb. příloha č. 2 (druhové třídění). Codes outside
// these patterns fall into 'otherRevenue'.
const INCOME_PATTERNS: { slug: string; patterns: RegExp[] }[] = [
  { slug: 'vat', patterns: [/^1211$/, /^1212$/, /^1213$/] },
  { slug: 'incomeTax', patterns: [/^111[1-3]$/, /^112[1-3]$/, /^1131$/] },
  { slug: 'socialInsurance', patterns: [/^161[1-9]$/, /^162[1-9]$/] },
  { slug: 'exciseDuties', patterns: [/^122\d$/, /^123\d$/] },
  { slug: 'euTransfers', patterns: [/^411[6-9]$/, /^421[6-9]$/] },
]

function classifyIncomeItem(itemCode: string): string {
  for (const { slug, patterns } of INCOME_PATTERNS) {
    if (patterns.some((re) => re.test(itemCode))) return slug
  }
  return 'otherRevenue'
}

// ─── Queries ────────────────────────────────────────────────────────────

/** All fiscal years present in budget_facts, newest first. */
export async function listYears(): Promise<number[]> {
  const rows = await db.selectDistinct({ year: budgetFacts.fiscalYear }).from(budgetFacts).orderBy(desc(budgetFacts.fiscalYear))
  return rows.map((r) => r.year)
}

/** Year-level revenue / expenditure / balance (SR scope) from the materialized view. */
export async function getYearTotals(year: number): Promise<YearTotals | null> {
  const rows = await db.execute<{
    fiscal_year: number
    revenue_approved: string | null
    revenue_actual: string | null
    expenditure_approved: string | null
    expenditure_actual: string | null
    balance_approved: string | null
    balance_actual: string | null
  }>(sql`
    SELECT fiscal_year,
           revenue_approved,
           revenue_actual,
           expenditure_approved,
           expenditure_actual,
           balance_approved,
           balance_actual
    FROM fiscal_year_totals
    WHERE fiscal_year = ${year}
  `)
  const row = rows[0]
  if (!row) return null
  return {
    fiscalYear: row.fiscal_year,
    approved: {
      revenue: Number(row.revenue_approved ?? 0),
      expenditure: Number(row.expenditure_approved ?? 0),
      balance: Number(row.balance_approved ?? 0),
    },
    actual: {
      revenue: Number(row.revenue_actual ?? 0),
      expenditure: Number(row.expenditure_actual ?? 0),
      balance: Number(row.balance_actual ?? 0),
    },
  }
}

/**
 * Expense aggregations per UI top-level category (skutečnost, SR scope).
 *
 * Joins category_paragraph_map to roll paragraph-level facts up into the 11
 * curated UI categories (socialProtection, healthcare, ...). Top-level only —
 * subcategories (parent_id IS NOT NULL) excluded.
 *
 * Only economic classes 5 and 6 (běžné/kapitálové výdaje) are summed; revenue
 * lines that happen to share a paragraph never reach this rollup.
 */
export async function getExpenseCategoriesForYear(year: number): Promise<ExpenseCategoryRow[]> {
  const rows = await db
    .select({
      slug: categories.slug,
      isMandatory: categories.isMandatory,
      total: sql<string>`SUM(${budgetFacts.valueActual})`.as('total'),
      subcategoryCount: sql<number>`COUNT(DISTINCT ${functionalSubdivisions.id})`.as('sub_count'),
    })
    .from(budgetFacts)
    .innerJoin(categoryParagraphMap, eq(categoryParagraphMap.paragraphId, budgetFacts.paragraphId))
    .innerJoin(categories, eq(categories.id, categoryParagraphMap.categoryId))
    .innerJoin(functionalParagraphs, eq(functionalParagraphs.id, budgetFacts.paragraphId))
    .innerJoin(functionalSubdivisions, eq(functionalSubdivisions.id, functionalParagraphs.subdivisionId))
    .innerJoin(economicItems, eq(economicItems.id, budgetFacts.itemId))
    .innerJoin(economicGroups, eq(economicGroups.id, economicItems.groupId))
    .innerJoin(economicClasses, eq(economicClasses.id, economicGroups.classId))
    .where(
      and(
        eq(budgetFacts.fiscalYear, year),
        hasActualFilter,
        srScopeFilter,
        eq(categories.type, 'expense'),
        isNull(categories.parentId),
        inArray(economicClasses.code, ['5', '6']),
      ),
    )
    .groupBy(categories.slug, categories.isMandatory)
    .orderBy(sql`SUM(${budgetFacts.valueActual}) DESC`)

  return rows.map((r) => ({
    slug: r.slug,
    isMandatory: r.isMandatory,
    value: Number(r.total),
    subcategoryCount: Number(r.subcategoryCount),
  }))
}

/**
 * Income aggregations per UI top-level category (skutečnost, SR scope).
 *
 * Income lines have no functional classification, so the mapping
 * `item_code → category` is encoded in INCOME_PATTERNS (above), not in DB.
 * We sum at the item level and then bucket in TypeScript.
 *
 * Returns the 6 income categories from docs/budget-categorization.md.
 */
export async function getIncomeCategoriesForYear(year: number): Promise<IncomeCategoryRow[]> {
  const rows = await db
    .select({
      itemCode: economicItems.code,
      total: sql<string>`SUM(${budgetFacts.valueActual})`.as('total'),
    })
    .from(budgetFacts)
    .innerJoin(economicItems, eq(economicItems.id, budgetFacts.itemId))
    .innerJoin(economicGroups, eq(economicGroups.id, economicItems.groupId))
    .innerJoin(economicClasses, eq(economicClasses.id, economicGroups.classId))
    .where(and(eq(budgetFacts.fiscalYear, year), hasActualFilter, srScopeFilter, inArray(economicClasses.code, ['1', '2', '3', '4'])))
    .groupBy(economicItems.code)

  // Bucket items into UI categories with running count of items per bucket
  const buckets = new Map<string, { value: number; count: number }>()
  for (const r of rows) {
    const slug = classifyIncomeItem(r.itemCode)
    const prev = buckets.get(slug) ?? { value: 0, count: 0 }
    buckets.set(slug, { value: prev.value + Number(r.total), count: prev.count + 1 })
  }

  return [...buckets.entries()]
    .map(([slug, { value, count }]) => ({ slug, value, subcategoryCount: count }))
    .sort((a, b) => b.value - a.value)
}

/**
 * Per-pododdíl breakdown within an expense category (drill-down for detail page).
 * Returns each functional subdivision (3-digit code in vyhláška) reachable from
 * the category's paragraph mapping with non-zero actual value, sorted DESC.
 */
export async function getExpenseCategoryPododdily(year: number, categorySlug: string): Promise<CategorySubdivisionRow[]> {
  const rows = await db
    .select({
      name: functionalSubdivisions.nameCs,
      total: sql<string>`SUM(${budgetFacts.valueActual})`.as('total'),
    })
    .from(budgetFacts)
    .innerJoin(categoryParagraphMap, eq(categoryParagraphMap.paragraphId, budgetFacts.paragraphId))
    .innerJoin(categories, eq(categories.id, categoryParagraphMap.categoryId))
    .innerJoin(functionalParagraphs, eq(functionalParagraphs.id, budgetFacts.paragraphId))
    .innerJoin(functionalSubdivisions, eq(functionalSubdivisions.id, functionalParagraphs.subdivisionId))
    .innerJoin(economicItems, eq(economicItems.id, budgetFacts.itemId))
    .innerJoin(economicGroups, eq(economicGroups.id, economicItems.groupId))
    .innerJoin(economicClasses, eq(economicClasses.id, economicGroups.classId))
    .where(
      and(
        eq(budgetFacts.fiscalYear, year),
        hasActualFilter,
        srScopeFilter,
        eq(categories.slug, categorySlug),
        inArray(economicClasses.code, ['5', '6']),
      ),
    )
    .groupBy(functionalSubdivisions.nameCs)
    .orderBy(sql`SUM(${budgetFacts.valueActual}) DESC`)

  return rows.map((r) => ({ name: r.name, value: Number(r.total) }))
}

/**
 * Per-item breakdown within an income category (drill-down for detail page).
 * Returns each economic_item (4-digit code) belonging to the income category
 * with non-zero actual value, sorted DESC. Income categories don't have a
 * functional dimension, so the drill-down is along druhové třídění.
 */
export async function getIncomeCategoryItems(year: number, categorySlug: string): Promise<CategorySubdivisionRow[]> {
  const rows = await db
    .select({
      itemCode: economicItems.code,
      name: economicItems.nameCs,
      total: sql<string>`SUM(${budgetFacts.valueActual})`.as('total'),
    })
    .from(budgetFacts)
    .innerJoin(economicItems, eq(economicItems.id, budgetFacts.itemId))
    .innerJoin(economicGroups, eq(economicGroups.id, economicItems.groupId))
    .innerJoin(economicClasses, eq(economicClasses.id, economicGroups.classId))
    .where(and(eq(budgetFacts.fiscalYear, year), hasActualFilter, srScopeFilter, inArray(economicClasses.code, ['1', '2', '3', '4'])))
    .groupBy(economicItems.code, economicItems.nameCs)

  return rows
    .filter((r) => classifyIncomeItem(r.itemCode) === categorySlug)
    .map((r) => ({ name: r.name, value: Number(r.total) }))
    .sort((a, b) => b.value - a.value)
}
