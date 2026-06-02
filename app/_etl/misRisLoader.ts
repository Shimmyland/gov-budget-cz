// MIS-RIS loader. Drives the end-to-end ETL for one monthly package:
//
//   1. Fetch ZIP and extract MIS-RIS CSV (cached on disk between runs).
//   2. Load dimension lookup maps (code → id) for chapters, paragraphs, items.
//   3. Pass 1: stream CSV, discover unique (chapter, org_unit) tuples, INSERT
//      missing rows into chapter_org_units with a placeholder name. Build the
//      (chapter_code, org_unit_code) → org_unit_id map for Pass 2.
//   4. Pass 2: stream CSV again, look up FK ids in memory, emit 1 budget_facts
//      row per CSV row carrying all 5 value states side-by-side.
//      Idempotent: deletes rows for periods covered by the package first.
//   5. REFRESH MATERIALIZED VIEW fiscal_year_totals.
//
// The CSV is streamed twice instead of buffered — the cache on disk makes the
// second pass cheap (just I/O, no network).

import { and, eq, lte, sql } from 'drizzle-orm'

import db from '@/app/_db/client'
import {
  budgetFacts,
  chapterOrgUnits,
  chapters,
  economicItems,
  functionalParagraphs,
} from '@/app/_db/schema'

import { fetchAndExtract, type MonitorPackage } from './monitorClient'
import { parseMisRis } from './misRisParser'

// Postgres caps parameters per query at 65535. budget_facts has 16 column values
// per row → max 4095 rows per batch; 3000 keeps headroom.
const FACT_BATCH_SIZE = 3000

export interface IngestStats {
  pkg: MonitorPackage
  skippedRowsWithUnknownFk: number
  orgUnitsInserted: number
  budgetFactsInserted: number
  durationMs: number
}

interface DimensionMaps {
  chapter: Map<string, number>
  paragraph: Map<string, number>
  item: Map<string, number>
}

async function loadDimensionMaps(): Promise<DimensionMaps> {
  const [chapterRows, paragraphRows, itemRows] = await Promise.all([
    db.select({ id: chapters.id, code: chapters.code }).from(chapters),
    db
      .select({ id: functionalParagraphs.id, code: functionalParagraphs.code })
      .from(functionalParagraphs),
    db.select({ id: economicItems.id, code: economicItems.code }).from(economicItems),
  ])
  return {
    chapter: new Map(chapterRows.map((r) => [r.code, r.id])),
    paragraph: new Map(paragraphRows.map((r) => [r.code, r.id])),
    item: new Map(itemRows.map((r) => [r.code, r.id])),
  }
}

/** Pass 1: discover org_units in CSV, insert missing ones, return full map. */
async function discoverOrgUnits(
  csvBuffer: Buffer,
  chapterMap: Map<string, number>,
): Promise<{ inserted: number; orgUnitMap: Map<string, number> }> {
  // Collect unique (chapter_code, org_unit_code, ico) tuples while streaming.
  const seen = new Set<string>()
  const toInsert: { chapterCode: string; code: string; ico: string }[] = []

  for await (const row of parseMisRis(csvBuffer)) {
    const key = `${row.chapterCode}|${row.orgUnitCode}`
    if (seen.has(key)) continue
    seen.add(key)
    if (!chapterMap.has(row.chapterCode)) continue
    toInsert.push({ chapterCode: row.chapterCode, code: row.orgUnitCode, ico: row.ico })
  }

  // Bulk insert in chunks; ON CONFLICT (chapter_id, code) DO NOTHING handles re-runs.
  let inserted = 0
  if (toInsert.length > 0) {
    const values = toInsert.map((r) => ({
      chapterId: chapterMap.get(r.chapterCode)!,
      code: r.code,
      nameCs: r.ico ? `IČO ${r.ico}` : `Unknown org_unit ${r.code}`,
    }))
    for (let i = 0; i < values.length; i += 1000) {
      const chunk = values.slice(i, i + 1000)
      const result = await db.insert(chapterOrgUnits).values(chunk).onConflictDoNothing()
      inserted += result.count ?? 0
    }
  }

  // Load the full map: (chapter_code, org_unit_code) → org_unit_id
  const all = await db
    .select({
      id: chapterOrgUnits.id,
      code: chapterOrgUnits.code,
      chapterId: chapterOrgUnits.chapterId,
    })
    .from(chapterOrgUnits)

  const chapterIdToCode = new Map<number, string>()
  for (const [code, id] of chapterMap) chapterIdToCode.set(id, code)

  const orgUnitMap = new Map<string, number>()
  for (const row of all) {
    const chapterCode = chapterIdToCode.get(row.chapterId)
    if (chapterCode) {
      orgUnitMap.set(`${chapterCode}|${row.code}`, row.id)
    }
  }

  return { inserted, orgUnitMap }
}

/** Pass 2: insert budget_facts rows. */
async function loadBudgetFacts(
  csvBuffer: Buffer,
  maps: DimensionMaps & { orgUnit: Map<string, number> },
  pkg: MonitorPackage,
): Promise<{ inserted: number; skipped: number }> {
  // Idempotency: clear rows for periods this package covers (months 1..pkg.month
  // of pkg.year, because MIS-RIS contains all periods from Jan to package month).
  await db
    .delete(budgetFacts)
    .where(and(eq(budgetFacts.fiscalYear, pkg.year), lte(budgetFacts.fiscalMonth, pkg.month)))

  let batch: (typeof budgetFacts.$inferInsert)[] = []
  let inserted = 0
  let skipped = 0

  const flush = async () => {
    if (batch.length === 0) return
    await db.insert(budgetFacts).values(batch)
    inserted += batch.length
    batch = []
  }

  for await (const row of parseMisRis(csvBuffer)) {
    const orgUnitId = maps.orgUnit.get(`${row.chapterCode}|${row.orgUnitCode}`)
    const paragraphId = maps.paragraph.get(row.paragraphCode)
    const itemId = maps.item.get(row.itemCode)

    if (!orgUnitId || !paragraphId || !itemId) {
      skipped++
      continue
    }

    batch.push({
      fiscalYear: row.fiscalYear,
      fiscalMonth: row.fiscalMonth,
      orgUnitId,
      paragraphId,
      itemId,
      fundingSourceCode: row.fundingSourceCode,
      nastrojCode: row.nastrojCode,
      fundCode: row.fundCode,
      edsCode: row.edsCode,
      ucrisCode: row.ucrisCode,
      valueApproved: row.valueApproved !== 0 ? row.valueApproved.toFixed(2) : null,
      valueAmended: row.valueAmended !== 0 ? row.valueAmended.toFixed(2) : null,
      valueFinal: row.valueFinal !== 0 ? row.valueFinal.toFixed(2) : null,
      valueActual: row.valueActual !== 0 ? row.valueActual.toFixed(2) : null,
      valueObligation: row.valueObligation !== 0 ? row.valueObligation.toFixed(2) : null,
    })

    if (batch.length >= FACT_BATCH_SIZE) await flush()
  }
  await flush()

  return { inserted, skipped }
}

/** Run the full ETL for a monthly package. */
export async function ingestPackage(pkg: MonitorPackage): Promise<IngestStats> {
  const start = Date.now()
  const { misRisCsv } = await fetchAndExtract(pkg)

  const dims = await loadDimensionMaps()
  const { inserted: orgUnitsInserted, orgUnitMap } = await discoverOrgUnits(misRisCsv, dims.chapter)
  const { inserted: factsInserted, skipped } = await loadBudgetFacts(
    misRisCsv,
    { ...dims, orgUnit: orgUnitMap },
    pkg,
  )

  await db.execute(sql`REFRESH MATERIALIZED VIEW fiscal_year_totals`)

  return {
    pkg,
    skippedRowsWithUnknownFk: skipped,
    orgUnitsInserted,
    budgetFactsInserted: factsInserted,
    durationMs: Date.now() - start,
  }
}
