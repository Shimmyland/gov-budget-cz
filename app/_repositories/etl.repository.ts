import { and, eq, lte, sql } from 'drizzle-orm'
import { db, LOCK_IDS, withAdvisoryLock } from '@/app/_db/client'
import { budgetFacts, chapterOrgUnits, chapters, economicItems, functionalParagraphs } from '@/app/_db/schema'
import type { DimensionMaps, MonitorPackage } from '@/app/lib/types'

export async function runWithEtlLock<T>(fn: () => Promise<T>) {
  return withAdvisoryLock(LOCK_IDS.etlIngest, fn)
}

export async function getLatestBudgetFactsPeriod(): Promise<MonitorPackage | null> {
  const rows = await db
    .select({
      year: sql<number>`MAX(${budgetFacts.fiscalYear})`,
      month: sql<number>`
        MAX(${budgetFacts.fiscalMonth})
        FILTER (
          WHERE ${budgetFacts.fiscalYear} = (
            SELECT MAX(${budgetFacts.fiscalYear})
            FROM ${budgetFacts}
          )
        )
      `,
    })
    .from(budgetFacts)

  const latest = rows[0]
  if (!latest || latest.year == null || latest.month == null) return null

  return { year: latest.year, month: latest.month }
}

export async function getLoadedFiscalYears(): Promise<number[]> {
  const rows = await db.execute<{ fiscal_year: number }>(sql`SELECT DISTINCT fiscal_year FROM fiscal_year_totals`)
  return rows.map((r) => r.fiscal_year)
}

export async function hasBudgetFactsForPeriod(pkg: MonitorPackage): Promise<boolean> {
  const rows = await db
    .select({ id: budgetFacts.id })
    .from(budgetFacts)
    .where(and(eq(budgetFacts.fiscalYear, pkg.year), eq(budgetFacts.fiscalMonth, pkg.month)))
    .limit(1)
  return rows.length > 0
}

export async function loadDimensionMaps(): Promise<DimensionMaps> {
  const [chapterRows, paragraphRows, itemRows] = await Promise.all([
    db.select({ id: chapters.id, code: chapters.code }).from(chapters),
    db.select({ id: functionalParagraphs.id, code: functionalParagraphs.code }).from(functionalParagraphs),
    db.select({ id: economicItems.id, code: economicItems.code }).from(economicItems),
  ])
  return {
    chapter: new Map(chapterRows.map((r) => [r.code, r.id])),
    paragraph: new Map(paragraphRows.map((r) => [r.code, r.id])),
    item: new Map(itemRows.map((r) => [r.code, r.id])),
  }
}

export async function insertMissingChapterOrgUnits(values: { chapterId: number; code: string; nameCs: string }[]): Promise<number> {
  let inserted = 0
  for (let i = 0; i < values.length; i += 1000) {
    const chunk = values.slice(i, i + 1000)
    const result = await db.insert(chapterOrgUnits).values(chunk).onConflictDoNothing()
    inserted += result.count ?? 0
  }
  return inserted
}

export async function loadChapterOrgUnitMap(chapterMap: Map<string, number>): Promise<Map<string, number>> {
  const all = await db
    .select({ id: chapterOrgUnits.id, code: chapterOrgUnits.code, chapterId: chapterOrgUnits.chapterId })
    .from(chapterOrgUnits)

  const chapterIdToCode = new Map<number, string>()
  for (const [code, id] of chapterMap) {
    chapterIdToCode.set(id, code)
  }

  const orgUnitMap = new Map<string, number>()
  for (const row of all) {
    const chapterCode = chapterIdToCode.get(row.chapterId)
    if (chapterCode) {
      orgUnitMap.set(`${chapterCode}|${row.code}`, row.id)
    }
  }

  return orgUnitMap
}

export async function deleteBudgetFactsCoveredByPackage(pkg: MonitorPackage): Promise<void> {
  await db.delete(budgetFacts).where(and(eq(budgetFacts.fiscalYear, pkg.year), lte(budgetFacts.fiscalMonth, pkg.month)))
}

export async function insertBudgetFactsBatch(batch: (typeof budgetFacts.$inferInsert)[]): Promise<void> {
  if (batch.length === 0) return
  await db.insert(budgetFacts).values(batch)
}

export async function refreshFiscalYearTotals(): Promise<void> {
  await db.execute(sql`REFRESH MATERIALIZED VIEW fiscal_year_totals`)
}
