import {
  deleteBudgetFactsCoveredByPackage,
  getLatestBudgetFactsPeriod,
  getLoadedFiscalYears,
  hasBudgetFactsForPeriod,
  insertBudgetFactsBatch,
  insertMissingChapterOrgUnits,
  loadChapterOrgUnitMap,
  loadDimensionMaps,
  refreshFiscalYearTotals,
  runWithEtlLock,
} from '@/app/_repositories/etl.repository'
import { fetchAndExtract } from '@/app/_services/monitor.service'
import { MonitorClientError } from '@/app/lib/errors'
import type { DimensionMaps, MonitorPackage } from '@/app/lib/types'
import { parseMisRis } from '@/app/_services/mis-ris-parser.service'
import { logger } from '../lib/logger'

const FACT_BATCH_SIZE = 3000

type PackageOutcome = 'loaded' | 'already_exists' | 'not_yet_published'

export async function loadMissingYears(trigger: 'startup' | 'cron'): Promise<void> {
  const prefix = `[${trigger}]`
  const startYear = Number(process.env.ETL_START_YEAR ?? 2018)
  const currentYear = new Date().getUTCFullYear()
  const startedAt = Date.now()

  const lockResult = await runWithEtlLock(async () => {
    let loaded = 0

    // Phase 1: completed years — load December (year-to-date covers full year)
    const loadedYears = new Set(await getLoadedFiscalYears())
    for (let year = startYear; year < currentYear; year++) {
      if (loadedYears.has(year)) continue
      try {
        const outcome = await loadPackage({ year, month: 12 }, trigger)
        if (outcome === 'loaded') loaded++
      } catch {
        return loaded
      }
    }

    // Phase 2: current year — iterate monthly from latest+1 (or Jan if no data yet)
    const latest = await getLatestBudgetFactsPeriod()
    let next: MonitorPackage = latest && latest.year >= currentYear ? nextPeriod(latest) : { year: currentYear, month: 1 }

    while (next.year === currentYear) {
      let outcome: PackageOutcome
      try {
        outcome = await loadPackage(next, trigger)
      } catch {
        return loaded
      }
      if (outcome === 'not_yet_published') break
      if (outcome === 'loaded') loaded++
      next = nextPeriod(next)
    }

    if (loaded > 0) {
      logger.info(`${prefix} refreshing fiscal_year_totals`)
      await refreshFiscalYearTotals()
    }
    return loaded
  })

  if (!lockResult.acquired) {
    logger.info(`${prefix} ETL lock held by another replica — skipping`)
    return
  }

  const durationS = ((Date.now() - startedAt) / 1000).toFixed(1)
  if (lockResult.result > 0) {
    logger.info(`${prefix} catch-up complete: ${lockResult.result} package(s) in ${durationS}s`)
  } else {
    logger.info(`${prefix} nothing to load`)
  }
}

async function loadPackage(pkg: MonitorPackage, trigger: 'startup' | 'cron'): Promise<PackageOutcome> {
  const prefix = `[${trigger}]`
  const label: string = `${pkg.year}-${String(pkg.month).padStart(2, '0')}`

  if (await hasBudgetFactsForPeriod(pkg)) {
    logger.info(`${prefix} Package ${label} already loaded — skipping`)
    return 'already_exists'
  }

  try {
    logger.info(`${prefix} loading ${label}`)
    const stats = await ingestPackage(pkg)
    logger.info(`${prefix} Ingested ${label}: +${stats.budgetFactsInserted} rows in ${(stats.durationMs / 1000).toFixed(1)}s`)
    return 'loaded'
  } catch (err) {
    if (err instanceof MonitorClientError && err.status === 404) {
      logger.info(`${prefix} Package ${label} not yet published`)
      return 'not_yet_published'
    }
    logger.error({ err }, `${prefix} Ingest failed for ${label}`)
    throw err
  }
}

async function prepareOrgUnits(misRisCsv: Buffer, dims: DimensionMaps): Promise<Map<string, number>> {
  const seen = new Set<string>()
  const toInsert: { chapterId: number; code: string; nameCs: string }[] = []

  for await (const row of parseMisRis(misRisCsv)) {
    const key = `${row.chapterCode}|${row.orgUnitCode}`
    if (seen.has(key)) continue
    seen.add(key)

    const chapterId = dims.chapter.get(row.chapterCode)
    if (!chapterId) continue

    toInsert.push({
      chapterId,
      code: row.orgUnitCode,
      nameCs: row.ico ? `IČO ${row.ico}` : `Unknown org_unit ${row.orgUnitCode}`,
    })
  }

  await insertMissingChapterOrgUnits(toInsert)
  return loadChapterOrgUnitMap(dims.chapter)
}

async function insertFacts(misRisCsv: Buffer, dims: DimensionMaps, orgUnitMap: Map<string, number>, pkg: MonitorPackage): Promise<number> {
  await deleteBudgetFactsCoveredByPackage(pkg)

  let batch: Parameters<typeof insertBudgetFactsBatch>[0] = []
  let count = 0

  const flush = async () => {
    if (batch.length === 0) return
    await insertBudgetFactsBatch(batch)
    count += batch.length
    batch = []
  }

  for await (const row of parseMisRis(misRisCsv)) {
    const orgUnitId = orgUnitMap.get(`${row.chapterCode}|${row.orgUnitCode}`)
    const paragraphId = dims.paragraph.get(row.paragraphCode)
    const itemId = dims.item.get(row.itemCode)

    if (!orgUnitId || !paragraphId || !itemId) continue

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
  return count
}

async function ingestPackage(pkg: MonitorPackage): Promise<{ budgetFactsInserted: number; durationMs: number }> {
  const start = Date.now()
  const { misRisCsv } = await fetchAndExtract(pkg)
  const dims = await loadDimensionMaps()
  const orgUnitMap = await prepareOrgUnits(misRisCsv, dims)
  const budgetFactsInserted = await insertFacts(misRisCsv, dims, orgUnitMap, pkg)
  return { budgetFactsInserted, durationMs: Date.now() - start }
}

function nextPeriod(pkg: MonitorPackage): MonitorPackage {
  return pkg.month === 12 ? { year: pkg.year + 1, month: 1 } : { year: pkg.year, month: pkg.month + 1 }
}
